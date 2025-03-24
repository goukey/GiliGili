import 'package:json_annotation/json_annotation.dart';

// 不再使用自动生成的代码
// part 'quality_item.g.dart';

// 手动实现序列化和反序列化代码
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

  factory QualityItem.fromJson(Map<String, dynamic> json) {
    return QualityItem(
      id: json['id'] as int,
      quality: json['quality'] as String,
      desc: json['desc'] as String,
      needVip: json['needVip'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quality': quality,
      'desc': desc,
      'needVip': needVip,
    };
  }
}

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
  
  factory Accept.fromJson(Map<String, dynamic> json) {
    return Accept(
      quality: json['quality'] as int,
      format: json['format'] as String,
      description: json['description'] as String,
      codecs: json['codecs'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'format': format,
      'description': description,
      'codecs': codecs,
    };
  }
} 