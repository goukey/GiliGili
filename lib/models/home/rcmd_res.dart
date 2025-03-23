import 'package:PiliPlus/models/home/rcmd_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rcmd_res.g.dart';

@JsonSerializable()
class RcmdRes {
  final List<RcmdItem> item;
  final bool hasMore;

  RcmdRes({
    required this.item,
    required this.hasMore,
  });

  factory RcmdRes.fromJson(Map<String, dynamic> json) => _$RcmdResFromJson(json);
  Map<String, dynamic> toJson() => _$RcmdResToJson(this);
} 