import 'package:GiliGili/grpc/app/main/community/reply/v1/reply.pb.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/common/reply_type.dart';
import 'package:GiliGili/models/dynamics/result.dart';
import 'package:GiliGili/pages/common/reply_controller.dart';
import 'package:GiliGili/utils/global_data.dart';
import 'package:GiliGili/utils/id_utils.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:get/get.dart';
import 'package:GiliGili/http/html.dart';
import 'package:GiliGili/http/reply.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

class DynamicDetailController extends ReplyController {
  DynamicDetailController(this.oid, this.type);
  int oid;
  int type;
  late DynamicItemModel item;
  int? floor;

  late final horizontalPreview = GStorage.horizontalPreview;
  late final showDynActionBar = GStorage.showDynActionBar;

  @override
  dynamic get sourceId =>
      type == ReplyType.video.index ? IdUtils.av2bv(oid) : oid;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments['item'];
    floor = Get.arguments['floor'];
    if (floor == 1) {
      count.value = int.parse(item.modules!.moduleStat!.comment!.count ?? '0');
    }

    if (oid != 0) {
      queryData();
    }
  }

  // 根据jumpUrl获取动态html
  reqHtmlByOpusId(int id) async {
    var res = await HtmlHttp.reqHtml(id, 'opus');
    oid = res['commentId'];
    queryData();
  }

  @override
  Future<LoadingState> customGetData() => GlobalData().grpcReply
      ? ReplyHttp.replyListGrpc(
          type: type,
          oid: oid,
          cursor: CursorReq(
            next: cursor?.next ?? $fixnum.Int64(0),
            mode: mode.value,
          ),
          antiGoodsReply: antiGoodsReply,
        )
      : ReplyHttp.replyList(
          isLogin: isLogin,
          oid: oid,
          nextOffset: nextOffset,
          type: type,
          sort: sortType.value.index,
          page: currentPage,
          antiGoodsReply: antiGoodsReply,
        );
}
