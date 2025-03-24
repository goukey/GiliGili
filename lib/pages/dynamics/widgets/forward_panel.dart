// 转发
import 'package:GiliGili/common/widgets/badge.dart';
import 'package:GiliGili/common/widgets/image_save.dart';
import 'package:GiliGili/common/widgets/imageview.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:GiliGili/utils/utils.dart';

import '../../../models/dynamics/result.dart';
import 'additional_panel.dart';
import 'article_panel.dart';
import 'live_panel.dart';
import 'live_rcmd_panel.dart';
import 'pic_panel.dart';
import 'rich_node_panel.dart';
import 'video_panel.dart';

InlineSpan picsNodes(List<OpusPicsModel> pics, callback) {
  return WidgetSpan(
    child: LayoutBuilder(
      builder: (context, constraints) => imageview(
        constraints.maxWidth,
        pics
            .map(
              (item) => ImageModel(
                width: item.width,
                height: item.height,
                url: item.url ?? '',
                liveUrl: item.liveUrl,
              ),
            )
            .toList(),
        callback: callback,
      ),
    ),
  );
}

Widget forWard(item, BuildContext context, source, callback, {floor = 1}) {
  switch (item.type) {
    // 图文
    case 'DYNAMIC_TYPE_DRAW':
      bool hasPics = item.modules.moduleDynamic.major != null &&
          item.modules.moduleDynamic.major.opus != null &&
          item.modules.moduleDynamic.major.opus.pics.isNotEmpty;

      InlineSpan? richNodes = richNode(item, context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (floor == 2) ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(
                      '/member?mid=${item.modules.moduleAuthor.mid}',
                      arguments: {'face': item.modules.moduleAuthor.face}),
                  child: Text(
                    '@${item.modules.moduleAuthor.name}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  Utils.dateFormat(item.modules.moduleAuthor.pubTs),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize),
                ),
              ],
            ),
            const SizedBox(height: 2),

            /// fix #话题跟content重复
            // if (item.modules.moduleDynamic.topic != null) ...[
            //   Padding(
            //     padding: floor == 2
            //         ? EdgeInsets.zero
            //         : const EdgeInsets.only(left: 12, right: 12),
            //     child: GestureDetector(
            //       child: Text(
            //         '#${item.modules.moduleDynamic.topic.name}',
            //         style: authorStyle,
            //       ),
            //     ),
            //   ),
            // ],

            if (richNodes != null)
              Text.rich(
                richNodes,
                // 被转发状态(floor=2) 隐藏
                maxLines: source == 'detail' && floor != 2 ? null : 4,
                overflow: source == 'detail' && floor != 2
                    ? null
                    : TextOverflow.ellipsis,
              ),
            if (hasPics) ...[
              Text.rich(
                picsNodes(item.modules.moduleDynamic.major.opus.pics, callback),
                // semanticsLabel: '动态图片',
              ),
              // if (item.modules.moduleDynamic.additional != null)
              //   const SizedBox(height: 4),
            ],
            const SizedBox(height: 4),
          ],
          Padding(
            padding: floor == 2
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 12, right: 12),
            child: picWidget(item, context, callback),
          ),

          /// 附加内容 商品信息、直播预约等等
          if (item.modules.moduleDynamic.additional != null)
            addWidget(
              item,
              context,
              item.modules.moduleDynamic.additional.type,
              floor: floor,
            ),

          if (item.modules.moduleDynamic.major.blocked != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: 12, right: 12, bottom: source == 'detail' ? 8 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.modules.moduleDynamic.major.blocked['title'] != null)
                    Text(
                      item.modules.moduleDynamic.major.blocked['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  if (item.modules.moduleDynamic.major
                          .blocked['hint_message'] !=
                      null)
                    Text(
                      item.modules.moduleDynamic.major.blocked['hint_message'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    // 视频
    case 'DYNAMIC_TYPE_AV':
      return videoSeasonWidget(item, context, 'archive', floor: floor);
    // 文章
    case 'DYNAMIC_TYPE_ARTICLE':
      return switch (item) {
        DynamicItemModel() => item.isForwarded == true
            ? articlePanel(item, context, callback, floor: floor)
            : item.modules?.moduleDynamic?.major?.blocked != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.modules?.moduleDynamic?.major
                                ?.blocked?['title'] !=
                            null)
                          Text(
                            '${item.modules?.moduleDynamic?.major?.blocked!['title']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        if (item.modules?.moduleDynamic?.major
                                ?.blocked?['hint_message'] !=
                            null)
                          Text(
                            '${item.modules?.moduleDynamic?.major?.blocked!['hint_message']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
        _ => const SizedBox.shrink(),
      };
    // return Container(
    //     padding:
    //         const EdgeInsets.only(left: 10, top: 12, right: 10, bottom: 10),
    //     color: Theme.of(context).dividerColor.withOpacity(0.08),
    //     child: articlePanel(item, context, floor: floor));
    // 转发
    case 'DYNAMIC_TYPE_FORWARD':
      return InkWell(
        onTap: () {
          if (item.orig.modules.moduleDynamic.major?.type ==
              'MAJOR_TYPE_NONE') {
            return;
          }
          Utils.pushDynDetail(item.orig, floor + 1);
        },
        onLongPress: () {
          if (item.orig.modules.moduleDynamic.major?.type ==
              'MAJOR_TYPE_NONE') {
            return;
          }
          if (item.orig.type == 'DYNAMIC_TYPE_AV') {
            imageSaveDialog(
              context: context,
              title: item.orig.modules.moduleDynamic.major.archive.title,
              cover: item.orig.modules.moduleDynamic.major.archive.cover,
            );
          } else if (item.orig.type == 'DYNAMIC_TYPE_UGC_SEASON') {
            imageSaveDialog(
              context: context,
              title: item.orig.modules.moduleDynamic.major.ugcSeason.title,
              cover: item.orig.modules.moduleDynamic.major.ugcSeason.cover,
            );
          } else if (item.orig.type == 'DYNAMIC_TYPE_PGC' ||
              item.orig.type == 'DYNAMIC_TYPE_PGC_UNION') {
            imageSaveDialog(
              context: context,
              title: item.orig.modules.moduleDynamic.major.pgc.title,
              cover: item.orig.modules.moduleDynamic.major.pgc.cover,
            );
          } else if (item.type == 'DYNAMIC_TYPE_LIVE_RCMD') {
            imageSaveDialog(
              context: context,
              title: item.modules.moduleDynamic.major.liveRcmd.title,
              cover: item.modules.moduleDynamic.major.liveRcmd.cover,
            );
          } else if (item.type == 'DYNAMIC_TYPE_LIVE') {
            imageSaveDialog(
              context: context,
              title: item.modules.moduleDynamic.major.live.title,
              cover: item.modules.moduleDynamic.major.live.cover,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          child:
              forWard(item.orig, context, source, callback, floor: floor + 1),
        ),
      );
    // 直播
    case 'DYNAMIC_TYPE_LIVE_RCMD':
      return liveRcmdPanel(item, context, floor: floor);
    // 直播
    case 'DYNAMIC_TYPE_LIVE':
      return livePanel(item, context, floor: floor);
    // 合集
    case 'DYNAMIC_TYPE_UGC_SEASON':
      return videoSeasonWidget(item, context, 'ugcSeason');
    case 'DYNAMIC_TYPE_WORD':
      InlineSpan? richNodes = richNode(item, context);
      return floor == 2
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(
                          '/member?mid=${item.modules.moduleAuthor.mid}',
                          arguments: {'face': item.modules.moduleAuthor.face}),
                      child: Text(
                        '@${item.modules.moduleAuthor.name}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Utils.dateFormat(item.modules.moduleAuthor.pubTs),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (richNodes != null)
                  Text.rich(
                    richNodes,
                    // 被转发状态(floor=2) 隐藏
                    maxLines: source == 'detail' && floor != 2 ? null : 4,
                    overflow: source == 'detail' && floor != 2
                        ? null
                        : TextOverflow.ellipsis,
                  ),
              ],
            )
          : item.modules.moduleDynamic.additional != null
              ? addWidget(
                  item,
                  context,
                  item.modules.moduleDynamic.additional.type,
                  floor: floor,
                )
              : const SizedBox(height: 0);
    case 'DYNAMIC_TYPE_PGC':
      return videoSeasonWidget(item, context, 'pgc', floor: floor);
    case 'DYNAMIC_TYPE_PGC_UNION':
      return videoSeasonWidget(item, context, 'pgc', floor: floor);
    // 直播结束
    case 'DYNAMIC_TYPE_NONE':
      return Row(
        children: [
          const Icon(
            FontAwesomeIcons.ghost,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(item.modules.moduleDynamic.major.none.tips)
        ],
      );
    // 课堂
    case 'DYNAMIC_TYPE_COURSES_SEASON':
      return Row(
        children: [
          Expanded(
            child: Text(
              "课堂💪：${item.modules.moduleDynamic.major.courses['title']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      );
    // 活动
    case 'DYNAMIC_TYPE_COMMON_SQUARE':
      return InkWell(
        onTap: () {
          try {
            String url = item.modules.moduleDynamic.major.common['jump_url'];
            if (url.contains('bangumi/play') && Utils.viewPgcFromUri(url)) {
              return;
            }
            Utils.handleWebview(url, inApp: true);
          } catch (_) {}
        },
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          child: Row(
            children: [
              NetworkImgLayer(
                type: 'cover',
                radius: 8,
                width: 45,
                height: 45,
                src: item.modules.moduleDynamic.major.common['cover'],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.modules.moduleDynamic.major.common['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.modules.moduleDynamic.major.common['desc'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MUSIC':
      final Map music = item.modules.moduleDynamic.major.music;
      return InkWell(
        onTap: () {
          Utils.handleWebview("https:${music['jump_url']}");
        },
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          child: Row(
            children: [
              NetworkImgLayer(
                type: 'cover',
                radius: 8,
                width: 45,
                height: 45,
                src: music['cover'],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music['title'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    music['label'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MEDIALIST':
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (floor == 2) ...[
            GestureDetector(
              onTap: () {
                Get.toNamed(
                  '/member?mid=${item.modules.moduleAuthor.mid}',
                );
              },
              child: Row(
                children: [
                  NetworkImgLayer(
                    width: 28,
                    height: 28,
                    type: 'avatar',
                    src: item.modules.moduleAuthor.face,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.modules.moduleAuthor.name,
                    style: TextStyle(
                      color: item.modules.moduleAuthor!.vip != null &&
                              item.modules.moduleAuthor!.vip['status'] > 0 &&
                              item.modules.moduleAuthor!.vip['type'] == 2
                          ? context.vipColor
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize:
                          Theme.of(context).textTheme.titleMedium!.fontSize,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (floor == 1) const SizedBox(width: 12),
              Stack(
                children: [
                  Hero(
                    tag: item.modules.moduleDynamic.major.medialist['cover'],
                    child: NetworkImgLayer(
                      width: 180,
                      height: 110,
                      src: item.modules.moduleDynamic.major.medialist['cover'],
                    ),
                  ),
                  if (item.modules.moduleDynamic.major.medialist['badge']
                          ?['text'] !=
                      null)
                    PBadge(
                      right: 6,
                      top: 6,
                      text: item.modules.moduleDynamic.major.medialist['badge']
                          ['text'],
                    )
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.modules.moduleDynamic.major.medialist['title'],
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .fontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      if (item.modules.moduleDynamic.major
                              .medialist['sub_title'] !=
                          null) ...[
                        const Spacer(),
                        Text(
                          item.modules.moduleDynamic.major
                              .medialist['sub_title'],
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (floor == 1) const SizedBox(width: 12),
            ],
          ),
        ],
      );

    default:
      return const SizedBox(
        width: double.infinity,
        child: Text('🙏 暂未支持的类型，请联系开发者反馈 '),
      );
  }
}
