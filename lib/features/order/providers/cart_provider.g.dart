// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartHash() => r'0c6e2cf99d48561381947d76457da1095386fa49';

/// See also [Cart].
@ProviderFor(Cart)
final cartProvider = NotifierProvider<Cart, List<OrderItem>>.internal(
  Cart.new,
  name: r'cartProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Cart = Notifier<List<OrderItem>>;
String _$paymentModeNotifierHash() =>
    r'36158696f3b0dc8748607c6a8da4d041ee94eb99';

/// See also [PaymentModeNotifier].
@ProviderFor(PaymentModeNotifier)
final paymentModeNotifierProvider =
    NotifierProvider<PaymentModeNotifier, PaymentMode>.internal(
      PaymentModeNotifier.new,
      name: r'paymentModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PaymentModeNotifier = Notifier<PaymentMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
