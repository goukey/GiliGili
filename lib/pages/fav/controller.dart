import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/user/fav_folder.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/http/user.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/storage.dart';

class FavController extends CommonController {
  late final dynamic mid = GStorage.userInfo.get('userInfoCache')?.mid;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future queryData([bool isRefresh = true]) {
    if (mid == null) {
      loadingState.value = LoadingState.error('账号未登录');
      return Future.value();
    }
    return super.queryData(isRefresh);
  }

  @override
  bool customHandleResponse(Success response) {
    if (response.response.hasMore == false ||
        (response.response.list as List?).isNullOrEmpty) {
      isEnd = true;
    }
    if (currentPage != 1 && loadingState.value is Success) {
      response.response.list ??= <FavFolderItemData>[];
      response.response.list!
          .insertAll(0, (loadingState.value as Success).response);
    }
    loadingState.value = LoadingState.success(response.response.list);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => UserHttp.userfavFolder(
        pn: currentPage,
        ps: 10,
        mid: mid,
      );
}
