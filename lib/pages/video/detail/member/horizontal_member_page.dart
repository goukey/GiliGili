import 'package:GiliGili/common/constants.dart';
import 'package:GiliGili/common/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:GiliGili/common/widgets/icon_button.dart';
import 'package:GiliGili/common/widgets/interactiveviewer_gallery/interactiveviewer_gallery.dart'
    show SourceModel;
import 'package:GiliGili/common/widgets/loading_widget.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/common/widgets/video_card_h_member_video.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/member/info.dart';
import 'package:GiliGili/pages/video/detail/controller.dart';
import 'package:GiliGili/pages/video/detail/introduction/controller.dart';
import 'package:GiliGili/pages/video/detail/member/controller.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/grid.dart';
import 'package:GiliGili/utils/id_utils.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../../models/space_archive/item.dart';

class HorizontalMemberPage extends StatefulWidget {
  const HorizontalMemberPage({
    super.key,
    required this.mid,
    required this.videoDetailController,
    required this.videoIntroController,
  });

  final dynamic mid;
  final VideoDetailController videoDetailController;
  final VideoIntroController videoIntroController;

  @override
  State<HorizontalMemberPage> createState() => _HorizontalMemberPageState();
}

class _HorizontalMemberPageState extends State<HorizontalMemberPage> {
  late final HorizontalMemberPageController _controller;
  int? _ownerMid;
  dynamic _bvid;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = Utils.makeHeroTag(widget.mid);
    _controller = Get.put(
      HorizontalMemberPageController(mid: widget.mid),
      tag: _tag,
    );
    _bvid = widget.videoDetailController.bvid;
    _ownerMid = GStorage.userInfo.get('userInfoCache')?.mid;
  }

  @override
  void dispose() {
    Get.delete<HorizontalMemberPageController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _buildUserPage(_controller.userState.value),
    );
  }

  Widget _buildUserPage(LoadingState userState) {
    return switch (userState) {
      Loading() => loadingWidget,
      Success() => Column(
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                iconButton(
                  context: context,
                  onPressed: Get.back,
                  tooltip: '关闭',
                  icon: Icons.clear,
                  size: 32,
                ),
                const SizedBox(width: 16),
              ],
            ),
            _buildUserInfo(userState.response),
            const SizedBox(height: 5),
            Expanded(
              child: Obx(() => _buildVideoList(_controller.loadingState.value)),
            ),
          ],
        ),
      Error() => errorWidget(
          errMsg: userState.errMsg,
          callback: () {
            _controller.userState.value = LoadingState.loading();
            _controller.getUserInfo();
          },
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }

  Widget get _buildSliverHeader {
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: CustomSliverPersistentHeaderDelegate(
        extent: 40,
        bgColor: Theme.of(context).colorScheme.surface,
        child: Container(
          height: 40,
          padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  _controller.count.value != -1
                      ? '共${_controller.count.value}视频'
                      : '',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(
                height: 35,
                child: TextButton.icon(
                  onPressed: _controller.queryBySort,
                  icon: Icon(
                    Icons.sort,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: Obx(
                    () => Text(
                      _controller.order.value == 'pubdate' ? '最新发布' : '最多播放',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => Material(
          color: Colors.transparent,
          child: CustomScrollView(
            controller: ScrollController(),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverHeader,
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithExtentAndRatio(
                    mainAxisSpacing: 2,
                    maxCrossAxisExtent: Grid.mediumCardWidth * 2,
                    childAspectRatio: StyleString.aspectRatio * 2.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == loadingState.response.length - 1) {
                        _controller.onLoadMore();
                      }
                      return VideoCardHMemberVideo(
                        videoItem: loadingState.response[index],
                        bvid: _bvid,
                        onTap: () {
                          final Item videoItem = loadingState.response[index];
                          widget.videoIntroController.changeSeasonOrbangu(
                            null,
                            videoItem.bvid,
                            videoItem.firstCid,
                            IdUtils.bv2av(videoItem.bvid!),
                            videoItem.cover,
                          );
                          _bvid = videoItem.bvid;
                          setState(() {});
                        },
                      );
                    },
                    childCount: loadingState.response.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      Error() => errorWidget(
          errMsg: loadingState.errMsg,
          callback: _controller.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }

  Widget _buildUserInfo(MemberInfoModel memberInfoModel) {
    return Row(
      children: [
        const SizedBox(width: 16),
        _buildAvatar(memberInfoModel.face),
        const SizedBox(width: 10),
        Expanded(child: _buildInfo(memberInfoModel)),
        const SizedBox(width: 16),
      ],
    );
  }

  _buildInfo(MemberInfoModel memberInfoModel) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Utils.copyText(memberInfoModel.name ?? '');
                },
                child: Text(
                  memberInfoModel.name ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (memberInfoModel.vip?.status ?? -1) > 0 &&
                            memberInfoModel.vip?.type == 2
                        ? context.vipColor
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/lv/lv${memberInfoModel.level}.png',
                height: 11,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Obx(
            () => Row(
              children: List.generate(5, (index) {
                if (index % 2 == 0) {
                  return _buildChildInfo(
                    title: const ['粉丝', '关注', '获赞'][index ~/ 2],
                    num: index == 0
                        ? _controller.userStat['follower'] != null
                            ? Utils.numFormat(_controller.userStat['follower'])
                            : ''
                        : index == 2
                            ? _controller.userStat['following'] ?? ''
                            : _controller.userStat['likes'] != null
                                ? Utils.numFormat(_controller.userStat['likes'])
                                : '',
                    onTap: () {
                      if (index == 0) {
                        Get.toNamed(
                            '/fan?mid=${widget.mid}&name=${memberInfoModel.name}');
                      } else if (index == 2) {
                        Get.toNamed(
                            '/follow?mid=${widget.mid}&name=${memberInfoModel.name}');
                      }
                    },
                  );
                } else {
                  return SizedBox(
                    height: 10,
                    width: 20,
                    child: VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  );
                }
              }),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: memberInfoModel.isFollowed == true
                        ? Theme.of(context).colorScheme.onInverseSurface
                        : null,
                    foregroundColor: memberInfoModel.isFollowed == true
                        ? Theme.of(context).colorScheme.outline
                        : null,
                    padding: const EdgeInsets.all(0),
                    visualDensity: const VisualDensity(
                      vertical: -2,
                    ),
                  ),
                  onPressed: () {
                    if (widget.mid == _ownerMid) {
                      Get.toNamed('/editProfile');
                    } else {
                      if (_ownerMid == null) {
                        SmartDialog.showToast('账号未登录');
                        return;
                      }
                      Utils.actionRelationMod(
                        context: context,
                        mid: widget.mid,
                        isFollow: memberInfoModel.isFollowed ?? false,
                        callback: (attribute) {
                          _controller.userState.value = LoadingState.success(
                              memberInfoModel..isFollowed = attribute != 0);
                        },
                      );
                    }
                  },
                  child: Text(
                    widget.mid == _ownerMid
                        ? '编辑资料'
                        : memberInfoModel.isFollowed == true
                            ? '已关注'
                            : '关注',
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    visualDensity: const VisualDensity(
                      vertical: -2,
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/member?mid=${widget.mid}');
                  },
                  child: Text(
                    '查看主页',
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildChildInfo({
    required String title,
    required dynamic num,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        '$num$title',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  _buildAvatar(face) => Hero(
        tag: face,
        child: GestureDetector(
          onTap: () {
            widget.videoDetailController.onViewImage();
            context.imageView(
              imgList: [SourceModel(url: face)],
              onDismissed: widget.videoDetailController.onDismissed,
            );
          },
          child: NetworkImgLayer(
            src: face,
            type: 'avatar',
            width: 70,
            height: 70,
          ),
        ),
      );
}
