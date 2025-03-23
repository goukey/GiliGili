import 'dart:async';

import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/video_card_v.dart';
import 'package:PiliPlus/common/widgets/http_error.dart';
import 'package:PiliPlus/common/widgets/video_card_v.dart';
import 'package:PiliPlus/pages/home/index.dart';
import 'package:PiliPlus/pages/main/index.dart';

import '../../utils/grid.dart';
import 'controller.dart';

class RcmdPage extends StatefulWidget {
  const RcmdPage({super.key});

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  late final _controller = Get.put(RcmdController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.scrollController.addListener(listener);
  }

  void listener() {
    StreamController<bool> mainStream =
        Get.find<MainController>().bottomBarStream;
    StreamController<bool> searchBarStream =
        Get.find<HomeController>().searchBarStream;
    final ScrollDirection direction =
        _controller.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      mainStream.add(true);
      searchBarStream.add(true);
    } else if (direction == ScrollDirection.reverse) {
      mainStream.add(false);
      searchBarStream.add(false);
    }
  }

  @override
  void dispose() {
    _controller.scrollController.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
          left: StyleString.safeSpace, right: StyleString.safeSpace),
      decoration: BoxDecoration(
        borderRadius: StyleString.mdRadius,
      ),
      child: refreshIndicator(
        onRefresh: () async {
          await _controller.onRefresh();
        },
        child: CustomScrollView(
          controller: _controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: StyleString.cardSpace,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              sliver: Obx(
                () => _controller.loadingState.value is Loading ||
                        _controller.loadingState.value is Success
                    ? contentGrid(_controller.loadingState.value)
                    : HttpError(
                        errMsg: _controller.loadingState.value is Error
                            ? (_controller.loadingState.value as Error).errMsg
                            : '没有相关数据',
                        callback: _controller.onReload,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentGrid(LoadingState loadingState) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithExtentAndRatio(
        // 行间距
        mainAxisSpacing: StyleString.cardSpace,
        // 列间距
        crossAxisSpacing: StyleString.cardSpace,
        // 最大宽度
        maxCrossAxisExtent: Grid.smallCardWidth,
        childAspectRatio: StyleString.aspectRatio,
        mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (loadingState is Success &&
              index == loadingState.response.length - 1) {
            _controller.onLoadMore();
          }
          if (loadingState is Success) {
            if (_controller.lastRefreshAt != null) {
              if (_controller.lastRefreshAt == index) {
                return GestureDetector(
                  onTap: () {
                    _controller.animateToTop();
                    _controller.onRefresh();
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '上次看到这里\n点击刷新',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }
              int actualIndex = _controller.lastRefreshAt == null
                  ? index
                  : index > _controller.lastRefreshAt!
                      ? index - 1
                      : index;
              return VideoCardV(
                videoItem: loadingState.response[actualIndex],
                onRemove: () {
                  if (_controller.lastRefreshAt != null &&
                      actualIndex < _controller.lastRefreshAt!) {
                    _controller.lastRefreshAt = _controller.lastRefreshAt! - 1;
                  }
                  _controller.loadingState.value = LoadingState.success(
                      (loadingState.response as List)..removeAt(actualIndex));
                },
              );
            } else {
              return VideoCardV(
                videoItem: loadingState.response[index],
                onRemove: () {
                  _controller.loadingState.value = LoadingState.success(
                      (loadingState.response as List)..removeAt(index));
                },
              );
            }
          }
          return const VideoCardVSkeleton();
        },
        childCount: loadingState is Success
            ? _controller.lastRefreshAt != null
                ? loadingState.response.length + 1
                : loadingState.response.length
            : 10,
      ),
    );
  }
}
