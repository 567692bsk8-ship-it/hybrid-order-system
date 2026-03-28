import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuModel {
  final String id;
  final String category;
  final String subCategory;
  final String name;
  final String description;
  final int basePrice;
  final String imageUrl;
  final bool isAvailable;

  MenuModel({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
    this.isAvailable = true,
  });

  MenuModel copyWith({
    String? id,
    String? category,
    String? subCategory,
    String? name,
    String? description,
    int? basePrice,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MenuModel(
      id: id ?? this.id,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) => _$MenuModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuModelToJson(this);
}
