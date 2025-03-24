import 'package:GiliGili/grpc/app/main/community/reply/v1/reply.pb.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/common/reply_type.dart';
import 'package:GiliGili/pages/common/reply_controller.dart';
import 'package:GiliGili/http/reply.dart';
import 'package:GiliGili/utils/global_data.dart';
import 'package:GiliGili/utils/id_utils.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_ticket_provider_mixin.dart';

class VideoReplyController extends ReplyController
    with GetTickerProviderStateMixin {
  VideoReplyController({required this.aid});
  // 视频aid 请求时使用的oid
  int aid;

  @override
  dynamic get sourceId => IdUtils.av2bv(aid);

  bool _isFabVisible = true;
  late final AnimationController fabAnimationCtr = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100))
    ..forward();

  void showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      fabAnimationCtr.forward();
    }
  }

  void hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      fabAnimationCtr.reverse();
    }
  }

  @override
  Future<LoadingState> customGetData() => GlobalData().grpcReply
      ? ReplyHttp.replyListGrpc(
          oid: aid,
          cursor: CursorReq(
            next: cursor?.next ?? $fixnum.Int64(0),
            mode: mode.value,
          ),
          antiGoodsReply: antiGoodsReply,
        )
      : ReplyHttp.replyList(
          isLogin: isLogin,
          oid: aid,
          nextOffset: nextOffset,
          type: ReplyType.video.index,
          sort: sortType.value.index,
          page: currentPage,
          antiGoodsReply: antiGoodsReply,
        );

  @override
  void onClose() {
    fabAnimationCtr.dispose();
    super.onClose();
  }
}
