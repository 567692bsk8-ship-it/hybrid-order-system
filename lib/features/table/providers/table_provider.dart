import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'table_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentTable extends _$CurrentTable {
  @override
  String build() {
    return "";
  }

  void setTable(String tableNumber) {
    state = tableNumber;
  }
}

@Riverpod(keepAlive: true)
class UserRole extends _$UserRole {
  @override
  String build() {
    return "customer"; // 現在のビュー（表示ロール）
  }

  void setRole(String role) {
    state = role;
  }
}

// 🛡 真の権限（本来のロール）を保持するためのプロバイダー
// これにより、ビューを切り替えても「本来のステータス」を失わずに済む
@Riverpod(keepAlive: true)
class AuthenticatedRole extends _$AuthenticatedRole {
  @override
  String build() {
    return "customer";
  }

  void setAuthenticatedRole(String role) {
    state = role;
  }
}
