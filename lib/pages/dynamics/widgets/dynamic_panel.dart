import 'package:GiliGili/common/widgets/image_save.dart';
import 'package:GiliGili/utils/extension.dart';
import 'package:GiliGili/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'action_panel.dart';
import 'author_panel.dart';
import 'content_panel.dart';
import 'forward_panel.dart';

class DynamicPanel extends StatelessWidget {
  final dynamic item;
  final String? source;
  final Function? onRemove;
  final Function(List<String>, int)? callback;

  const DynamicPanel({
    required this.item,
    this.source,
    this.onRemove,
    this.callback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: source == 'detail'
      //     ? const EdgeInsets.only(bottom: 12)
      //     : EdgeInsets.zero,
      decoration: source == 'detail' &&
              Get.context!.orientation == Orientation.landscape
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 8,
                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                ),
              ),
            ),
      child: Material(
        elevation: 0,
        // clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(5),
        // ),
        child: InkWell(
          onTap: source == 'detail' &&
                  [
                    'DYNAMIC_TYPE_AV',
                    'DYNAMIC_TYPE_UGC_SEASON',
                    'DYNAMIC_TYPE_PGC_UNION',
                    'DYNAMIC_TYPE_PGC',
                    'DYNAMIC_TYPE_LIVE',
                    'DYNAMIC_TYPE_LIVE_RCMD',
                    'DYNAMIC_TYPE_MEDIALIST',
                  ].contains(item.type).not
              ? null
              : () => Utils.pushDynDetail(item, 1),
          onLongPress: () {
            if (item.type == 'DYNAMIC_TYPE_AV') {
              imageSaveDialog(
                context: context,
                title: item.modules.moduleDynamic.major.archive.title,
                cover: item.modules.moduleDynamic.major.archive.cover,
              );
            } else if (item.type == 'DYNAMIC_TYPE_UGC_SEASON') {
              imageSaveDialog(
                context: context,
                title: item.modules.moduleDynamic.major.ugcSeason.title,
                cover: item.modules.moduleDynamic.major.ugcSeason.cover,
              );
            } else if (item.type == 'DYNAMIC_TYPE_PGC' ||
                item.type == 'DYNAMIC_TYPE_PGC_UNION') {
              imageSaveDialog(
                context: context,
                title: item.modules.moduleDynamic.major.pgc.title,
                cover: item.modules.moduleDynamic.major.pgc.cover,
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
          child: (item.modules.moduleAuthor?.pendant?['image'] as String?)
                      ?.isNotEmpty ==
                  true
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildContent(context, item, source, callback),
                    Positioned(
                      left: 2,
                      top: 2,
                      child: IgnorePointer(
                        child: CachedNetworkImage(
                          width: 60,
                          height: 60,
                          imageUrl: item.modules.moduleAuthor.pendant['image'],
                        ),
                      ),
                    ),
                  ],
                )
              : _buildContent(context, item, source, callback),
        ),
      ),
    );
  }

  Widget _buildContent(context, item, source, callback) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: AuthorPanel(
              item: item,
              source: source,
              onRemove: onRemove,
            ),
          ),
          if (item!.modules!.moduleDynamic!.desc != null ||
              item!.modules!.moduleDynamic!.major != null)
            content(context, item, source, callback),
          forWard(item, context, source, callback),
          const SizedBox(height: 2),
          if (source == null) ActionPanel(item: item),
          if (source == 'detail') const SizedBox(height: 12),
        ],
      );
}
