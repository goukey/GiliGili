import 'dart:async';
import 'package:GiliGili/http/video.dart';
import 'package:GiliGili/models/video/play/quality.dart';
import 'package:GiliGili/models/video/play/url.dart';
import 'package:GiliGili/models/video/quality_item.dart';
import 'package:GiliGili/models/video_detail_res.dart';
import 'package:GiliGili/plugin/pl_player/index.dart';
import 'package:GiliGili/utils/feed_back.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:GiliGili/utils/tv_focus_utils.dart';
import 'package:GiliGili/utils/video_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class TvPlayerController extends GetxController {
  late String _bvid;
  late int _cid;
  int? _epid;
  int? _seasonId;
  int currentPartIndex = 0;
  List<VideoDetailResPart> parts = [];
  
  // 是否自动全屏和自动播放下一分P
  final bool autoFullScreen;
  final bool autoPlayNext;
  final bool exitWhenAllFinished;
  
  final Rx<bool> isLoading = true.obs;
  final Rx<bool> isError = false.obs;
  final Rx<String> errorMsg = ''.obs;
  
  // 视频详情
  Rx<VideoDetailResModel?> videoDetail = Rx(null);
  
  // 播放相关
  late PlPlayerController playerController;
  
  // 视频相关数据
  List<QualityItem> qualityItems = [];
  final Rx<QualityItem> currentQuality = QualityItem(id: 0, quality: '自动', desc: '自动', needVip: false).obs;
  
  // 控制相关
  final Rx<bool> showControls = false.obs;
  Timer? controlsTimer;
  
  // 在构造函数中接收额外参数
  TvPlayerController({
    required this.autoFullScreen,
    required this.autoPlayNext,
    required this.exitWhenAllFinished,
  });
  
  @override
  void onInit() {
    super.onInit();
    
    final Map<String, dynamic> arguments = Get.arguments;
    _bvid = arguments['bvid'];
    _cid = arguments['cid'];
    _epid = arguments['epid'];
    _seasonId = arguments['seasonId'];
    
    // 获取视频详情
    _fetchVideoDetail();
    
    // 初始化播放器控制器
    playerController = PlPlayerController.getInstance();
    
    // 添加视频结束的监听器
    playerController.addStatusListener(_handleVideoComplete);
    
    // 如果需要自动全屏，设置全屏状态
    if (autoFullScreen) {
      Future.delayed(const Duration(milliseconds: 500), () {
        playerController.triggerFullScreen(status: true);
      });
    }
  }
  
  @override
  void onClose() {
    // 移除视频结束的监听器
    playerController.removeStatusListener(_handleVideoComplete);
    playerController.reset();
    super.onClose();
  }
  
  // 处理视频播放完成
  void _handleVideoComplete(PlayerStatus status) {
    if (status == PlayerStatus.completed) {
      if (autoPlayNext && currentPartIndex < parts.length - 1) {
        // 如果自动播放下一分P且还有下一分P，切换到下一分P
        switchPart(currentPartIndex + 1);
      } else if (exitWhenAllFinished && currentPartIndex >= parts.length - 1) {
        // 如果所有分P都播放完毕且设置了播放完毕退出，返回上一页
        Get.back();
      }
    }
  }
  
  // 获取视频详情
  Future<void> _fetchVideoDetail() async {
    isLoading.value = true;
    isError.value = false;
    
    try {
      VideoApi videoApi = VideoApi();
      final result = await videoApi.getVideoDetail(_bvid);
      
      if (result != null) {
        videoDetail.value = result;
        parts = result.pages;
        currentPartIndex = parts.indexWhere((part) => part.cid == _cid);
        if (currentPartIndex < 0) currentPartIndex = 0;
        
        // 开始加载视频播放URL
        _loadPlayUrl();
      } else {
        isError.value = true;
        errorMsg.value = '获取视频详情失败';
      }
    } catch (e) {
      isError.value = true;
      errorMsg.value = '获取视频详情错误: $e';
    }
  }
  
  // 加载视频播放URL
  Future<void> _loadPlayUrl() async {
    try {
      VideoApi videoApi = VideoApi();
      final current = parts[currentPartIndex];
      
      // 获取播放URL
      final UrlNoModel? urlModel = await videoApi.getUrl(_bvid, current.cid ?? 0);
      
      if (urlModel != null) {
        // 保存可用清晰度列表
        qualityItems = urlModel.accept.map((item) {
          // 明确强制转为Accept类型
          Accept accept = item as Accept;
          return QualityItem(
            id: accept.quality,
            quality: VideoUtils.getQualityMap()[accept.quality.toString()] ?? '未知',
            desc: VideoUtils.getQualityMap()[accept.quality.toString()] ?? '未知',
            needVip: false,
          );
        }).toList();
        
        // 设置默认清晰度
        int qualityId = GStorage.setting.get(SettingBoxKey.defaultQn, defaultValue: 64);
        final hasQuality = qualityItems.any((item) => item.id == qualityId);
        
        if (!hasQuality && qualityItems.isNotEmpty) {
          qualityId = qualityItems.first.id;
        }
        
        // 更新当前清晰度
        if (qualityItems.isNotEmpty) {
          currentQuality.value = qualityItems.firstWhere(
            (item) => item.id == qualityId,
            orElse: () => qualityItems.first
          );
        }
        
        // 构建播放数据源
        final dataSource = DataSource(
          type: DataSourceType.network,
          url: urlModel.accept.first.format,
          cid: current.cid ?? 0,
          quality: qualityId,
          videoTitle: videoDetail.value?.data?.title ?? '',
          title: current.part ?? '',
          type2: _epid != null ? 'pgc' : 'ugc',
          epId: _epid?.toString(),
          seasonId: _seasonId?.toString(),
        );
        
        // 播放视频
        playerController.setInitialVolume(GStorage.setting.get(SettingBoxKey.defaultVolume, defaultValue: 1.0));
        playerController.setShowControls(true);
        
        // 延迟隐藏控制栏
        _scheduleHideControls();
        
        await playerController.playVideo(source: dataSource, autoPlay: true);
        
        isLoading.value = false;
      } else {
        isError.value = true;
        errorMsg.value = '获取视频播放地址失败';
      }
    } catch (e) {
      isError.value = true;
      errorMsg.value = '加载视频失败: $e';
    }
  }
  
  // 切换分P
  void switchPart(int index) {
    if (index < 0 || index >= parts.length || index == currentPartIndex) return;
    
    currentPartIndex = index;
    _cid = parts[index].cid ?? 0;
    _loadPlayUrl();
  }
  
  // 显示控制栏
  void showControlsPanel() {
    showControls.value = true;
    _scheduleHideControls();
  }
  
  // 隐藏控制栏
  void hideControlsPanel() {
    showControls.value = false;
    if (controlsTimer != null) {
      controlsTimer!.cancel();
      controlsTimer = null;
    }
  }
  
  // 延迟隐藏控制栏
  void _scheduleHideControls() {
    if (controlsTimer != null) {
      controlsTimer!.cancel();
    }
    
    controlsTimer = Timer(const Duration(seconds: 5), () {
      showControls.value = false;
      controlsTimer = null;
    });
  }
  
  // 切换播放/暂停
  void togglePlay() {
    if (playerController.videoPlayerController != null) {
      if (playerController.playerStatus.isPlaying) {
        playerController.videoPlayerController?.pause();
      } else {
        playerController.videoPlayerController?.play();
      }
    }
  }
  
  // 跳转到指定位置
  void seekTo(Duration position) {
    playerController.videoPlayerController?.seek(position);
  }
  
  // 快进
  void fastForward() {
    if (playerController.videoPlayerController != null) {
      final currentPosition = playerController.position.value;
      final seekPosition = currentPosition + const Duration(seconds: 10);
      playerController.videoPlayerController?.seek(seekPosition);
    }
  }
  
  // 快退
  void rewind() {
    if (playerController.videoPlayerController != null) {
      final currentPosition = playerController.position.value;
      final seekPosition = currentPosition - const Duration(seconds: 10);
      playerController.videoPlayerController?.seek(seekPosition);
    }
  }
}

