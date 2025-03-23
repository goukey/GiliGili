import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@JsonSerializable()
class Region {
  final int tid;
  final String name;
  final String logo;
  final String goto;
  final String param;
  final String uri;

  Region({
    required this.tid,
    required this.name,
    required this.logo,
    required this.goto,
    required this.param,
    required this.uri,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);
} 