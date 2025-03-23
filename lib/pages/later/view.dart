import 'package:PiliPlus/common/widgets/icon_button.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/history/view.dart' show AppBarWidget;
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/http_error.dart';
import 'package:PiliPlus/common/widgets/video_card_h.dart';
import 'package:PiliPlus/pages/later/index.dart';

import '../../common/constants.dart';
import '../../utils/grid.dart';

class LaterPage extends StatefulWidget {
  const LaterPage({super.key});

  @override
  State<LaterPage> createState() => _LaterPageState();
}

class _LaterPageState extends State<LaterPage> {
  final LaterController _laterController = Get.put(LaterController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: _laterController.enableMultiSelect.value.not,
        onPopInvokedWithResult: (didPop, result) {
          if (_laterController.enableMultiSelect.value) {
            _laterController.handleSelect();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBarWidget(
            visible: _laterController.enableMultiSelect.value,
            child1: AppBar(
              title: Obx(
                () => Text(
                  '稍后再看${_laterController.count.value == -1 ? '' : ' (${_laterController.count.value})'}',
                ),
              ),
              actions: [
                Obx(
                  () => _laterController.count.value != -1
                      ? TextButton(
                          onPressed: () => _laterController.toViewDel(context),
                          child: const Text('移除已看'),
                        )
                      : const SizedBox(),
                ),
                Obx(
                  () => _laterController.count.value != -1
                      ? IconButton(
                          tooltip: '一键清空',
                          onPressed: () =>
                              _laterController.toViewClear(context),
                          icon: Icon(
                            Icons.clear_all_outlined,
                            size: 21,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : const SizedBox(),
                ),
                const SizedBox(width: 8),
              ],
            ),
            child2: AppBar(
              leading: IconButton(
                tooltip: '取消',
                onPressed: _laterController.handleSelect,
                icon: const Icon(Icons.close_outlined),
              ),
              title: Obx(
                () => Text(
                  '已选: ${_laterController.checkedCount.value}',
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                  ),
                  onPressed: () => _laterController.handleSelect(true),
                  child: const Text('全选'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                  ),
                  onPressed: () => Utils.onCopyOrMove(
                    context: context,
                    isCopy: true,
                    ctr: _laterController,
                    mediaId: null,
                  ),
                  child: Text(
                    '复制',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                  ),
                  onPressed: () => Utils.onCopyOrMove(
                    context: context,
                    isCopy: false,
                    ctr: _laterController,
                    mediaId: null,
                  ),
                  child: Text(
                    '移动',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                  ),
                  onPressed: () => _laterController.onDelChecked(context),
                  child: Text(
                    '移除',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          floatingActionButton: Obx(
            () => _laterController.loadingState.value is Success
                ? FloatingActionButton.extended(
                    onPressed: _laterController.toViewPlayAll,
                    label: const Text('播放全部'),
                    icon: const Icon(Icons.playlist_play),
                  )
                : const SizedBox(),
          ),
          body: refreshIndicator(
            onRefresh: () async {
              await _laterController.onRefresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _laterController.scrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 85,
                  ),
                  sliver: Obx(
                    () => _buildBody(_laterController.loadingState.value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            mainAxisSpacing: 2,
            maxCrossAxisExtent: Grid.mediumCardWidth * 2,
            childAspectRatio: StyleString.aspectRatio * 2.2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return const VideoCardHSkeleton();
            },
            childCount: 10,
          ),
        ),
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? SliverGrid(
              gridDelegate: SliverGridDelegateWithExtentAndRatio(
                mainAxisSpacing: 2,
                maxCrossAxisExtent: Grid.mediumCardWidth * 2,
                childAspectRatio: StyleString.aspectRatio * 2.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var videoItem = loadingState.response[index];
                  return Stack(
                    children: [
                      VideoCardH(
                        videoItem: videoItem,
                        source: 'later',
                        onViewLater: (cid) {
                          Utils.toViewPage(
                            'bvid=${videoItem.bvid}&cid=$cid',
                            arguments: {
                              'videoItem': videoItem,
                              'oid': videoItem.aid,
                              'heroTag': Utils.makeHeroTag(videoItem.bvid),
                              'sourceType': 'watchLater',
                              'count': loadingState.response.length,
                              'favTitle': '稍后再看',
                              'mediaId': _laterController.mid,
                              'desc': false,
                              'isContinuePlaying': index != 0,
                            },
                          );
                        },
                        onTap: _laterController.enableMultiSelect.value.not
                            ? null
                            : () {
                                _laterController.onSelect(index);
                              },
                        onLongPress: () {
                          if (_laterController.enableMultiSelect.value.not) {
                            _laterController.enableMultiSelect.value = true;
                            _laterController.onSelect(index);
                          }
                        },
                      ),
                      Positioned(
                        top: 5,
                        left: 12,
                        bottom: 5,
                        child: IgnorePointer(
                          child: LayoutBuilder(
                            builder: (context, constraints) => AnimatedOpacity(
                              opacity: videoItem.checked == true ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                alignment: Alignment.center,
                                height: constraints.maxHeight,
                                width: constraints.maxHeight *
                                    StyleString.aspectRatio,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: AnimatedScale(
                                    scale: videoItem.checked == true ? 1 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    child: IconButton(
                                      tooltip: '取消选择',
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            WidgetStateProperty.resolveWith(
                                          (states) {
                                            return Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.8);
                                          },
                                        ),
                                      ),
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.done_all_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 0,
                        child: iconButton(
                          tooltip: '移除',
                          context: context,
                          onPressed: () {
                            _laterController.toViewDel(
                              context,
                              aid: videoItem.aid,
                            );
                          },
                          icon: Icons.clear,
                          iconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          bgColor: Colors.transparent,
                        ),
                      ),
                    ],
                  );
                },
                childCount: loadingState.response.length,
              ),
            )
          : HttpError(
              callback: _laterController.onReload,
            ),
      Error() => HttpError(
          errMsg: loadingState.errMsg,
          callback: _laterController.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
