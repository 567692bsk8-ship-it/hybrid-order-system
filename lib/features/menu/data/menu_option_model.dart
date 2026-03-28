import 'package:json_annotation/json_annotation.dart';

part 'menu_option_model.g.dart';

@JsonSerializable()
class MenuOptionModel {
  final String id;
  final String name;
  final int price;
  final String targetCategory;
  final bool isMultiSelect;

  MenuOptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.targetCategory,
    this.isMultiSelect = true,
  });

  MenuOptionModel copyWith({
    String? id,
    String? name,
    int? price,
    String? targetCategory,
    bool? isMultiSelect,
  }) {
    return MenuOptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      targetCategory: targetCategory ?? this.targetCategory,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
    );
  }

  factory MenuOptionModel.fromJson(Map<String, dynamic> json) => _$MenuOptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuOptionModelToJson(this);
}
