import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_order_app/features/order/data/order_model.dart';
import 'package:mobile_order_app/features/order/data/order_repository.dart';
import '../providers/cart_provider.dart';
import '../../table/providers/table_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final paymentMode = ref.watch(paymentModeNotifierProvider);
    final total = ref.watch(cartProvider.notifier).totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) => _buildCartItemCard(cartItems[index], index, ref),
                  ),
          ),
          
          if (cartItems.isNotEmpty)
            _buildPaymentSection(context, ref, paymentMode, total, cartItems),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'カートは空です',
            style: GoogleFonts.notoSansJp(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(OrderItem item, int index, WidgetRef ref) {
    final basePrice = 980; 

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.all(16),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.selectedOptions.join(', '),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text('¥${item.unitPrice * item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006241))),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: () => ref.read(cartProvider.notifier).removeItem(index),
        ),
        children: [
          const Divider(),
          _buildEditSection(
            '麺の硬さ',
            ['柔らかめ', '普通', '硬め', 'バリカタ'],
            item.selectedOptions.firstWhere((o) => o.startsWith('麺:'), orElse: () => '麺:普通').substring(2),
            (val) => _updateCartItem(ref, index, item, '麺', val, basePrice),
          ),
          const SizedBox(height: 16),
          _buildEditSection(
            '味の濃さ',
            ['薄め', '普通', '濃いめ'],
            item.selectedOptions.firstWhere((o) => o.startsWith('味:'), orElse: () => '味:普通').substring(2),
            (val) => _updateCartItem(ref, index, item, '味', val, basePrice),
          ),
          const SizedBox(height: 16),
          _buildMultiEditSection(
            'トッピング',
            ['煮たまご (+¥100)', 'チャーシュー (+¥250)', 'のり (+¥50)', 'ネギ (+¥50)'],
            item.selectedOptions.where((o) => o.contains('(+¥')).toList(),
            (val) => _toggleTopping(ref, index, item, val, basePrice),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('数量', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildCounterButton(Icons.remove, () {
                    if (item.quantity > 1) {
                      ref.read(cartProvider.notifier).updateItem(index, item.copyWith(quantity: item.quantity - 1));
                    }
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('${item.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildCounterButton(Icons.add, () {
                    ref.read(cartProvider.notifier).updateItem(index, item.copyWith(quantity: item.quantity + 1));
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiEditSection(String title, List<String> options, List<String> currentList, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) => FilterChip(
            label: Text(opt, style: const TextStyle(fontSize: 11)),
            selected: currentList.contains(opt),
            onSelected: (val) => onSelected(opt),
            selectedColor: const Color(0xFFD4E9E2),
            checkmarkColor: const Color(0xFF006241),
            side: BorderSide(color: currentList.contains(opt) ? const Color(0xFF006241) : Colors.grey.shade300),
            labelStyle: TextStyle(
              color: currentList.contains(opt) ? const Color(0xFF006241) : Colors.black87,
              fontWeight: currentList.contains(opt) ? FontWeight.bold : FontWeight.normal,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildEditSection(String title, List<String> options, String current, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) => ActionChip(
            label: Text(opt, style: const TextStyle(fontSize: 12)),
            onPressed: () => onSelected(opt),
            backgroundColor: current == opt ? const Color(0xFFD4E9E2) : Colors.transparent,
            side: BorderSide(color: current == opt ? const Color(0xFF006241) : Colors.grey.shade300),
            labelStyle: TextStyle(color: current == opt ? const Color(0xFF006241) : Colors.black87),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  // トッピングの切替
  void _toggleTopping(WidgetRef ref, int index, OrderItem item, String topping, int basePrice) {
    final newOptions = List<String>.from(item.selectedOptions);
    if (newOptions.contains(topping)) {
      newOptions.remove(topping);
    } else {
      newOptions.add(topping);
    }
    _applyUpdate(ref, index, item, newOptions, basePrice);
  }

  // カート内アイテムの更新処理 (麺、味、トッピング共通)
  void _updateCartItem(WidgetRef ref, int index, OrderItem item, String prefix, String newVal, int basePrice) {
    final newOptions = List<String>.from(item.selectedOptions);
    final optIndex = newOptions.indexWhere((o) => o.startsWith('$prefix:'));
    if (optIndex != -1) {
      newOptions[optIndex] = '$prefix:$newVal';
    } else {
      newOptions.add('$prefix:$newVal');
    }
    _applyUpdate(ref, index, item, newOptions, basePrice);
  }

  // 最終的な Provider 更新と価格再計算
  void _applyUpdate(WidgetRef ref, int index, OrderItem item, List<String> newOptions, int basePrice) {
    int additionalPrice = 0;
    final priceRegExp = RegExp(r'¥(\d+)');
    for (final opt in newOptions) {
      final match = priceRegExp.firstMatch(opt);
      if (match != null) {
        additionalPrice += int.parse(match.group(1)!);
      }
    }

    ref.read(cartProvider.notifier).updateItem(
      index,
      item.copyWith(
        selectedOptions: newOptions,
        unitPrice: basePrice + additionalPrice,
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, WidgetRef ref, PaymentMode mode, int total, List<OrderItem> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          SegmentedButton<PaymentMode>(
            segments: const [
              ButtonSegment(value: PaymentMode.online, label: Text('事前決済'), icon: Icon(Icons.credit_card)),
              ButtonSegment(value: PaymentMode.atRegister, label: Text('レジ精算'), icon: Icon(Icons.payments_outlined)),
            ],
            selected: {mode},
            onSelectionChanged: (set) => ref.read(paymentModeNotifierProvider.notifier).setMode(set.first),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('¥$total', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF006241))),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submitOrder(context, ref, items, mode, total),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006241),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: Text('決済して注文を確定', style: GoogleFonts.notoSansJp(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref, List<OrderItem> items, PaymentMode mode, int total) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF006241))),
    );

    try {
      final repository = ref.read(orderRepositoryProvider);
      final orderNumber = await repository.getNextOrderNumber();
      
      final tableNumber = ref.read(currentTableProvider);
      
      final order = OrderModel(
        id: '',
        tableNumber: 'Table $tableNumber',
        items: items,
        totalAmount: total,
        paymentMethod: mode.name, // online or atRegister
        isPaid: mode == PaymentMode.online,
        status: mode == PaymentMode.online ? 'cooking' : 'waiting_payment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        managerId: 'manager_1',
        orderNumber: orderNumber,
      );

      final orderId = await repository.submitOrder(order);
      
      if (context.mounted) Navigator.pop(context);
      ref.read(cartProvider.notifier).clear();
      
      if (context.mounted) {
        context.push('/order-success', extra: {
          'orderId': orderId,
          'orderNumber': orderNumber,
          'paymentMethod': mode.name,
        });
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }
}
