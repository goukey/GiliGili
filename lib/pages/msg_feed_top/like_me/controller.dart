import 'package:GiliGili/common/widgets/pair.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/http/msg.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/models/msg/msgfeed_like_me.dart';

class LikeMeController extends CommonController {
  int cursor = -1;
  int cursorTime = -1;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(Success response) {
    MsgFeedLikeMe data = response.response;
    if (data.total?.cursor?.isEnd == true ||
        data.total?.items.isNullOrEmpty == true) {
      isEnd = true;
    }
    cursor = data.total?.cursor?.id ?? -1;
    cursorTime = data.total?.cursor?.time ?? -1;
    List<LikeMeItems> latest = data.latest?.items ?? [];
    List<LikeMeItems> total = data.total?.items ?? [];
    if (currentPage != 1 && loadingState.value is Success) {
      Pair<List<LikeMeItems>, List<LikeMeItems>> pair =
          (loadingState.value as Success).response;
      latest.insertAll(0, pair.first);
      total.insertAll(0, pair.second);
    }
    loadingState.value =
        LoadingState.success(Pair(first: latest, second: total));
    return true;
  }

  @override
  Future onRefresh() {
    cursor = -1;
    cursorTime = -1;
    return super.onRefresh();
  }

  @override
  Future<LoadingState> customGetData() =>
      MsgHttp.msgFeedLikeMe(cursor: cursor, cursorTime: cursorTime);
}
