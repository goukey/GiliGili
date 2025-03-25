import 'package:json_annotation/json_annotation.dart';

class RcmdResponse {
  final int code;
  final String message;
  final RcmdData data;
  
  // 添加快捷访问item的getter
  List<RcmdItem> get item => data.items;

  RcmdResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory RcmdResponse.fromJson(Map<String, dynamic> json) {
    return RcmdResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: RcmdData.fromJson(json['data'] as Map<String, dynamic>),
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

class RcmdData {
  final List<RcmdItem> items;

  RcmdData({
    required this.items,
  });

  factory RcmdData.fromJson(Map<String, dynamic> json) {
    return RcmdData(
      items: (json['item'] as List<dynamic>)
          .map((e) => RcmdItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': items.map((e) => e.toJson()).toList(),
    };
  }
}

class RcmdItem {
  final String title;
  final String uri;
  final String pic;
  final Map<String, dynamic> owner;
  final Map<String, dynamic> stat;
  final int duration;
  final String bvid;

  RcmdItem({
    required this.title,
    required this.uri,
    required this.pic,
    required this.owner,
    required this.stat,
    required this.duration,
    required this.bvid,
  });

  factory RcmdItem.fromJson(Map<String, dynamic> json) {
    return RcmdItem(
      title: json['title'] as String,
      uri: json['uri'] as String,
      pic: json['pic'] as String,
      owner: json['owner'] as Map<String, dynamic>,
      stat: json['stat'] as Map<String, dynamic>,
      duration: json['duration'] as int,
      bvid: json['bvid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'uri': uri,
      'pic': pic,
      'owner': owner,
      'stat': stat,
      'duration': duration,
      'bvid': bvid,
    };
  }
} 