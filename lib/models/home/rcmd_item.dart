import 'package:json_annotation/json_annotation.dart';

part 'rcmd_item.g.dart';

@JsonSerializable()
class RcmdItem {
  final int id;
  final String bvid;
  final String title;
  final String pic;
  final int duration;
  final Owner owner;
  final Stat stat;
  final RcmdReason rcmdReason;

  RcmdItem({
    required this.id,
    required this.bvid,
    required this.title,
    required this.pic,
    required this.duration,
    required this.owner,
    required this.stat,
    required this.rcmdReason,
  });

  factory RcmdItem.fromJson(Map<String, dynamic> json) => _$RcmdItemFromJson(json);
  Map<String, dynamic> toJson() => _$RcmdItemToJson(this);
}

@JsonSerializable()
class Owner {
  final int mid;
  final String name;

  Owner({
    required this.mid,
    required this.name,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

@JsonSerializable()
class Stat {
  final int view;
  final int danmaku;

  Stat({
    required this.view,
    required this.danmaku,
  });

  factory Stat.fromJson(Map<String, dynamic> json) => _$StatFromJson(json);
  Map<String, dynamic> toJson() => _$StatToJson(this);
}

@JsonSerializable()
class RcmdReason {
  final String? content;

  RcmdReason({
    this.content,
  });

  factory RcmdReason.fromJson(Map<String, dynamic> json) => _$RcmdReasonFromJson(json);
  Map<String, dynamic> toJson() => _$RcmdReasonToJson(this);
} 