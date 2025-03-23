import 'dart:async';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/video/play/quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/models/video_detail_res.dart';
import 'package:PiliPlus/plugin/pl_player/index.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/tv_focus_utils.dart';
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
      final UrlNoModel? urlModel = await videoApi.getUrl(_bvid, current.cid);
      
      if (urlModel != null) {
        // 保存可用清晰度列表
        qualityItems = urlModel.accept.map((item) => QualityItem(
          id: item.quality,
          quality: VideoUtils.getQualityMap()[item.quality.toString()] ?? '未知',
          desc: VideoUtils.getQualityMap()[item.quality.toString()] ?? '未知',
          needVip: false,
        )).toList();
        
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
          bvid: _bvid,
          cid: current.cid,
          quality: qualityId,
          videoTitle: videoDetail.value?.title ?? '',
          title: current.title,
          url: urlModel.durl.first.url,
          type: _epid != null ? 'pgc' : 'ugc',
          epId: _epid,
          seasonId: _seasonId,
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
    _cid = parts[index].cid;
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

class TvPlayerPage extends StatelessWidget {
  const TvPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 从Get.arguments中获取额外参数
    final Map<String, dynamic> arguments = Get.arguments;
    final bool autoFullScreen = arguments['autoFullScreen'] ?? false;
    final bool autoPlayNext = arguments['autoPlayNext'] ?? true;
    final bool exitWhenAllFinished = arguments['exitWhenAllFinished'] ?? true;
    
    // 创建控制器并传入参数
    final controller = Get.put(TvPlayerController(
      autoFullScreen: autoFullScreen,
      autoPlayNext: autoPlayNext,
      exitWhenAllFinished: exitWhenAllFinished,
    ));
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          if (controller.showControls.value) {
            controller.hideControlsPanel();
            return false;
          }
          return true;
        },
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              // 处理遥控器按键
              if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                if (controller.showControls.value) {
                  controller.hideControlsPanel();
                } else {
                  controller.showControlsPanel();
                }
              } else if (event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
                controller.togglePlay();
                controller.showControlsPanel();
              } else if (event.logicalKey == LogicalKeyboardKey.mediaFastForward ||
                         event.logicalKey == LogicalKeyboardKey.arrowRight) {
                controller.fastForward();
                controller.showControlsPanel();
              } else if (event.logicalKey == LogicalKeyboardKey.mediaRewind ||
                         event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                controller.rewind();
                controller.showControlsPanel();
              } else if (event.logicalKey == LogicalKeyboardKey.escape ||
                         event.logicalKey == LogicalKeyboardKey.goBack) {
                if (controller.showControls.value) {
                  controller.hideControlsPanel();
                } else {
                  Get.back();
                }
              }
            }
          },
          child: Stack(
            children: [
              // 视频播放器
              Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: PlVideo(
                        controller: controller.playerController,
                        looping: false,
                        autoPlay: true,
                        freeControls: true,
                      ),
                    ),
                  )
              ),
              
              // 错误提示
              Obx(() => controller.isError.value
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMsg.value,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TvFocusable(
                          autoFocus: true,
                          onTap: () => controller._fetchVideoDetail(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '重试',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()
              ),
              
              // 控制面板
              Obx(() => controller.showControls.value
                ? _buildControlPanel(context, controller)
                : const SizedBox.shrink()
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlPanel(BuildContext context, TvPlayerController controller) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 顶部控制栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                TvFocusable(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    controller.videoDetail.value?.title ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // 中间控制部分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TvFocusable(
                onTap: () => controller.rewind(),
                child: const Icon(Icons.replay_10, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 32),
              Obx(() => TvFocusable(
                autoFocus: true,
                onTap: () => controller.togglePlay(),
                child: Icon(
                  controller.playerController.playerStatus.isPlaying 
                    ? Icons.pause 
                    : Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              )),
              const SizedBox(width: 32),
              TvFocusable(
                onTap: () => controller.fastForward(),
                child: const Icon(Icons.forward_10, color: Colors.white, size: 40),
              ),
            ],
          ),
          
          // 底部进度条
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(() {
                  // 获取播放进度和总时长
                  final position = controller.playerController.position.value;
                  final duration = controller.playerController.duration.value;
                  
                  return Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: position.inSeconds.toDouble(),
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              final newPosition = Duration(seconds: value.toInt());
                              controller.seekTo(newPosition);
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                }),
                
                const SizedBox(height: 16),
                
                // 分P选择
                if (controller.parts.length > 1)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.parts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TvFocusable(
                            onTap: () => controller.switchPart(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: controller.currentPartIndex == index 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "P${index + 1}: ${controller.parts[index].title}",
                                style: const TextStyle(color: Colors.white),
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
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
} 