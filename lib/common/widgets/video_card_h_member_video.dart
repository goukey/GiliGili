import 'package:PiliPlus/common/widgets/image_save.dart';
import 'package:PiliPlus/common/widgets/stat/danmu.dart';
import 'package:PiliPlus/common/widgets/stat/view.dart';
import 'package:PiliPlus/common/widgets/video_popup_menu.dart';
import 'package:PiliPlus/common/widgets/video_progress_indicator.dart';
import 'package:PiliPlus/models/space_archive/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';

// 视频卡片 - 水平布局
class VideoCardHMemberVideo extends StatelessWidget {
  const VideoCardHMemberVideo({
    super.key,
    required this.videoItem,
    this.onTap,
    this.bvid,
  });
  final Item videoItem;
  final VoidCallback? onTap;
  final dynamic bvid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onLongPress: () => imageSaveDialog(
            context: context,
            title: videoItem.title,
            cover: videoItem.cover,
          ),
          onTap: () async {
            if (onTap != null) {
              onTap!();
              return;
            }
            if (videoItem.isPgc == true && videoItem.uri?.isNotEmpty == true) {
              if (Utils.viewPgcFromUri(videoItem.uri!)) {
                return;
              }
            }
            if (videoItem.bvid == null || videoItem.firstCid == null) {
              return;
            }
            try {
              Utils.toViewPage(
                'bvid=${videoItem.bvid}&cid=${videoItem.firstCid}',
                arguments: {
                  'heroTag': Utils.makeHeroTag(videoItem.bvid),
                },
              );
            } catch (err) {
              SmartDialog.showToast(err.toString());
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StyleString.safeSpace,
              vertical: 5,
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints boxConstraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: StyleString.aspectRatio,
                      child: LayoutBuilder(
                        builder: (BuildContext context,
                            BoxConstraints boxConstraints) {
                          final double maxWidth = boxConstraints.maxWidth;
                          final double maxHeight = boxConstraints.maxHeight;
                          return Stack(
                            children: [
                              NetworkImgLayer(
                                src: videoItem.cover,
                                // videoItem.season?['cover'] ?? videoItem.cover,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                              if (videoItem.badges?.isNotEmpty == true)
                                PBadge(
                                  text: videoItem.badges!
                                      .map((item) => item.text)
                                      .join('|'),
                                  right: 6.0,
                                  top: 6.0,
                                ),
                              if (videoItem.duration != null)
                                PBadge(
                                  text: Utils.timeFormat(videoItem.duration),
                                  right: 6.0,
                                  bottom: 6.0,
                                  type: 'gray',
                                ),
                              if (videoItem.history != null)
                                Builder(builder: (context) {
                                  try {
                                    return Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: videoProgressIndicator(
                                        videoItem.history!['progress'] /
                                            videoItem.history!['duration'],
                                      ),
                                    );
                                  } catch (_) {
                                    return const SizedBox.shrink();
                                  }
                                }),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    videoContent(context),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 12,
          child: VideoPopupMenu(
            size: 29,
            iconSize: 17,
            videoItem: videoItem,
          ),
        ),
      ],
    );
  }

  Widget videoContent(context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              // videoItem.season?['title'] ?? videoItem.title ?? '',
              videoItem.title ?? '',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: videoItem.bvid != null && videoItem.bvid == bvid
                    ? FontWeight.bold
                    : null,
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                height: 1.42,
                letterSpacing: 0.3,
                color: videoItem.bvid != null && videoItem.bvid == bvid
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            videoItem.season != null
                ? Utils.dateFormat(videoItem.season?['mtime'])
                : videoItem.publishTimeText ?? '',
            maxLines: 1,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
              height: 1,
              color: Theme.of(context).colorScheme.outline,
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              statView(
                context: context,
                theme: 'gray',
                // view: videoItem.season?['view_content'] ??
                //     videoItem.viewContent,
                view: videoItem.viewContent,
              ),
              const SizedBox(width: 8),
              statDanMu(
                context: context,
                theme: 'gray',
                // danmu: videoItem.season?['danmaku'] ?? videoItem.danmaku,
                danmu: videoItem.danmaku,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
