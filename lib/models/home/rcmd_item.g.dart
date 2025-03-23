// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rcmd_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RcmdItem _$RcmdItemFromJson(Map<String, dynamic> json) => RcmdItem(
      id: json['id'] as int,
      bvid: json['bvid'] as String,
      title: json['title'] as String,
      pic: json['pic'] as String,
      duration: json['duration'] as int,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
      stat: Stat.fromJson(json['stat'] as Map<String, dynamic>),
      rcmdReason: RcmdReason.fromJson(json['rcmd_reason'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RcmdItemToJson(RcmdItem instance) => <String, dynamic>{
      'id': instance.id,
      'bvid': instance.bvid,
      'title': instance.title,
      'pic': instance.pic,
      'duration': instance.duration,
      'owner': instance.owner,
      'stat': instance.stat,
      'rcmd_reason': instance.rcmdReason,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      mid: json['mid'] as int,
      name: json['name'] as String,
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'mid': instance.mid,
      'name': instance.name,
    };

Stat _$StatFromJson(Map<String, dynamic> json) => Stat(
      view: json['view'] as int,
      danmaku: json['danmaku'] as int,
    );

Map<String, dynamic> _$StatToJson(Stat instance) => <String, dynamic>{
      'view': instance.view,
      'danmaku': instance.danmaku,
    };

RcmdReason _$RcmdReasonFromJson(Map<String, dynamic> json) => RcmdReason(
      content: json['content'] as String?,
    );

Map<String, dynamic> _$RcmdReasonToJson(RcmdReason instance) => <String, dynamic>{
      'content': instance.content,
    }; 