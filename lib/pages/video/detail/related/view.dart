import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/http_error.dart';
import 'package:PiliPlus/common/widgets/video_card_h.dart';
import '../../../../common/constants.dart';
import '../../../../utils/grid.dart';
import './controller.dart';

class RelatedVideoPanel extends StatefulWidget {
  const RelatedVideoPanel({super.key, required this.heroTag});
  final String heroTag;
  @override
  State<RelatedVideoPanel> createState() => _RelatedVideoPanelState();
}

class _RelatedVideoPanelState extends State<RelatedVideoPanel>
    with AutomaticKeepAliveClientMixin {
  late final RelatedController _relatedController =
      Get.put(RelatedController(), tag: widget.heroTag);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SliverPadding(
      padding: const EdgeInsets.only(top: StyleString.safeSpace - 5),
      sliver: Obx(() => _buildBody(_relatedController.loadingState.value)),
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
            childCount: 5,
          ),
        ),
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? SliverGrid(
              gridDelegate: SliverGridDelegateWithExtentAndRatio(
                mainAxisSpacing: 2,
                maxCrossAxisExtent: Grid.mediumCardWidth * 2,
                childAspectRatio: StyleString.aspectRatio * 2.2,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == loadingState.response.length) {
                  return SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  );
                } else {
                  return VideoCardH(
                    videoItem: loadingState.response[index],
                    showPubdate: true,
                  );
                }
              }, childCount: loadingState.response.length + 1),
            )
          : SliverToBoxAdapter(),
      Error() => HttpError(
          errMsg: loadingState.errMsg,
          callback: _relatedController.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
