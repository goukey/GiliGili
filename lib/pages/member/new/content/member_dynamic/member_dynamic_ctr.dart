import 'package:GiliGili/grpc/app/dynamic/v2/dynamic.pb.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/http/member.dart';
import 'package:GiliGili/pages/common/common_controller.dart';

class MemberDynamicCtr extends CommonController {
  MemberDynamicCtr({
    required this.mid,
  });
  int mid;

  @override
  bool customHandleResponse(Success response) {
    DynSpaceRsp res = response.response;
    isEnd = !res.hasMore;
    if (currentPage != 1 && loadingState.value is Success) {
      res.list.insertAll(0, (loadingState.value as Success).response);
    }
    loadingState.value = LoadingState.success(res.list);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => MemberHttp.spaceDynamic(
        mid: mid,
        page: currentPage,
      );
}
