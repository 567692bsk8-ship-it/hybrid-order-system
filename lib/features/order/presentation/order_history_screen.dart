import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/order_repository.dart';
import '../data/order_model.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStream = ref.watch(orderRepositoryProvider).watchMyOrders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('注文履歴はありません'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFF006241)),
                  title: Text('注文 #${order.orderNumber.toString().padLeft(3, '0')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${order.createdAt.toLocal().toString().substring(0, 16)} - ¥${order.totalAmount}'),
                  trailing: _buildStatusBadge(order.status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String label = '確認中';
    Color color = Colors.grey;
    if (status == 'cooking') { label = '調理中'; color = Colors.blue; }
    if (status == 'served' || status == 'completed') { label = '完了'; color = Colors.green; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
