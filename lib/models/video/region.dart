import 'package:json_annotation/json_annotation.dart';

class Region {
  final int tid;
  final String name;
  final List<Region> children;

  Region({
    required this.tid,
    required this.name,
    required this.children,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      tid: json['tid'] as int,
      name: json['name'] as String,
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((e) => Region.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tid': tid,
      'name': name,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

class RegionResponse {
  final int code;
  final String message;
  final RegionData data;

  RegionResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory RegionResponse.fromJson(Map<String, dynamic> json) {
    return RegionResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: RegionData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class RegionData {
  final List<RegionVideoItem> archives;
  final int page;
  final bool noMore;

  RegionData({
    required this.archives,
    required this.page,
    required this.noMore,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      archives: (json['archives'] as List<dynamic>)
          .map((e) => RegionVideoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page']['num'] as int,
      noMore: json['page']['is_end'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'archives': archives.map((e) => e.toJson()).toList(),
      'page': {
        'num': page,
        'is_end': noMore,
      },
    };
  }
}

class RegionVideoItem {
  final String title;
  final String pic;
  final int duration;
  final String bvid;
  final Map<String, dynamic> owner;
  final Map<String, dynamic> stat;

  RegionVideoItem({
    required this.title,
    required this.pic,
    required this.duration,
    required this.bvid,
    required this.owner,
    required this.stat,
  });

  factory RegionVideoItem.fromJson(Map<String, dynamic> json) {
    return RegionVideoItem(
      title: json['title'] as String,
      pic: json['pic'] as String,
      duration: json['duration'] as int,
      bvid: json['bvid'] as String,
      owner: json['owner'] as Map<String, dynamic>,
      stat: json['stat'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pic': pic,
      'duration': duration,
      'bvid': bvid,
      'owner': owner,
      'stat': stat,
    };
  }
} 