// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuModel _$MenuModelFromJson(Map<String, dynamic> json) => MenuModel(
  id: json['id'] as String,
  category: json['category'] as String,
  subCategory: json['subCategory'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  basePrice: (json['basePrice'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  isAvailable: json['isAvailable'] as bool? ?? true,
);

Map<String, dynamic> _$MenuModelToJson(MenuModel instance) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'subCategory': instance.subCategory,
  'name': instance.name,
  'description': instance.description,
  'basePrice': instance.basePrice,
  'imageUrl': instance.imageUrl,
  'isAvailable': instance.isAvailable,
};
