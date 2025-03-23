// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QualityItem _$QualityItemFromJson(Map<String, dynamic> json) => QualityItem(
      id: json['id'] as int,
      quality: json['quality'] as String,
      desc: json['desc'] as String,
      needVip: json['need_vip'] as bool,
    );

Map<String, dynamic> _$QualityItemToJson(QualityItem instance) => <String, dynamic>{
      'id': instance.id,
      'quality': instance.quality,
      'desc': instance.desc,
      'need_vip': instance.needVip,
    };

Accept _$AcceptFromJson(Map<String, dynamic> json) => Accept(
      quality: json['quality'] as int,
      format: json['format'] as String,
      description: json['description'] as String,
      codecs: json['codecs'] as String,
    );

Map<String, dynamic> _$AcceptToJson(Accept instance) => <String, dynamic>{
      'quality': instance.quality,
      'format': instance.format,
      'description': instance.description,
      'codecs': instance.codecs,
    }; 