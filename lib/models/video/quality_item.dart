import 'package:json_annotation/json_annotation.dart';

part 'quality_item.g.dart';

@JsonSerializable()
class QualityItem {
  final int id;
  final String quality;
  final String desc;
  final bool needVip;

  QualityItem({
    required this.id,
    required this.quality,
    required this.desc,
    required this.needVip,
  });

  factory QualityItem.fromJson(Map<String, dynamic> json) => _$QualityItemFromJson(json);
  Map<String, dynamic> toJson() => _$QualityItemToJson(this);
}

@JsonSerializable()
class Accept {
  final int quality;
  final String format;
  final String description;
  final String codecs;
  
  Accept({
    required this.quality,
    required this.format,
    required this.description,
    required this.codecs,
  });
  
  factory Accept.fromJson(Map<String, dynamic> json) => _$AcceptFromJson(json);
  Map<String, dynamic> toJson() => _$AcceptToJson(this);
} 