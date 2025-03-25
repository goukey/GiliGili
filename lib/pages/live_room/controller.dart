import 'dart:convert';

import 'package:GiliGili/models/live/danmu_info.dart';
import 'package:GiliGili/models/live/quality.dart';
import 'package:GiliGili/tcp/live.dart';
import 'package:GiliGili/utils/danmaku.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:GiliGili/http/constants.dart';
import 'package:GiliGili/http/live.dart';
import 'package:GiliGili/models/live/room_info.dart';
import 'package:GiliGili/plugin/pl_player/index.dart';
import '../../models/live/room_info_h5.dart';
import '../../utils/video_utils.dart';

class LiveRoomController extends GetxController {
  late int roomId;
  dynamic liveItem;
  double volume = 0.0;
  // 静音状态
  RxBool volumeOff = false.obs;
  PlPlayerController plPlayerController =
      PlPlayerController.getInstance(videoType: 'live');
  Rx<RoomInfoH5Model> roomInfoH5 = RoomInfoH5Model().obs;

  RxList<dynamic> messages = [].obs;
  RxBool disableAutoScroll = false.obs;
  double? brightness;
  DanmakuController? controller;
  bool showDanmaku = true;

  late int currentQn = 10000;
  late List<Map> acceptQnList = <Map>[];
  RxString currentQnDesc = ''.obs;

  @override
  void onInit() {
    super.onInit();
    roomId = int.parse(Get.parameters['roomid']!);
  }

  playerInit(source) async {
    await plPlayerController.setDataSource(
      DataSource(
        type: DataSourceType.network,
        url: source,
        videoSource: source,
        httpHeaders: {'referer': 'https://live.bilibili.com/h5'},
      ),
      // 硬解
      enableHA: true,
      autoplay: true,
      direction: isPortrait.value ? 'vertical' : 'horizontal',
    );
  }

  final RxBool isPortrait = false.obs;

  Future queryLiveInfo() async {
    var res = await LiveHttp.liveRoomInfo(roomId: roomId, qn: currentQn);
    if (res['status']) {
      isPortrait.value = res['data'].isPortrait ?? false;
      List<CodecItem> codec =
          res['data'].playurlInfo.playurl.stream.first.format.first.codec;
      CodecItem item = codec.first;
      // 以服务端返回的码率为准
      currentQn = item.currentQn!;
      List acceptQn = item.acceptQn!;
      acceptQnList = acceptQn.map((e) {
        return {
          'code': e,
          'desc': LiveQuality.values
              .firstWhere((element) => element.code == e)
              .description,
        };
      }).toList();
      currentQnDesc.value = LiveQuality.values
          .firstWhere((element) => element.code == currentQn)
          .description;
      String videoUrl = VideoUtils.getCdnUrl(item);
      await playerInit(videoUrl);
      return res;
    }
  }

  void setVolume(value) {
    if (value == 0) {
      // 设置音量
      volumeOff.value = false;
    } else {
      // 取消音量
      volume = value;
      volumeOff.value = true;
    }
  }

  Future queryLiveInfoH5() async {
    var res = await LiveHttp.liveRoomInfoH5(roomId: roomId);
    if (res['status']) {
      roomInfoH5.value = res['data'];
    }
    return res;
  }

  LiveMessageStream? msgStream;
  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    if (disableAutoScroll.value) return;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
      );
    }
  }

  void liveMsg() {
    LiveHttp.liveRoomDanmaPrefetch(roomId: roomId).then((v) {
      if (v['status']) {
        messages.addAll((v['data'] as List)
            .map((obj) => {
                  'name': obj['user']['base']['name'],
                  'uid': obj['user']['uid'],
                  'text': obj['text'],
                  'emots': obj['emots'],
                  'uemote': obj['emoticon']['emoticon_unique'] != ""
                      ? obj['emoticon']
                      : null,
                })
            .toList());
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => scrollToBottom(),
        );
      }
    });
    LiveHttp.liveRoomGetDanmakuToken(roomId: roomId).then((v) {
      if (v['status']) {
        LiveDanmakuInfo info = v['data'];
        // logger.d("info => $info");
        List<String> servers = [];
        for (final host in info.data.hostList) {
          servers.add('wss://${host.host}:${host.wssPort}/sub');
        }
        msgStream = LiveMessageStream(
          streamToken: info.data.token,
          roomId: roomId,
          uid: GStorage.userInfo.get('userInfoCache')?.mid ?? 0,
          servers: servers,
        );
        msgStream?.addEventListener((obj) {
          if (obj['cmd'] == 'DANMU_MSG') {
            // logger.i(' 原始弹幕消息 ======> ${jsonEncode(obj)}');
            messages.add({
              'name': obj['info'][0][15]['user']['base']['name'],
              'uid': obj['info'][0][15]['user']['uid'],
              'text': obj['info'][1],
              'emots': jsonDecode(obj['info'][0][15]['extra'])['emots'],
              'uemote': obj['info'][0][13],
            });
            Map json = jsonDecode(obj['info'][0][15]['extra']);
            if (showDanmaku) {
              controller?.addDanmaku(
                DanmakuContentItem(
                  json['content'],
                  color: DmUtils.decimalToColor(json['color']),
                  type: DmUtils.getPosition(json['mode']),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => scrollToBottom(),
              );
            }
          }
        });
        msgStream?.init();
        scrollController.addListener(listener);
      }
    });
  }

  void listener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      disableAutoScroll.value = true;
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      final pos = scrollController.position;
      if (pos.maxScrollExtent - pos.pixels <= 100) {
        disableAutoScroll.value = false;
      }
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(listener);
    scrollController.dispose();
    super.onClose();
  }

  // 修改画质
  void changeQn(int qn) async {
    if (currentQn == qn) {
      return;
    }
    currentQn = qn;
    currentQnDesc.value = LiveQuality.values
        .firstWhere((element) => element.code == currentQn)
        .description;
    await queryLiveInfo();
  }
}
