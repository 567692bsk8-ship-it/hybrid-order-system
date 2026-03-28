import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode 用
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_order_app/features/table/providers/table_provider.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 🚀 起動高速化：Firebase への全シード書き込み・画像アップロードを停止
  // すでにデータは投入済みのため、管理画面から編集・管理が可能です。
  /*
  await QuickImageUploader.uploadInitialImages();
  final container = ProviderContainer();
  final menuRepo = container.read(menuRepositoryProvider);
  await menuRepo.seedMenuData();
  await menuRepo.seedOptionData();
  final tableRepo = container.read(tableRepositoryProvider);
  await tableRepo.seedTableData();
  */
  
  runApp(
    const ProviderScope(
      child: MobileOrderApp(),
    ),
  );
}

class MobileOrderApp extends ConsumerWidget {
  const MobileOrderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🛡 開発効率UP：デバッグモードの時は自動で開発者(developer)ロールに設定
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userRoleProvider.notifier).setRole('developer');
        ref.read(authenticatedRoleProvider.notifier).setAuthenticatedRole('developer');
        ref.read(currentTableProvider.notifier).setTable('Dev');
      });
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Order & Pay',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
