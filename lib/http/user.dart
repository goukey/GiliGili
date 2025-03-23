import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/video/later.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../common/constants.dart';
import '../models/model_hot_video_item.dart';
import '../models/user/fav_detail.dart';
import '../models/user/fav_folder.dart';
import '../models/user/history.dart';
import '../models/user/info.dart';
import '../models/user/stat.dart';
import '../models/user/sub_detail.dart';
import '../models/user/sub_folder.dart';
import 'api.dart';
import 'init.dart';

class UserHttp {
  static Future<dynamic> userStat({required int mid}) async {
    var res = await Request().get(Api.userStat, queryParameters: {'vmid': mid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false};
    }
  }

  static Future<dynamic> userInfo() async {
    var res = await Request().get(Api.userInfo);
    if (res.data['code'] == 0) {
      UserInfoData data = UserInfoData.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<dynamic> userStatOwner() async {
    var res = await Request().get(Api.userStatOwner);
    if (res.data['code'] == 0) {
      UserStat data = UserStat.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 收藏夹
  static Future<LoadingState> userfavFolder({
    required int pn,
    required int ps,
    required dynamic mid,
  }) async {
    var res = await Request().get(Api.userFavFolder, queryParameters: {
      'pn': pn,
      'ps': ps,
      'up_mid': mid,
    });
    if (res.data['code'] == 0) {
      return LoadingState.success(FavFolderData.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message'] ?? '账号未登录');
    }
  }

  static Future cleanFav({
    required dynamic mediaId,
  }) async {
    var res = await Request().post(
      Api.cleanFav,
      data: {
        'media_id': mediaId,
        'platform': 'web',
        'csrf': await Request.getCsrf(),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future deleteFolder({
    required List<dynamic> mediaIds,
  }) async {
    var res = await Request().post(Api.deleteFolder,
        data: {
          'media_ids': mediaIds.join(','),
          'platform': 'web',
          'csrf': await Request.getCsrf(),
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future addOrEditFolder({
    required bool isAdd,
    dynamic mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  }) async {
    var res = await Request().post(isAdd ? Api.addFolder : Api.editFolder,
        data: {
          'title': title,
          'intro': intro,
          'privacy': privacy,
          'cover': cover.isNotEmpty ? Uri.encodeFull(cover) : cover,
          'csrf': await Request.getCsrf(),
          if (mediaId != null) 'media_id': mediaId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': FavFolderItemData.fromJson(res.data['data'])
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future folderInfo({
    dynamic mediaId,
  }) async {
    var res = await Request().get(Api.folderInfo, queryParameters: {
      'media_id': mediaId,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future<LoadingState> userFavFolderDetail(
      {required int mediaId,
      required int pn,
      required int ps,
      String keyword = '',
      String order = 'mtime',
      int type = 0}) async {
    var res = await Request().get(Api.userFavFolderDetail, queryParameters: {
      'media_id': mediaId,
      'pn': pn,
      'ps': ps,
      'keyword': keyword,
      'order': order,
      'type': type,
      'tid': 0,
      'platform': 'web'
    });
    if (res.data['code'] == 0) {
      return LoadingState.success(FavDetailData.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  // 稍后再看
  static Future<LoadingState> seeYouLater() async {
    var res = await Request().get(Api.seeYouLater);
    if (res.data['code'] == 0) {
      if (res.data['data']['count'] == 0) {
        return LoadingState.success({
          'list': [],
          'count': 0,
        });
      }
      List<HotVideoItemModel> list = [];
      if (res.data['data']?['list'] != null) {
        for (var i in res.data['data']['list']) {
          list.add(HotVideoItemModel.fromJson(i));
        }
      }
      return LoadingState.success({
        'list': list,
        'count': res.data['data']['count'],
      });
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  // 观看历史
  static Future<LoadingState> historyList({
    int? max,
    int? viewAt,
  }) async {
    var res = await Request().get(Api.historyList, queryParameters: {
      'type': 'all',
      'ps': 20,
      'max': max ?? 0,
      'view_at': viewAt ?? 0,
    });
    if (res.data['code'] == 0) {
      return LoadingState.success(HistoryData.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  // 暂停观看历史
  static Future pauseHistory(bool switchStatus) async {
    // 暂停switchStatus传true 否则false
    var res = await Request().post(
      Api.pauseHistory,
      queryParameters: {
        'switch': switchStatus,
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    return res;
  }

  // 观看历史暂停状态
  static Future historyStatus() async {
    var res = await Request().get(Api.historyStatus);
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 清空历史记录
  static Future clearHistory() async {
    var res = await Request().post(
      Api.clearHistory,
      queryParameters: {
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    return res;
  }

  // 稍后再看
  static Future toViewLater({String? bvid, dynamic aid}) async {
    var data = {'csrf': await Request.getCsrf()};
    if (bvid != null) {
      data['bvid'] = bvid;
    } else if (aid != null) {
      data['aid'] = aid;
    }
    var res = await Request().post(
      Api.toViewLater,
      queryParameters: data,
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': 'yeah！稍后再看'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 移除已观看
  static Future toViewDel({
    List? aids,
  }) async {
    final Map<String, dynamic> params = {
      'jsonp': 'jsonp',
      'csrf': await Request.getCsrf(),
      if (aids != null) 'aid': aids.join(',') else 'viewed': true
    };
    dynamic res = await Request().post(
      Api.toViewDel,
      data: params,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': 'yeah！成功移除'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 获取用户凭证 失效
  static Future thirdLogin() async {
    var res = await Request().get(
      'https://passport.bilibili.com/login/app/third',
      queryParameters: {
        'appkey': Constants.appKey,
        'api': Constants.thirdApi,
        'sign': Constants.thirdSign,
      },
    );
    try {
      if (res.data['code'] == 0 && res.data['data']['has_login'] == 1) {
        Request().get(res.data['data']['confirm_uri']);
      }
    } catch (err) {
      SmartDialog.showNotify(msg: '获取用户凭证: $err', notifyType: NotifyType.error);
    }
  }

  // 清空稍后再看
  static Future toViewClear() async {
    var res = await Request().post(
      Api.toViewClear,
      queryParameters: {
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': '操作完成'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 删除历史记录
  static Future delHistory(List kidList) async {
    var res = await Request().post(
      Api.delHistory,
      data: {
        'kid': kidList.join(','),
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': '已删除'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future hasFollow(int mid) async {
    var res = await Request().get(
      Api.hasFollow,
      queryParameters: {
        'fid': mid,
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }
  // // 相互关系查询
  // static Future relationSearch(int mid) async {
  //   Map params = await WbiSign.makSign({
  //     'mid': mid,
  //     'token': '',
  //     'platform': 'web',
  //     'web_location': 1550101,
  //   });
  //   var res = await Request().get(
  //     Api.relationSearch,
  //     data: {
  //       'mid': mid,
  //       'w_rid': params['w_rid'],
  //       'wts': params['wts'],
  //     },
  //   );
  //   if (res.data['code'] == 0) {
  //     // relation 主动状态
  //     // 被动状态
  //     return {'status': true, 'data': res.data['data']};
  //   } else {
  //     return {'status': false, 'msg': res.data['message']};
  //   }
  // }

  // 搜索历史记录
  static Future<LoadingState> searchHistory(
      {required int pn, required String keyword}) async {
    var res = await Request().get(
      Api.searchHistory,
      queryParameters: {
        'pn': pn,
        'keyword': keyword,
        'business': 'all',
      },
    );
    if (res.data['code'] == 0) {
      return LoadingState.success(HistoryData.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  // 我的订阅
  static Future<LoadingState> userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(
      Api.userSubFolder,
      queryParameters: {
        'up_mid': mid,
        'ps': ps,
        'pn': pn,
        'platform': 'web',
      },
    );
    if (res.data['code'] == 0 && res.data['data'] is Map) {
      return LoadingState.success(
          SubFolderModelData.fromJson(res.data['data']).list);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future favSeasonList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(Api.favSeasonList, queryParameters: {
      'season_id': id,
      'ps': ps,
      'pn': pn,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SubDetailModelData.fromJson(res.data['data'])
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future favResourceList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(Api.favResourceList, queryParameters: {
      'media_id': id,
      'ps': ps,
      'pn': pn,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SubDetailModelData.fromJson(res.data['data'])
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 取消订阅
  static Future cancelSub({required int id, required int type}) async {
    late dynamic res;
    if (type == 11) {
      res = await Request().post(
        Api.unfavFolder,
        queryParameters: {
          'media_id': id,
          'csrf': await Request.getCsrf(),
        },
      );
    } else {
      res = await Request().post(
        Api.unfavSeason,
        queryParameters: {
          'platform': 'web',
          'season_id': id,
          'csrf': await Request.getCsrf(),
        },
      );
    }
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static videoTags({required String bvid}) async {
    var res =
        await Request().get(Api.videoTags, queryParameters: {'bvid': bvid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false};
    }
  }

  // 稍后再看播放全部
  // static Future toViewPlayAll({required int oid, required String bvid}) async {
  //   var res = await Request().get(
  //     Api.watchLaterHtml,
  //     data: {
  //       'oid': oid,
  //       'bvid': bvid,
  //     },
  //   );
  //   String scriptContent =
  //       extractScriptContents(parse(res.data).body!.outerHtml)[0];
  //   int startIndex = scriptContent.indexOf('{');
  //   int endIndex = scriptContent.lastIndexOf('};');
  //   String jsonContent = scriptContent.substring(startIndex, endIndex + 1);
  //   // 解析JSON字符串为Map
  //   Map<String, dynamic> jsonData = json.decode(jsonContent);
  //   // 输出解析后的数据
  //   return {
  //     'status': true,
  //     'data': jsonData['resourceList']
  //         .map((e) => MediaVideoItemModel.fromJson(e))
  //         .toList()
  //   };
  // }
  static List<String> extractScriptContents(String htmlContent) {
    RegExp scriptRegExp = RegExp(r'<script>([\s\S]*?)<\/script>');
    Iterable<Match> matches = scriptRegExp.allMatches(htmlContent);
    List<String> scriptContents = [];
    for (Match match in matches) {
      String scriptContent = match.group(1)!;
      scriptContents.add(scriptContent);
    }
    return scriptContents;
  }

  // 稍后再看列表
  static Future getMediaList({
    required dynamic type,
    required int bizId,
    required int ps,
    dynamic oid,
    int? otype,
    bool withCurrent = false,
    bool desc = true,
    dynamic sortField = 1,
    bool direction = false,
  }) async {
    var res = await Request().get(
      Api.mediaList,
      queryParameters: {
        'mobi_app': 'web',
        'type': type,
        'biz_id': bizId,
        if (oid != null) 'oid': oid,
        if (otype != null) 'otype': otype, // video:2 // bangumi: 24
        'ps': ps,
        'direction': direction,
        'desc': desc,
        'sort_field': sortField,
        'tid': 0,
        'with_current': withCurrent,
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data']['media_list'] != null
            ? res.data['data']['media_list']
                .map<MediaVideoItemModel>(
                    (e) => MediaVideoItemModel.fromJson(e))
                .toList()
            : []
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 解析收藏夹视频
  // static Future parseFavVideo({
  //   required int mediaId,
  //   required int oid,
  //   required String bvid,
  // }) async {
  //   var res = await Request().get(
  //     'https://www.bilibili.com/list/ml$mediaId',
  //     queryParameters: {
  //       'oid': mediaId,
  //       'bvid': bvid,
  //     },
  //   );
  //   String scriptContent =
  //       extractScriptContents(parse(res.data).body!.outerHtml)[0];
  //   int startIndex = scriptContent.indexOf('{');
  //   int endIndex = scriptContent.lastIndexOf('};');
  //   String jsonContent = scriptContent.substring(startIndex, endIndex + 1);
  //   // 解析JSON字符串为Map
  //   Map<String, dynamic> jsonData = json.decode(jsonContent);
  //   return {
  //     'status': true,
  //     'data': jsonData['resourceList']
  //         .map<MediaVideoItemModel>((e) => MediaVideoItemModel.fromJson(e))
  //         .toList()
  //   };
  // }
}
