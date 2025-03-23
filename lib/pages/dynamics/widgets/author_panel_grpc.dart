import 'package:PiliPlus/grpc/app/dynamic/v2/dynamic.pb.dart' as dyn;
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/utils.dart';

import '../../../http/constants.dart';
import '../controller.dart';

class AuthorPanelGrpc extends StatelessWidget {
  final dyn.DynamicItem item;
  final Function? addBannedList;
  final String? source;
  final Function? onRemove;
  const AuthorPanelGrpc({
    super.key,
    required this.item,
    this.addBannedList,
    this.source,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(item.modules.first.moduleAuthor.mid);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // 番剧
            // if (item.modules.first.moduleAuthor.type == 'AUTHOR_TYPE_PGC') {
            //   return;
            // }
            feedBack();
            Get.toNamed(
              '/member?mid=${item.modules.first.moduleAuthor.author.mid}',
              arguments: {
                'face': item.modules.first.moduleAuthor.author.face,
                'heroTag': heroTag
              },
            );
          },
          child: Hero(
            tag: heroTag,
            child: NetworkImgLayer(
              width: 40,
              height: 40,
              type: 'avatar',
              src: item.modules.first.moduleAuthor.author.face,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.modules.first.moduleAuthor.author.name,
                  // semanticsLabel: "UP主：${item.modules.moduleAuthor.name}",
                  style: TextStyle(
                    color: item.modules.first.moduleAuthor.author.vip.status >
                                0 &&
                            item.modules.first.moduleAuthor.author.vip.type == 2
                        ? context.vipColor
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  ),
                ),
              ],
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
              child: Row(
                children: [
                  // Text(item.modules.first.moduleAuthor.pubTime),
                  // if (item.modules.first.moduleAuthor.pubTime != '' &&
                  //     item.modules.first.moduleAuthor.pubAction != '')
                  //   const Text(' '),
                  // Text(item.modules.first.moduleAuthor.pubAction),
                ],
              ),
            )
          ],
        ),
        const Spacer(),
        // if (source != 'detail' && item.modules.first?.moduleTag?.text != null)
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        //     decoration: BoxDecoration(
        //       color: Theme.of(context).colorScheme.surface,
        //       borderRadius: const BorderRadius.all(Radius.circular(4)),
        //       border: Border.all(
        //         width: 1.25,
        //         color: Theme.of(context).colorScheme.primary,
        //       ),
        //     ),
        //     child: Text(
        //       item.modules.first.moduleTag.text,
        //       style: TextStyle(
        //         height: 1,
        //         fontSize: 12,
        //         color: Theme.of(context).colorScheme.primary,
        //       ),
        //       strutStyle: const StrutStyle(
        //         leading: 0,
        //         height: 1,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            tooltip: '更多',
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) {
                  return MorePanel(
                    item: item,
                    onRemove: onRemove,
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert_outlined, size: 18),
          ),
        ),
      ],
    );
  }
}

class MorePanel extends StatelessWidget {
  final dynamic item;
  final Function? onRemove;
  const MorePanel({
    super.key,
    required this.item,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      // clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          if (item.type == 'DYNAMIC_TYPE_AV')
            ListTile(
              onTap: () async {
                try {
                  String bvid = item.modules.moduleDynamic.major.archive.bvid;
                  var res = await UserHttp.toViewLater(bvid: bvid);
                  SmartDialog.showToast(res['msg']);
                  Get.back();
                } catch (err) {
                  SmartDialog.showToast('出错了：${err.toString()}');
                }
              },
              minLeadingWidth: 0,
              // dense: true,
              leading: const Icon(Icons.watch_later_outlined, size: 19),
              title: Text(
                '稍后再看',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ListTile(
            title: Text(
              '分享动态',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            leading: const Icon(Icons.share_outlined, size: 19),
            onTap: () {
              Get.back();
              Utils.shareText(
                  '${HttpString.dynamicShareBaseUrl}/${item.idStr}');
            },
            minLeadingWidth: 0,
          ),
          ListTile(
            title: Text(
              '临时屏蔽：${item.modules.moduleAuthor.name}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            leading: const Icon(Icons.visibility_off_outlined, size: 19),
            onTap: () {
              Get.back();
              DynamicsController dynamicsController =
                  Get.find<DynamicsController>();
              dynamicsController.tempBannedList
                  .add(item.modules.moduleAuthor.mid);
              SmartDialog.showToast(
                  '已临时屏蔽${item.modules.moduleAuthor.name}(${item.modules.moduleAuthor.mid})，重启恢复');
            },
            minLeadingWidth: 0,
          ),
          if (item.modules.moduleAuthor.mid ==
              GStorage.userInfo.get('userInfoCache')?.mid)
            ListTile(
              onTap: () async {
                Get.back();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('确定删除该动态?'),
                          actions: [
                            TextButton(
                              onPressed: Get.back,
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                onRemove?.call(item.idStr);
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ));
              },
              minLeadingWidth: 0,
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error, size: 19),
              title: Text('删除',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.error)),
            ),
          const Divider(thickness: 0.1, height: 1),
          ListTile(
            onTap: () => Get.back(),
            minLeadingWidth: 0,
            dense: true,
            title: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
