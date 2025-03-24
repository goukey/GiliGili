import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/pages/common/common_controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/http/msg.dart';
import 'package:GiliGili/models/msg/msgfeed_at_me.dart';

class AtMeController extends CommonController {
  int cursor = -1;
  int cursorTime = -1;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(Success response) {
    MsgFeedAtMe data = response.response;
    if (data.cursor?.isEnd == true || data.items.isNullOrEmpty) {
      isEnd = true;
    }
    cursor = data.cursor?.id ?? -1;
    cursorTime = data.cursor?.time ?? -1;
    if (currentPage != 1 && loadingState.value is Success) {
      data.items ??= <AtMeItems>[];
      data.items!.insertAll(0, (loadingState.value as Success).response);
    }
    loadingState.value = LoadingState.success(data.items);
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
      MsgHttp.msgFeedAtMe(cursor: cursor, cursorTime: cursorTime);
}
