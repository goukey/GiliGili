import 'package:GiliGili/http/video.dart';
import 'package:GiliGili/models/home/rcmd_item.dart';
import 'package:GiliGili/models/home/rcmd_res.dart';
import 'package:GiliGili/models/home/region.dart';
import 'package:GiliGili/models/video/rcmd_response.dart' as video_rcmd;
import 'package:GiliGili/models/video/region.dart' as video_region;
import 'package:GiliGili/router/app_pages.dart';
import 'package:GiliGili/utils/feed_back.dart';
import 'package:GiliGili/utils/tv_focus_utils.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TvHomeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final Rx<bool> isLoading = true.obs;
  final Rx<bool> isLoadingMore = false.obs;
  final Rx<bool> hasMore = true.obs;
  final Rx<bool> isError = false.obs;
  final RxList<RcmdItem> videoList = <RcmdItem>[].obs;
  
  // 分区数据
  final RxList<Region> regionList = <Region>[].obs;
  final Rx<int> selectedRegionIndex = 0.obs;
  
  // 焦点控制
  final FocusNode searchFocusNode = FocusNode();
  
  @override
  void onInit() {
    super.onInit();
    _fetchRecommendVideos();
    _fetchRegionList();
  }
  
  @override
  void onClose() {
    scrollController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
  
  // 获取推荐视频
  Future<void> _fetchRecommendVideos() async {
    if (isLoading.value || isLoadingMore.value) return;
    
    try {
      isLoading.value = true;
      isError.value = false;
      
      VideoApi videoApi = VideoApi();
      final res = await videoApi.getRcmdFeed();
      
      if (res != null && res.item.isNotEmpty) {
        // 将video_rcmd.RcmdItem转为界面使用的RcmdItem
        videoList.value = res.item.map((videoItem) => RcmdItem(
          id: int.tryParse(videoItem.bvid) ?? 0,
          bvid: videoItem.bvid,
          title: videoItem.title,
          pic: videoItem.pic,
          duration: videoItem.duration,
          owner: Owner(
            mid: videoItem.owner['mid'],
            name: videoItem.owner['name'],
          ),
          stat: Stat(
            view: videoItem.stat['view'] ?? 0,
            danmaku: videoItem.stat['danmaku'] ?? 0,
          ),
          rcmdReason: RcmdReason(),
        )).toList();
        hasMore.value = res.item.length >= 20;
      } else {
        isError.value = true;
      }
    } catch (e) {
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
  
  // 加载更多推荐视频
  Future<void> loadMoreRecommendVideos() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    
    try {
      isLoadingMore.value = true;
      
      VideoApi videoApi = VideoApi();
      final res = await videoApi.getRcmdFeed();
      
      if (res != null && res.item.isNotEmpty) {
        videoList.addAll(res.item.map((videoItem) => RcmdItem(
          id: int.tryParse(videoItem.bvid) ?? 0,
          bvid: videoItem.bvid,
          title: videoItem.title,
          pic: videoItem.pic,
          duration: videoItem.duration,
          owner: Owner(
            mid: videoItem.owner['mid'],
            name: videoItem.owner['name'],
          ),
          stat: Stat(
            view: videoItem.stat['view'] ?? 0,
            danmaku: videoItem.stat['danmaku'] ?? 0,
          ),
          rcmdReason: RcmdReason(),
        )).toList());
        hasMore.value = res.item.length >= 20;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  // 获取分区列表
  Future<void> _fetchRegionList() async {
    try {
      VideoApi videoApi = VideoApi();
      final res = await videoApi.getRegionList();
      
      if (res != null && res.isNotEmpty) {
        // 添加一个"推荐"分区作为首个选项，同时将video_region.Region转为界面使用的Region
        regionList.value = [
          Region(tid: 0, name: '推荐', logo: '', goto: '', param: '', uri: ''),
          ...res.map((videoRegion) => Region(
            tid: videoRegion.tid,
            name: videoRegion.name,
            logo: '',
            goto: '',
            param: '',
            uri: '',
          )).toList()
        ];
      }
    } catch (e) {
      // 如果获取分区失败，至少添加推荐分区
      regionList.value = [
        Region(tid: 0, name: '推荐', logo: '', goto: '', param: '', uri: ''),
      ];
    }
  }
  
  // 切换分区
  Future<void> changeRegion(int index) async {
    if (index < 0 || index >= regionList.length || index == selectedRegionIndex.value) {
      return;
    }
    
    selectedRegionIndex.value = index;
    
    if (index == 0) {
      // 推荐区域，重新加载推荐视频
      videoList.clear();
      _fetchRecommendVideos();
    } else {
      // 其他分区，加载分区视频
      _fetchRegionVideos(regionList[index].tid);
    }
  }
  
  // 获取分区视频
  Future<void> _fetchRegionVideos(int tid) async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      isError.value = false;
      videoList.clear();
      
      VideoApi videoApi = VideoApi();
      final res = await videoApi.getRegionVideos(tid, 1);
      
      if (res != null && res.archives.isNotEmpty) {
        // 转换格式以适配现有列表
        final items = res.archives.map((archive) => RcmdItem(
          id: 0, // video_region.RegionVideoItem没有aid属性
          bvid: archive.bvid,
          title: archive.title,
          pic: archive.pic,
          duration: archive.duration,
          owner: Owner(
            mid: archive.owner['mid'],
            name: archive.owner['name'],
          ),
          stat: Stat(
            view: archive.stat['view'] ?? 0,
            danmaku: archive.stat['danmaku'] ?? 0,
          ),
          rcmdReason: RcmdReason(),
        )).toList();
        
        videoList.value = items;
        hasMore.value = items.length >= 20;
      } else {
        isError.value = true;
      }
    } catch (e) {
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
  
  // 打开视频
  void openVideo(String bvid, int cid) {
    Get.toNamed('/tvPlayer', arguments: {
      'bvid': bvid,
      'cid': cid,
      'epid': null,
      'seasonId': null,
    });
  }
  
  // 打开搜索页面
  void openSearch() {
    Get.toNamed('/search');
  }
}

class TvHomePage extends StatelessWidget {
  const TvHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TvHomeController());
    
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              controller.scrollController.animateTo(
                controller.scrollController.offset + 200,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              controller.scrollController.animateTo(
                (controller.scrollController.offset - 200).clamp(0, controller.scrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        },
        child: Column(
          children: [
            // 头部区域（搜索栏和分区选择）
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'GiliGili TV',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      // 搜索按钮
                      TvFocusable(
                        focusNode: controller.searchFocusNode,
                        onTap: () => controller.openSearch(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '搜索',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 分区选择
                  SizedBox(
                    height: 40,
                    child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.regionList.length,
                      itemBuilder: (context, index) {
                        final isSelected = controller.selectedRegionIndex.value == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TvFocusable(
                            autoFocus: index == 0,
                            onTap: () => controller.changeRegion(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.regionList[index].name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.videoList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.isError.value && controller.videoList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text('加载失败'),
                        const SizedBox(height: 24),
                        TvFocusable(
                          autoFocus: true,
                          onTap: () => controller._fetchRecommendVideos(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '重试',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels > scrollInfo.metrics.maxScrollExtent - 200 &&
                        !controller.isLoadingMore.value &&
                        controller.hasMore.value) {
                      controller.loadMoreRecommendVideos();
                    }
                    return true;
                  },
                  child: TvFocusGrid(
                    crossAxisCount: 3,
                    spacing: 16,
                    runSpacing: 16,
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...List.generate(controller.videoList.length, (index) {
                        final video = controller.videoList[index];
                        return _buildVideoCard(context, video, controller, index);
                      }),
                      if (controller.isLoadingMore.value)
                        ...List.generate(3, (index) => const Center(child: CircularProgressIndicator())),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoCard(BuildContext context, RcmdItem video, TvHomeController controller, int index) {
    // 为第一行的前三个视频设置自动焦点，但搜索按钮优先级更高
    bool shouldAutoFocus = index < 3 && controller.searchFocusNode.hasFocus == false;
    
    // 使用自定义键盘方向控制
    return TvFocusable(
      autoFocus: shouldAutoFocus && index == 0,
      onTap: () {
        feedBack();
        // 直接使用传递全屏和自动退出参数的方法
        Utils.openVideoDirectly(video.bvid, video.id.toInt());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: video.pic,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Utils.timeFormat(video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            video.owner.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Text(
                Utils.compactFormat(video.stat.view),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.comment,
                size: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Text(
                Utils.compactFormat(video.stat.danmaku),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 