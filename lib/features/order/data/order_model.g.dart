// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  tableNumber: json['tableNumber'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toInt(),
  paymentMethod: json['paymentMethod'] as String,
  isPaid: json['isPaid'] as bool,
  status: json['status'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  managerId: json['managerId'] as String,
  orderNumber: (json['orderNumber'] as num).toInt(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableNumber': instance.tableNumber,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'isPaid': instance.isPaid,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'managerId': instance.managerId,
      'orderNumber': instance.orderNumber,
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  name: json['name'] as String,
  selectedOptions: (json['selectedOptions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  unitPrice: (json['unitPrice'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'name': instance.name,
  'selectedOptions': instance.selectedOptions,
  'unitPrice': instance.unitPrice,
  'quantity': instance.quantity,
};