class TvPlayerPage extends GetView<TvPlayerController> {
  const TvPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置沉浸式全屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return WillPopScope(
      onWillPop: () async {
        // 退出页面时恢复系统UI
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.isLoading.value) {
            // 加载中
            return const Center(child: CircularProgressIndicator());
          } else if (controller.isError.value) {
            // 加载错误
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMsg.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => controller._fetchVideoDetail(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          } else {
            // 播放器内容
            return Column(
              children: [
                Expanded(
                  child: PLVideoPlayer(
                    plPlayerController: controller.playerController,
                    customWidgets: [
                      _buildPartsList(),
                      _buildQualitySelectionList(),
                    ],
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  // 构建分P列表
  Widget _buildPartsList() {
    return Obx(() {
      return Positioned(
        left: 20,
        top: 70,
        child: Visibility(
          visible: controller.showControls.value,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '分P列表',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: controller.parts.length,
                    itemBuilder: (context, index) {
                      final part = controller.parts[index];
                      final isSelected = index == controller.currentPartIndex;
                      
                      return TvFocusable(
                        focusNode: FocusNode(),
                        onTap: () => controller.switchPart(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}: ${part.part}',
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 构建清晰度选择列表
  Widget _buildQualitySelectionList() {
    return Obx(() {
      return Positioned(
        right: 20,
        top: 70,
        child: Visibility(
          visible: controller.showControls.value,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '清晰度',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: controller.qualityItems.length,
                    itemBuilder: (context, index) {
                      final quality = controller.qualityItems[index];
                      final isSelected = quality.id == controller.currentQuality.value.id;
                      
                      return TvFocusable(
                        focusNode: FocusNode(),
                        onTap: () {
                          // 切换清晰度
                          // TODO: 实现清晰度切换功能
                          SmartDialog.showToast('切换清晰度功能尚未实现');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            quality.quality,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
} 