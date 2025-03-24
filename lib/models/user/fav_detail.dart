import 'package:GiliGili/models/model_owner.dart';
import 'package:GiliGili/models/user/fav_folder.dart';

class FavDetailData {
  FavDetailData({
    this.info,
    this.medias,
    this.hasMore,
  });

  FavFolderItemData? info;
  List<FavDetailItemData>? medias;
  bool? hasMore;

  FavDetailData.fromJson(Map<String, dynamic> json) {
    info =
        json['info'] == null ? null : FavFolderItemData.fromJson(json['info']);
    medias = (json['medias'] as List?)
        ?.map<FavDetailItemData>((e) => FavDetailItemData.fromJson(e))
        .toList();
    hasMore = json['has_more'];
  }
}

class FavDetailItemData {
  FavDetailItemData({
    this.id,
    this.type,
    this.title,
    this.pic,
    this.intro,
    this.page,
    this.duration,
    this.owner,
    this.attr,
    this.cntInfo,
    this.link,
    this.ctime,
    this.pubdate,
    this.favTime,
    this.bvId,
    this.bvid,
    // this.season,
    this.ogv,
    this.stat,
    this.cid,
    this.epId,
    this.checked,
  });

  int? id;
  int? type;
  String? title;
  String? pic;
  String? intro;
  int? page;
  int? duration;
  Owner? owner;
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/fav/list.md
  // | attr     | num  | 失效  | 0: 正常；9: up自己删除；1: 其他原因删除                                                         |
  int? attr;
  Map? cntInfo;
  String? link;
  int? ctime;
  int? pubdate;
  int? favTime;
  String? bvId;
  String? bvid;
  Map? ogv;
  Stat? stat;
  int? cid;
  String? epId;
  bool? checked;

  FavDetailItemData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    pic = json['cover'];
    intro = json['intro'];
    page = json['page'];
    duration = json['duration'];
    owner = Owner.fromJson(json['upper']);
    attr = json['attr'];
    cntInfo = json['cnt_info'];
    link = json['link'];
    ctime = json['ctime'];
    pubdate = json['pubtime'];
    favTime = json['fav_time'];
    bvId = json['bv_id'];
    bvid = json['bvid'];
    ogv = json['ogv'];
    stat = Stat.fromJson(json['cnt_info']);
    cid = json['ugc'] != null ? json['ugc']['first_cid'] : null;
    if (json['link'] != null && json['link'].contains('/bangumi')) {
      epId = resolveEpId(json['link']);
    }
  }

  String resolveEpId(url) {
    RegExp regex = RegExp(r'\d+');
    Iterable<Match> matches = regex.allMatches(url);
    List<String> numbers = [];
    for (Match match in matches) {
      numbers.add(match.group(0)!);
    }
    return numbers[0];
  }
}

class Stat {
  Stat({
    this.view,
    this.danmu,
  });

  int? view;
  int? danmu;

  Stat.fromJson(Map<String, dynamic> json) {
    view = json['play'];
    danmu = json['danmaku'];
  }
}
