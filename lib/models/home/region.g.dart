// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
      tid: json['tid'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String,
      goto: json['goto'] as String,
      param: json['param'] as String,
      uri: json['uri'] as String,
    );

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'tid': instance.tid,
      'name': instance.name,
      'logo': instance.logo,
      'goto': instance.goto,
      'param': instance.param,
      'uri': instance.uri,
    }; 