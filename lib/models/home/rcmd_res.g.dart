// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rcmd_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RcmdRes _$RcmdResFromJson(Map<String, dynamic> json) => RcmdRes(
      item: (json['item'] as List<dynamic>)
          .map((e) => RcmdItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$RcmdResToJson(RcmdRes instance) => <String, dynamic>{
      'item': instance.item,
      'has_more': instance.hasMore,
    }; 