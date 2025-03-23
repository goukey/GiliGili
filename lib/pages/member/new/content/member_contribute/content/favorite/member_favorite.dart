import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/loading_widget.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_fav/datum.dart';
import 'package:PiliPlus/models/space_fav/list.dart';
import 'package:PiliPlus/models/user/sub_folder.dart';
import 'package:PiliPlus/pages/member/new/content/member_contribute/content/favorite/member_favorite_ctr.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberFavorite extends StatefulWidget {
  const MemberFavorite({
    super.key,
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  @override
  State<MemberFavorite> createState() => _MemberFavoriteState();
}

class _MemberFavoriteState extends State<MemberFavorite>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _controller = Get.put(
    MemberFavoriteCtr(mid: widget.mid),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => _buildBody(_controller.loadingState.value));
  }

  _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? refreshIndicator(
              onRefresh: () async {
                await _controller.onRefresh();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Obx(
                      () => _buildItem(_controller.first.value, true),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(
                      () => _buildItem(_controller.second.value, false),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 12 + MediaQuery.of(context).padding.bottom,
                    ),
                  )
                ],
              ),
            )
          : scrollErrorWidget(
              callback: _controller.onReload,
            ),
      Error() => scrollErrorWidget(
          errMsg: loadingState.errMsg,
          callback: _controller.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }

  _buildItem(Datum data, bool isFirst) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        dense: true,
        initiallyExpanded: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: data.name,
                style: TextStyle(fontSize: 14),
              ),
              TextSpan(
                text: ' ${data.mediaListResponse?.count}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          ...(data.mediaListResponse?.list as List<FavList>).map(
            (item1) => ListTile(
              onTap: () async {
                if (item1.state == 1) {
                  // invalid
                  return;
                }

                if (item1.type == 0) {
                  dynamic res = await Get.toNamed(
                    '/favDetail',
                    parameters: {
                      'mediaId': item1.id.toString(),
                      'heroTag': widget.heroTag ?? '',
                    },
                  );
                  if (res == true) {
                    _controller.first.value.mediaListResponse?.list
                        ?.remove(item1);
                    _controller.first.refresh();
                  } else {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _controller.onRefresh();
                    });
                  }
                } else {
                  Get.toNamed(
                    '/subDetail',
                    arguments: SubFolderItemData(
                      type: item1.type,
                      title: item1.title,
                      cover: item1.cover,
                      upper: Upper(
                        mid: item1.upper?.mid,
                        name: item1.upper?.name,
                        face: item1.upper?.face,
                      ),
                      mediaCount: item1.mediaCount,
                      viewCount: item1.viewCount,
                    ),
                    parameters: {
                      'heroTag': widget.heroTag ?? '',
                      'id': item1.id.toString(),
                    },
                  );
                }
              },
              leading: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        NetworkImgLayer(
                          radius: 6,
                          src: item1.cover,
                          width:
                              constraints.maxHeight * StyleString.aspectRatio,
                          height: constraints.maxHeight,
                        ),
                        if (item1.type == 21)
                          PBadge(
                            right: 3,
                            bottom: 3,
                            text: '合集',
                            bold: false,
                            size: 'small',
                          )
                        else if (item1.type == 0 || item1.type == 11)
                          Positioned(
                            right: 3,
                            bottom: 3,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Icon(
                                Icons.video_library_outlined,
                                size: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              title: Text(
                item1.title ?? '',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                item1.type == 0
                    ? '${item1.mediaCount}个内容 · ${Utils.isPublicText(item1.attr ?? 0)}'
                    : item1.type == 11
                        ? '${item1.mediaCount}个内容 · ${item1.upper?.name}'
                        : item1.type == 21
                            ? '创建者: ${item1.upper?.name}\n${item1.mediaCount}个视频 · ${Utils.numFormat(item1.viewCount)}播放'
                            : '${item1.mediaCount}个内容',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
          Obx(
            () => (isFirst
                    ? _controller.firstEnd.value
                    : _controller.secondEnd.value)
                ? const SizedBox.shrink()
                : _buildLoadMoreItem(isFirst),
          ),
        ],
      ),
    );
  }

  _buildLoadMoreItem(bool isFirst) {
    return ListTile(
      dense: true,
      onTap: () {
        if (isFirst) {
          _controller.userfavFolder();
        } else {
          _controller.userSubFolder();
        }
      },
      title: Text(
        '查看更多内容',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
