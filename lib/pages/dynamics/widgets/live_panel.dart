import 'package:GiliGili/common/widgets/image_save.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/utils/utils.dart';

import 'rich_node_panel.dart';

Widget livePanel(item, context, {floor = 1}) {
  dynamic content = item.modules.moduleDynamic.major;
  late final TextStyle authorStyle =
      TextStyle(color: Theme.of(context).colorScheme.primary);
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
                style: authorStyle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              Utils.dateFormat(item.modules.moduleAuthor.pubTs),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
            ),
          ],
        ),
      ],
      const SizedBox(height: 4),
      if (item.modules.moduleDynamic.topic != null) ...[
        Padding(
          padding: floor == 2
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 12, right: 12),
          child: GestureDetector(
            child: Text(
              '#${item.modules.moduleDynamic.topic.name}',
              style: authorStyle,
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
      if (floor == 2 && item.modules.moduleDynamic.desc != null) ...[
        if (richNodes != null) Text.rich(richNodes),
        const SizedBox(height: 6),
      ],
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.toNamed('/liveRoom?roomid=${content.live?.id}');
        },
        onLongPress: () {
          Feedback.forLongPress(context);
          imageSaveDialog(
            context: context,
            title: content.live.title,
            cover: content.live.cover,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImgLayer(
              width: 120,
              height: 75,
              src: content.live.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    content.live.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.live.descFirst,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                    ),
                  )
                ],
              ),
            ),
            Text(
              content.live.badge['text'],
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
              ),
            )
          ],
        ),
      ),
    ],
  );
}
