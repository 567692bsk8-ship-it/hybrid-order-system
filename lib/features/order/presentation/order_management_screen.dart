import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/order_repository.dart';
import '../data/order_model.dart';

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(orderRepositoryProvider).watchOrders();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('STAFF ONLY - 注文管理', style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: '受付待ち'),
              Tab(text: '調理中'),
              Tab(text: '完了'),
            ],
            labelColor: Color(0xFF006241),
            indicatorColor: Color(0xFF006241),
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: orderStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final orders = snapshot.data!;
            
            return TabBarView(
              children: [
                _buildOrderList(context, ref, orders.where((o) => o.status == 'waiting_payment').toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)), "注文を受付・支払済みへ"),
                _buildOrderList(context, ref, orders.where((o) => o.status == 'cooking').toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)), "調理完了・提供へ"),
                _buildOrderList(context, ref, orders.where((o) => o.status == 'served' || o.status == 'completed').toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)), ""), // 完了は新しい順
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, WidgetRef ref, List<OrderModel> orders, String actionLabel) {
    if (orders.isEmpty) return const Center(child: Text('注文はありません'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status),
              child: Text('#${order.orderNumber}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text('${order.tableNumber} - ¥${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('注文: ${TimeOfDay.fromDateTime(order.createdAt).format(context)} / 決済: ${order.paymentMethod == 'online' ? '事前' : 'レジ'} (${order.isPaid ? '済' : '未'})'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text('【注文内容】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFF006241), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.name} x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (item.selectedOptions.isNotEmpty)
                                  Text('  ${item.selectedOptions.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (order.status == 'waiting_payment')
                          _buildStatusButton(ref, order, '支払完了・調理開始', 'cooking', true),
                        if (order.status == 'cooking')
                          _buildStatusButton(ref, order, '調理完了・配膳', 'served', true),
                        if (order.status == 'served')
                          _buildStatusButton(ref, order, '会計完了', 'completed', true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(WidgetRef ref, OrderModel order, String label, String nextStatus, bool isPaid) {
    return ElevatedButton(
      onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, nextStatus, isPaid),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006241),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting_payment': return Colors.orange;
      case 'cooking': return Colors.blue;
      case 'served': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
