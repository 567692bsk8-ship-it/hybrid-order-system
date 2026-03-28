import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/order_model.dart';

part 'cart_provider.g.dart';

enum PaymentMode {
  online, // 事前決済
  atRegister, // レジ精算
}

@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<OrderItem> build() => [];

  void addItem(OrderItem item) {
    state = [...state, item];
  }
 
  void removeItem(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  void updateItem(int index, OrderItem newItem) {
    final newState = [...state];
    newState[index] = newItem;
    state = newState;
  }
 
  void clear() => state = [];
 
  int get totalAmount =>
      state.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
}
 
@Riverpod(keepAlive: true)
class PaymentModeNotifier extends _$PaymentModeNotifier {
  @override
  PaymentMode build() => PaymentMode.online; // デフォルトは事前決済
 
  void setMode(PaymentMode mode) => state = mode;
}
