import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/bangumi/list.dart';
import 'package:GiliGili/models/common/tab_type.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/http/bangumi.dart';
import 'package:GiliGili/utils/storage.dart';

class BangumiController extends CommonController {
  BangumiController({required this.tabType});
  final TabType tabType;

  RxBool isLogin = false.obs;
  int? mid;

  @override
  void onInit() {
    super.onInit();
    mid = GStorage.userInfo.get('userInfoCache')?.mid;
    isLogin.value = mid != null;

    queryData();
    queryBangumiFollow();
    if (isLogin.value) {
      followController = ScrollController();
    }
  }

  @override
  Future onRefresh() {
    if (isLogin.value) {
      followPage = 1;
      followEnd = false;
    }
    queryBangumiFollow();
    return super.onRefresh();
  }

  late int followPage = 1;
  late RxInt followCount = (-1).obs;
  late bool followLoading = false;
  late bool followEnd = false;
  late Rx<LoadingState> followState = LoadingState.loading().obs;
  ScrollController? followController;

  // 我的订阅
  Future queryBangumiFollow([bool isRefresh = true]) async {
    if (isLogin.value.not || followLoading || (isRefresh.not && followEnd)) {
      return;
    }
    followLoading = true;
    dynamic res = await BangumiHttp.bangumiFollow(
      mid: mid,
      type: tabType == TabType.bangumi ? 1 : 2,
      pn: followPage,
    );
    if (res is Success) {
      BangumiListDataModel data = res.response;
      followPage++;
      followEnd = data.hasNext == 0 || data.list.isNullOrEmpty;
      followCount.value = data.total ?? -1;
      if (isRefresh.not && followState.value is Success) {
        data.list?.insertAll(0, (followState.value as Success).response);
      }
      followState.value = LoadingState.success(data.list);
      if (isRefresh) {
        followController?.animToTop();
      }
    } else {
      followState.value = res;
    }
    followLoading = false;
  }

  @override
  Future<LoadingState> customGetData() => BangumiHttp.bangumiList(
        page: currentPage,
        indexType: tabType == TabType.cinema ? 102 : null, // TODO: sort
      );

  @override
  void onClose() {
    followController?.dispose();
    super.onClose();
  }
}
