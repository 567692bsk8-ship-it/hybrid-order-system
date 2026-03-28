import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/order_model.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) => OrderRepository();

class OrderRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<String> submitOrder(OrderModel order) async {
    final docRef = _firestore.collection('orders').doc();
    final orderWithId = order.copyWith(id: docRef.id);
    
    // JSONに変換（converterによって DateTime は Timestamp に変換される）
    final data = orderWithId.toJson();
    
    await docRef.set(data);
    return docRef.id;
  }

  // 全ての注文をリアルタイムで監視 (管理者用)
  Stream<List<OrderModel>> watchOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // 注文ステータスの更新
  Future<void> updateOrderStatus(String orderId, String newStatus, bool isPaid) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'isPaid': isPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 注文履歴 (特定ユーザー/デバイス用 - 今回は簡易的に全取得)
  Stream<List<OrderModel>> watchMyOrders() => watchOrders();

  // 注文番号（シーケンシャルな番号）を生成する簡易ロジック
  Future<int> getNextOrderNumber() async {
    // 実際はトランザクションやカウンターを使う方が良いが、MVPでは今日の日付の注文数+1で代用
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final snapshot = await _firestore.collection('orders')
      .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
      .count()
      .get();
      
    return (snapshot.count ?? 0) + 1;
  }
}
