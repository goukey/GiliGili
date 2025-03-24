import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/http/member.dart';
import 'package:GiliGili/pages/common/common_controller.dart';

class MemberCoinController extends CommonController {
  final dynamic mid;
  MemberCoinController({this.mid});

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState> customGetData() =>
      MemberHttp.getRecentCoinVideo(mid: mid);
}
