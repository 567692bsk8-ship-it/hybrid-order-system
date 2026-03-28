import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'table_model.dart';

part 'table_repository.g.dart';

@riverpod
TableRepository tableRepository(Ref ref) => TableRepository();

class TableRepository {
  final _firestore = FirebaseFirestore.instance;

  // トークンからテーブル情報を取得
  Future<TableModel?> getTableByToken(String token) async {
    final query = await _firestore
        .collection('tables')
        .where('token', isEqualTo: token)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return TableModel.fromJson({...query.docs.first.data(), 'id': query.docs.first.id});
  }

  // 初期シードデータ (テーブル1〜10番)
  Future<void> seedTableData() async {
    final collection = _firestore.collection('tables');
    
    final List<Map<String, String>> seeds = [
      {'num': '1', 'tok': 'A7b3Xz9K2m1p', 'role': 'customer'},
      {'num': '2', 'tok': 'B1c4Yr8L1n2q', 'role': 'customer'},
      {'num': '3', 'tok': 'C2d5Zs7M0p3r', 'role': 'customer'},
      {'num': '4', 'tok': 'D3e6Wt6N9q4s', 'role': 'customer'},
      {'num': '5', 'tok': 'E4f7Vs5O8r5t', 'role': 'customer'},
      {'num': '6', 'tok': 'F5g8Us4P7s6u', 'role': 'customer'},
      {'num': '7', 'tok': 'G6h9Ts3Q6t7v', 'role': 'customer'},
      {'num': '8', 'tok': 'H7i0Rs2R5u8w', 'role': 'customer'},
      {'num': '9', 'tok': 'I8j1Qs1S4v9x', 'role': 'customer'},
      {'num': '10', 'tok': 'J9k2Ps0T3w0y', 'role': 'customer'},
      // 管理者
      {'num': 'Staff', 'tok': 'S1T2A3F4F5K6', 'role': 'staff'},
      // 開発者
      {'num': 'Dev', 'tok': 'D1E2V3E4L5O6', 'role': 'developer'},
    ];

    print('[Firestore] Starting table re-seeding...');
    int count = 0;
    for (var seed in seeds) {
      final model = TableModel(
        id: 'table_${seed['num']}',
        tableNumber: seed['num']!,
        token: seed['tok']!,
        role: seed['role']!,
        isActive: true,
      );
      await collection.doc(model.id).set(model.toJson());
      count++;
    }
    print('[Firestore] Table re-seeding completed. Created/Updated $count tables.');
  }
}
