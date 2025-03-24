import 'dart:math';

import 'package:GiliGili/common/widgets/article_content.dart';
import 'package:GiliGili/common/widgets/http_error.dart';
import 'package:GiliGili/common/widgets/loading_widget.dart';
import 'package:GiliGili/common/widgets/refresh_indicator.dart';
import 'package:GiliGili/http/constants.dart';
import 'package:GiliGili/http/loading_state.dart';
import 'package:GiliGili/models/common/reply_sort_type.dart';
import 'package:GiliGili/pages/dynamics/repost_dyn_panel.dart';
import 'package:GiliGili/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:GiliGili/pages/video/detail/reply/widgets/reply_item_grpc.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/global_data.dart';
import 'package:GiliGili/utils/storage.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:GiliGili/common/skeleton/video_reply.dart';
import 'package:GiliGili/common/widgets/html_render.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/models/common/reply_type.dart';
import 'package:GiliGili/pages/video/detail/reply_reply/index.dart';
import 'package:GiliGili/utils/feed_back.dart';

import '../../utils/grid.dart';
import 'controller.dart';

class HtmlRenderPage extends StatefulWidget {
  const HtmlRenderPage({super.key});

  @override
  State<HtmlRenderPage> createState() => _HtmlRenderPageState();
}

class _HtmlRenderPageState extends State<HtmlRenderPage>
    with TickerProviderStateMixin {
  late final HtmlRenderController _htmlRenderCtr = Get.put(
    HtmlRenderController(),
    tag: Utils.makeHeroTag(id),
  );
  late String title;
  late String id;
  late String url;
  late String dynamicType;
  late int type;
  bool _isFabVisible = true;
  bool? _imageStatus;
  late AnimationController fabAnimationCtr;

  late final List<double> _ratio = GStorage.dynamicDetailRatio;

  bool get _horizontalPreview =>
      context.orientation == Orientation.landscape &&
      _htmlRenderCtr.horizontalPreview;

  late final _key = GlobalKey<ScaffoldState>();

  get _getImageCallback => _horizontalPreview
      ? (imgList, index) {
          _imageStatus = true;
          bool isFabVisible = _isFabVisible;
          if (isFabVisible) {
            _hideFab();
          }
          final ctr = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 200),
          )..forward();
          Utils.onHorizontalPreview(
            _key,
            AnimationController(
              vsync: this,
              duration: Duration.zero,
            ),
            ctr,
            imgList,
            index,
            (value) async {
              _imageStatus = null;
              if (isFabVisible) {
                isFabVisible = false;
                _showFab();
              }
              if (value == false) {
                await ctr.reverse();
              }
              try {
                ctr.dispose();
              } catch (_) {}
              if (value == false) {
                Get.back();
              }
            },
          );
        }
      : null;

  @override
  void initState() {
    super.initState();
    title = Get.parameters['title']!;
    id = Get.parameters['id']!;
    url = Get.parameters['url']!;
    dynamicType = Get.parameters['dynamicType']!;
    type = dynamicType == 'picture' ? 11 : 12;
    fabAnimationCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabAnimationCtr.forward();
    scrollListener();
  }

  @override
  void dispose() {
    fabAnimationCtr.dispose();
    _htmlRenderCtr.scrollController.removeListener(listener);
    super.dispose();
  }

  void scrollListener() {
    _htmlRenderCtr.scrollController.addListener(listener);
  }

  void listener() {
    // 标题
    // if (scrollController.offset > 55 && !_visibleTitle) {
    //   _visibleTitle = true;
    //   titleStreamC.add(true);
    // } else if (scrollController.offset <= 55 && _visibleTitle) {
    //   _visibleTitle = false;
    //   titleStreamC.add(false);
    // }

    // fab按钮
    final ScrollDirection direction1 =
        _htmlRenderCtr.scrollController.positions.first.userScrollDirection;
    late final ScrollDirection direction2 =
        _htmlRenderCtr.scrollController.positions.last.userScrollDirection;
    if (direction1 == ScrollDirection.forward ||
        direction2 == ScrollDirection.forward) {
      _showFab();
    } else if (direction1 == ScrollDirection.reverse ||
        direction2 == ScrollDirection.reverse) {
      _hideFab();
    }
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      fabAnimationCtr.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      fabAnimationCtr.reverse();
    }
  }

  void replyReply(context, replyItem, id, isTop) {
    EasyThrottle.throttle('replyReply', const Duration(milliseconds: 500), () {
      int oid = replyItem.oid.toInt();
      int rpid = GlobalData().grpcReply ? replyItem.id.toInt() : replyItem.rpid;
      Widget replyReplyPage(
              [bool automaticallyImplyLeading = true,
              VoidCallback? onDispose]) =>
          Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text('评论详情'),
              titleSpacing: automaticallyImplyLeading ? null : 12,
              automaticallyImplyLeading: automaticallyImplyLeading,
            ),
            body: VideoReplyReplyPanel(
              id: id,
              oid: oid,
              rpid: rpid,
              source: 'dynamic',
              replyType: ReplyType.values[type],
              firstFloor: replyItem,
              isTop: isTop ?? false,
              onDispose: onDispose,
            ),
          );
      if (this.context.orientation == Orientation.portrait) {
        Get.to(replyReplyPage);
      } else {
        ScaffoldState? scaffoldState = Scaffold.maybeOf(context);
        if (scaffoldState != null) {
          bool isFabVisible = _isFabVisible;
          if (isFabVisible) {
            _hideFab();
          }
          scaffoldState.showBottomSheet(
            backgroundColor: Colors.transparent,
            (context) => MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              child: replyReplyPage(
                false,
                () {
                  if (isFabVisible && _imageStatus != true) {
                    _showFab();
                  }
                },
              ),
            ),
          );
        } else {
          Get.to(replyReplyPage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(title),
        actions: [
          const SizedBox(width: 4),
          if (context.orientation == Orientation.landscape)
            IconButton(
              tooltip: '页面比例调节',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 56,
                        right: 16,
                      ),
                      width: context.width / 4,
                      height: 32,
                      child: Builder(
                        builder: (context) => Slider(
                          min: 1,
                          max: 100,
                          value: _ratio.first,
                          onChanged: (value) async {
                            if (value >= 10 && value <= 90) {
                              _ratio[0] = value;
                              _ratio[1] = 100 - value;
                              await GStorage.setting.put(
                                SettingBoxKey.dynamicDetailRatio,
                                _ratio,
                              );
                              (context as Element).markNeedsBuild();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: Transform.rotate(
                angle: pi / 2,
                child: Icon(Icons.splitscreen, size: 19),
              ),
            ),
          IconButton(
            tooltip: '浏览器打开',
            onPressed: () {
              Utils.inAppWebview(url.startsWith('http') ? url : 'https:$url');
            },
            icon: const Icon(Icons.open_in_browser_outlined, size: 19),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 19),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () => {
                  _htmlRenderCtr.reqHtml(),
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 19),
                    SizedBox(width: 10),
                    Text('刷新'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  Utils.inAppWebview(
                      url.startsWith('http') ? url : 'https:$url');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 19),
                    SizedBox(width: 10),
                    Text('浏览器打开'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Utils.copyText(url),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 19),
                    SizedBox(width: 10),
                    Text('复制链接'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Utils.shareText(url),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('分享'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6)
        ],
      ),
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) {
              double padding = max(context.width / 2 - Grid.smallCardWidth, 0);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: _ratio[0].toInt(),
                    child: CustomScrollView(
                      controller: _htmlRenderCtr.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: orientation == Orientation.portrait
                              ? EdgeInsets.symmetric(horizontal: padding)
                              : EdgeInsets.only(left: padding / 4),
                          sliver: SliverToBoxAdapter(
                            child: Obx(
                              () => _htmlRenderCtr.loaded.value
                                  ? _buildHeader
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: orientation == Orientation.portrait
                              ? EdgeInsets.symmetric(horizontal: padding)
                              : EdgeInsets.only(
                                  left: padding / 4,
                                  bottom:
                                      MediaQuery.paddingOf(context).bottom + 80,
                                ),
                          sliver: _buildContent,
                        ),
                        if (orientation == Orientation.portrait) ...[
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            sliver: SliverToBoxAdapter(
                              child: Divider(
                                thickness: 8,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.05),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            sliver: SliverToBoxAdapter(child: replyHeader()),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            sliver: Obx(
                              () =>
                                  replyList(_htmlRenderCtr.loadingState.value),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (orientation == Orientation.landscape) ...[
                    VerticalDivider(
                      thickness: 8,
                      color: Theme.of(context).dividerColor.withOpacity(0.05),
                    ),
                    Expanded(
                      flex: _ratio[1].toInt(),
                      child: Scaffold(
                        key: _key,
                        backgroundColor: Colors.transparent,
                        body: refreshIndicator(
                          onRefresh: () async {
                            await _htmlRenderCtr.onRefresh();
                          },
                          child: CustomScrollView(
                            controller: _htmlRenderCtr.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.only(right: padding / 4),
                                sliver: SliverToBoxAdapter(
                                  child: replyHeader(),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.only(right: padding / 4),
                                sliver: Obx(
                                  () => replyList(
                                      _htmlRenderCtr.loadingState.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: fabAnimationCtr,
                curve: Curves.easeInOut,
              )),
              child: Builder(
                builder: (context) {
                  Widget button() => FloatingActionButton(
                        heroTag: null,
                        onPressed: () {
                          feedBack();
                          _htmlRenderCtr.onReply(
                            context,
                            oid: _htmlRenderCtr.oid.value,
                            replyType: ReplyType.values[type],
                          );
                        },
                        tooltip: '评论动态',
                        child: const Icon(Icons.reply),
                      );
                  return _htmlRenderCtr.showDynActionBar.not
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 14,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 14,
                            ),
                            child: button(),
                          ),
                        )
                      : Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 14,
                                  bottom: 14 +
                                      (_htmlRenderCtr.item.value.idStr != null
                                          ? 0
                                          : MediaQuery.of(context)
                                              .padding
                                              .bottom),
                                ),
                                child: button(),
                              ),
                              _htmlRenderCtr.item.value.idStr != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        border: Border(
                                          top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.08),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.paddingOf(context)
                                              .bottom),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Builder(
                                              builder: (btnContext) =>
                                                  TextButton.icon(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    useSafeArea: true,
                                                    builder: (context) =>
                                                        RepostPanel(
                                                      item: _htmlRenderCtr
                                                          .item.value,
                                                      callback: () {
                                                        int count = int.tryParse(
                                                                _htmlRenderCtr
                                                                        .item
                                                                        .value
                                                                        .modules
                                                                        ?.moduleStat
                                                                        ?.forward
                                                                        ?.count ??
                                                                    '0') ??
                                                            0;
                                                        _htmlRenderCtr
                                                                .item
                                                                .value
                                                                .modules
                                                                ?.moduleStat
                                                                ?.forward!
                                                                .count =
                                                            (count + 1)
                                                                .toString();
                                                        if (btnContext
                                                            .mounted) {
                                                          (btnContext
                                                                  as Element?)
                                                              ?.markNeedsBuild();
                                                        }
                                                      },
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  FontAwesomeIcons
                                                      .shareFromSquare,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  semanticLabel: "转发",
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 0, 15, 0),
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                ),
                                                label: Text(
                                                  _htmlRenderCtr
                                                              .item
                                                              .value
                                                              .modules
                                                              ?.moduleStat
                                                              ?.forward!
                                                              .count !=
                                                          null
                                                      ? Utils.numFormat(
                                                          _htmlRenderCtr
                                                              .item
                                                              .value
                                                              .modules
                                                              ?.moduleStat
                                                              ?.forward!
                                                              .count)
                                                      : '转发',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Utils.shareText(
                                                    '${HttpString.dynamicShareBaseUrl}/${_htmlRenderCtr.item.value.idStr}');
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.shareNodes,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                                semanticLabel: "分享",
                                              ),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 0, 15, 0),
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                              ),
                                              label: const Text('分享'),
                                            ),
                                          ),
                                          Expanded(
                                            child: Builder(
                                              builder: (context) =>
                                                  TextButton.icon(
                                                onPressed: () =>
                                                    Utils.onLikeDynamic(
                                                  _htmlRenderCtr.item.value,
                                                  () {
                                                    if (context.mounted) {
                                                      (context as Element?)
                                                          ?.markNeedsBuild();
                                                    }
                                                  },
                                                ),
                                                icon: Icon(
                                                  _htmlRenderCtr
                                                              .item
                                                              .value
                                                              .modules
                                                              ?.moduleStat
                                                              ?.like
                                                              ?.status ==
                                                          true
                                                      ? FontAwesomeIcons
                                                          .solidThumbsUp
                                                      : FontAwesomeIcons
                                                          .thumbsUp,
                                                  size: 16,
                                                  color: _htmlRenderCtr
                                                              .item
                                                              .value
                                                              .modules
                                                              ?.moduleStat
                                                              ?.like
                                                              ?.status ==
                                                          true
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                  semanticLabel: _htmlRenderCtr
                                                              .item
                                                              .value
                                                              .modules
                                                              ?.moduleStat
                                                              ?.like
                                                              ?.status ==
                                                          true
                                                      ? "已赞"
                                                      : "点赞",
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          15, 0, 15, 0),
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                ),
                                                label: AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return ScaleTransition(
                                                        scale: animation,
                                                        child: child);
                                                  },
                                                  child: Text(
                                                    _htmlRenderCtr
                                                                .item
                                                                .value
                                                                .modules
                                                                ?.moduleStat
                                                                ?.like
                                                                ?.count !=
                                                            null
                                                        ? Utils.numFormat(
                                                            _htmlRenderCtr
                                                                .item
                                                                .value
                                                                .modules!
                                                                .moduleStat!
                                                                .like!
                                                                .count)
                                                        : '点赞',
                                                    style: TextStyle(
                                                      color: _htmlRenderCtr
                                                                  .item
                                                                  .value
                                                                  .modules
                                                                  ?.moduleStat
                                                                  ?.like
                                                                  ?.status ==
                                                              true
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .outline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget replyList(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => SliverList.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return const VideoReplySkeleton();
          },
        ),
      Success() => (loadingState.response.replies as List?)?.isNotEmpty == true
          ? SliverList.builder(
              itemCount: loadingState.response.replies.length + 1,
              itemBuilder: (context, index) {
                if (index == loadingState.response.replies.length) {
                  _htmlRenderCtr.onLoadMore();
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom),
                    height: MediaQuery.of(context).padding.bottom + 100,
                    child: Text(
                      _htmlRenderCtr.isEnd.not
                          ? '加载中...'
                          : loadingState.response.replies.isEmpty
                              ? '还没有评论'
                              : '没有更多了',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                } else {
                  return GlobalData().grpcReply
                      ? ReplyItemGrpc(
                          replyItem: loadingState.response.replies[index],
                          showReplyRow: true,
                          replyLevel: '1',
                          replyReply: (replyItem, id, isTop) =>
                              replyReply(context, replyItem, id, isTop),
                          replyType: ReplyType.values[type],
                          onReply: () {
                            _htmlRenderCtr.onReply(
                              context,
                              replyItem: loadingState.response.replies[index],
                              index: index,
                            );
                          },
                          onDelete: _htmlRenderCtr.onMDelete,
                          isTop: _htmlRenderCtr.hasUpTop && index == 0,
                          upMid: loadingState.response.subjectControl.upMid,
                          callback: _getImageCallback,
                          onCheckReply: (item) =>
                              _htmlRenderCtr.onCheckReply(context, item),
                        )
                      : ReplyItem(
                          replyItem: loadingState.response.replies[index],
                          showReplyRow: true,
                          replyLevel: '1',
                          replyReply: (replyItem, id, isTop) =>
                              replyReply(context, replyItem, id, isTop),
                          replyType: ReplyType.values[type],
                          onReply: () {
                            _htmlRenderCtr.onReply(
                              context,
                              replyItem: loadingState.response.replies[index],
                              index: index,
                            );
                          },
                          onDelete: _htmlRenderCtr.onMDelete,
                          callback: _getImageCallback,
                          onCheckReply: (item) =>
                              _htmlRenderCtr.onCheckReply(context, item),
                        );
                }
              },
            )
          : HttpError(
              callback: _htmlRenderCtr.onReload,
            ),
      Error() => replyErrorWidget(
          context,
          true,
          loadingState.errMsg,
          _htmlRenderCtr.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }

  Container replyHeader() {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Row(
        children: [
          const Text('回复'),
          const Spacer(),
          SizedBox(
            height: 35,
            child: TextButton.icon(
              onPressed: () => _htmlRenderCtr.queryBySort(),
              icon: const Icon(Icons.sort, size: 16),
              label: Obx(
                () => Text(
                  _htmlRenderCtr.sortType.value.label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget get _buildHeader => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            NetworkImgLayer(
              width: 40,
              height: 40,
              type: 'avatar',
              src: _htmlRenderCtr.response['avatar']!,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _htmlRenderCtr.response['uname'],
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  ),
                ),
                Text(
                  _htmlRenderCtr.response['updateTime'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );

  Widget get _buildContent => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        sliver: Obx(
          () => _htmlRenderCtr.loaded.value
              ? _htmlRenderCtr.response['isJsonContent'] == true
                  ? SliverLayoutBuilder(
                      builder: (context, constraints) => articleContent(
                        context: context,
                        list: _htmlRenderCtr.response['content'],
                        callback: _getImageCallback,
                        maxWidth: constraints.crossAxisExtent,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: LayoutBuilder(
                        builder: (context, constraints) => htmlRender(
                          context: context,
                          htmlContent: _htmlRenderCtr.response['content'],
                          constrainedWidth: constraints.maxWidth,
                          callback: _getImageCallback,
                        ),
                      ),
                    )
              : SliverToBoxAdapter(child: const SizedBox()),
        ),
      );
}
