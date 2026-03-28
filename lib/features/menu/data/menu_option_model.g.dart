// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuOptionModel _$MenuOptionModelFromJson(Map<String, dynamic> json) =>
    MenuOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      targetCategory: json['targetCategory'] as String,
      isMultiSelect: json['isMultiSelect'] as bool? ?? true,
    );

Map<String, dynamic> _$MenuOptionModelToJson(MenuOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'targetCategory': instance.targetCategory,
      'isMultiSelect': instance.isMultiSelect,
    };
