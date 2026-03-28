import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'menu_model.dart';
import 'menu_option_model.dart';

part 'menu_repository.g.dart';

@riverpod
MenuRepository menuRepository(Ref ref) => MenuRepository();

class MenuRepository {
  final _firestore = FirebaseFirestore.instance;

  // メニュー一覧の取得
  Stream<List<MenuModel>> watchMenu() {
    return _firestore
        .collection('menus')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // カテゴリーに応じたトッピング（オプション）の取得
  Stream<List<MenuOptionModel>> watchOptionsByCategory(String category) {
    return _firestore
        .collection('menu_options')
        .where('targetCategory', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuOptionModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // 初期シードデータの投入 (既存データを一掃して最新を反映)
  Future<void> seedOptionData() async {
    final collection = _firestore.collection('menu_options');
    
    // 1. 既存データを全削除してクリーンな状態にする (不整合防止)
    final existing = await collection.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    // 2. 最新のフルオプションリストを定義
    final options = [
      // ラーメン用 (フルセット)
      MenuOptionModel(id: 'r_opt_1', name: '麺大盛り', price: 150, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_2', name: '味付け玉子', price: 120, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_3', name: 'チャーシュー増量', price: 300, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_4', name: 'のり増し', price: 100, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_5', name: '白髪ネギ', price: 150, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_6', name: 'メンマ増量', price: 120, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_7', name: '背脂多め', price: 50, targetCategory: 'ラーメン'),
      MenuOptionModel(id: 'r_opt_8', name: '特製辛味', price: 50, targetCategory: 'ラーメン'),
      
      // つけ麺用
      MenuOptionModel(id: 't_opt_1', name: '麺特盛り', price: 250, targetCategory: 'つけ麺'),
      MenuOptionModel(id: 't_opt_2', name: 'あつもり', price: 0, targetCategory: 'つけ麺'),
      MenuOptionModel(id: 't_opt_3', name: 'スープ増量', price: 100, targetCategory: 'つけ麺'),
      MenuOptionModel(id: 't_opt_4', name: '魚粉増し', price: 50, targetCategory: 'つけ麺'),

      // サイドメニュー用
      MenuOptionModel(id: 's_opt_1', name: 'ライスセット', price: 200, targetCategory: 'サイド'),
      MenuOptionModel(id: 's_opt_2', name: 'マヨネーズ', price: 30, targetCategory: 'サイド'),
      MenuOptionModel(id: 's_opt_3', name: '大盛り(サイド)', price: 150, targetCategory: 'サイド'),

      // ドリンク用
      MenuOptionModel(id: 'd_opt_1', name: '氷なし', price: 0, targetCategory: 'ドリンク'),
      MenuOptionModel(id: 'd_opt_2', name: 'メガサイズ変更', price: 300, targetCategory: 'ドリンク'),
    ];

    print('Re-seeding full options after cleanup...');
    for (var opt in options) {
      await collection.doc(opt.id).set(opt.toJson());
    }
    print('Option seeding completed.');
  }

  // 初期シードデータの投入
  Future<void> seedMenuData() async {
    final collection = _firestore.collection('menus');
    
    // 既存データがあるかチェック
    final existing = await collection.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('Menu data already exists in Firestore.');
      return;
    }

    final menus = [
      // ラーメン - 醤油
      MenuModel(id: 'r_shoyu_1', category: 'ラーメン', subCategory: '醤油', name: '特製醤油ラーメン', description: '鶏ガラと魚介のコク深い王道醤油。', basePrice: 880, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_shoyu_2', category: 'ラーメン', subCategory: '醤油', name: '醤油チャーシュー麺', description: '厚切りチャーシューが5枚乗った満足の一杯。', basePrice: 1180, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_shoyu_3', category: 'ラーメン', subCategory: '醤油', name: '味玉醤油ラーメン', description: 'とろ〜り半熟の味付け玉子をトッピング。', basePrice: 980, imageUrl: 'assets/images/ramen.png'),
      
      // ラーメン - 味噌
      MenuModel(id: 'r_miso_1', category: 'ラーメン', subCategory: '味噌', name: '濃厚芳醇味噌ラーメン', description: '三種の味噌をブレンドした濃厚な味わい。', basePrice: 950, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_miso_2', category: 'ラーメン', subCategory: '味噌', name: '辛味噌ラーメン', description: '自家製ラー油の刺激が食欲をそそる。', basePrice: 1050, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_miso_3', category: 'ラーメン', subCategory: '味噌', name: '特製味噌バターコーン', description: '味噌のコクを引き立てる背徳のトッピング。', basePrice: 1150, imageUrl: 'assets/images/ramen.png'),

      // ラーメン - 塩
      MenuModel(id: 'r_shio_1', category: 'ラーメン', subCategory: '塩', name: '淡麗ゆず塩ラーメン', description: 'ゆずが香る透明感のある黄金スープ。', basePrice: 850, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_shio_2', category: 'ラーメン', subCategory: '塩', name: '海鮮塩バターラーメン', description: '海の幸の旨みが溶け出した贅沢な一杯。', basePrice: 1080, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'r_shio_3', category: 'ラーメン', subCategory: '塩', name: 'ネギ塩ラーメン', description: 'シャキシャキの白髪ネギがたっぷりと。', basePrice: 950, imageUrl: 'assets/images/ramen.png'),

      // つけ麺
      MenuModel(id: 't_1', category: 'つけ麺', subCategory: '濃厚', name: '極太魚介つけ麺', description: '超濃厚な魚介豚骨スープと全粒粉麺。', basePrice: 980, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 't_2', category: 'つけ麺', subCategory: '油そば', name: '特製油そば', description: '醤油ベースの特製タレとラー油、お酢で。', basePrice: 850, imageUrl: 'assets/images/ramen.png'),

      // サイド
      MenuModel(id: 's_1', category: 'サイド', subCategory: '揚げ物', name: '手包み羽根つき餃子', description: '外はパリッと中は肉汁溢れる看板サイド。', basePrice: 450, imageUrl: 'assets/images/gyoza.png'),
      MenuModel(id: 's_2', category: 'サイド', subCategory: '揚げ物', name: 'ジューシー唐揚げ', description: '秘伝のタレに漬け込んだ大ぶりな唐揚げ。', basePrice: 580, imageUrl: 'assets/images/gyoza.png'),

      // ドリンク
      MenuModel(id: 'd_1', category: 'ドリンク', subCategory: 'ソフトドリンク', name: 'コーラ', description: 'キンキンに冷えたコカ・コーラ。', basePrice: 250, imageUrl: 'assets/images/ramen.png'),
      MenuModel(id: 'd_2', category: 'ドリンク', subCategory: 'アルコール', name: 'プレミアム生ビール', description: '厳選された麦芽100%の極上生。', basePrice: 550, imageUrl: 'assets/images/ramen.png'),
    ];

    print('Starting menu seeding...');
    for (var menu in menus) {
      await collection.doc(menu.id).set(menu.toJson());
    }
    print('Menu seeding completed successfully.');
  }

  // --- CRUD 操作 (管理者用) ---

  // メニューの更新
  Future<void> updateMenu(MenuModel menu) async {
    await _firestore.collection('menus').doc(menu.id).set(menu.toJson());
  }

  // メニューの削除
  Future<void> deleteMenu(String menuId) async {
    await _firestore.collection('menus').doc(menuId).delete();
  }

  // メニューの新規追加
  Future<void> addMenu(MenuModel menu) async {
    final docRef = _firestore.collection('menus').doc();
    final newMenu = menu.copyWith(id: docRef.id);
    await docRef.set(newMenu.toJson());
  }

  // トッピングの更新
  Future<void> updateOption(MenuOptionModel option) async {
    await _firestore.collection('menu_options').doc(option.id).set(option.toJson());
  }

  // トッピングの削除
  Future<void> deleteOption(String optionId) async {
    await _firestore.collection('menu_options').doc(optionId).delete();
  }

  // トッピングの新規追加
  Future<void> addOption(MenuOptionModel option) async {
    final docRef = _firestore.collection('menu_options').doc();
    final newOption = option.copyWith(id: docRef.id);
    await docRef.set(newOption.toJson());
  }

  // 管理者用：全てのメニュー（品切れ含む）を監視
  Stream<List<MenuModel>> watchAllMenu() {
    return _firestore
        .collection('menus')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
