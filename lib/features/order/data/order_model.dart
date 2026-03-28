import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel {
  final String id;
  final String tableNumber;
  final List<OrderItem> items;
  final int totalAmount;
  final String paymentMethod; // "online" or "at_register"
  final bool isPaid;
  final String status; // "waiting_payment", "cooking", "completed"
  @TimestampConverter()
  final DateTime createdAt;
  @TimestampConverter()
  final DateTime updatedAt;
  final String managerId;
  final int orderNumber;

  OrderModel({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.managerId,
    required this.orderNumber,
  });

  OrderModel copyWith({
    String? id,
    String? tableNumber,
    List<OrderItem>? items,
    int? totalAmount,
    String? paymentMethod,
    bool? isPaid,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? managerId,
    int? orderNumber,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      managerId: managerId ?? this.managerId,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderItem {
  final String name;
  final List<String> selectedOptions;
  final int unitPrice;
  final int quantity;

  OrderItem({
    required this.name,
    required this.selectedOptions,
    required this.unitPrice,
    required this.quantity,
  });

  OrderItem copyWith({
    String? name,
    List<String>? selectedOptions,
    int? unitPrice,
    int? quantity,
  }) {
    return OrderItem(
      name: name ?? this.name,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
