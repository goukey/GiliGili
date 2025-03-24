import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/http/member.dart';
import 'package:GiliGili/pages/common/common_controller.dart';

class MemberLikeController extends CommonController {
  final dynamic mid;
  MemberLikeController({this.mid});

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState> customGetData() =>
      MemberHttp.getRecentLikeVideo(mid: mid);
}
