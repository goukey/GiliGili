import 'package:GiliGili/common/widgets/interactiveviewer_gallery/interactiveviewer_gallery.dart'
    show SourceModel;
import 'package:GiliGili/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GiliGili/common/widgets/network_img_layer.dart';
import 'package:GiliGili/models/member/info.dart';
import 'package:GiliGili/utils/utils.dart';

class ProfilePanel extends StatelessWidget {
  final dynamic ctr;
  final bool loadingStatus;
  const ProfilePanel({
    super.key,
    required this.ctr,
    this.loadingStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    MemberInfoModel memberInfo = ctr.memberInfo.value;
    return Builder(
      builder: ((context) {
        return Row(
          children: [
            Hero(
              tag: !loadingStatus ? memberInfo.face : ctr.face.value,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => context.imageView(
                      imgList: [
                        SourceModel(
                          url:
                              !loadingStatus ? memberInfo.face : ctr.face.value,
                        )
                      ],
                    ),
                    child: NetworkImgLayer(
                      width: 90,
                      height: 90,
                      type: 'avatar',
                      src: !loadingStatus ? memberInfo.face : ctr.face.value,
                    ),
                  ),
                  if (!loadingStatus &&
                      memberInfo.liveRoom != null &&
                      memberInfo.liveRoom!.liveStatus == 1)
                    Positioned(
                      bottom: 0,
                      left: 14,
                      child: GestureDetector(
                        onTap: () {
                          // LiveItemModel liveItem = LiveItemModel.fromJson({
                          //   'title': memberInfo.liveRoom!.title,
                          //   'uname': memberInfo.name,
                          //   'face': memberInfo.face,
                          //   'roomid': memberInfo.liveRoom!.roomId,
                          //   'watched_show': memberInfo.liveRoom!.watchedShow,
                          // });
                          Get.toNamed(
                            '/liveRoom?roomid=${memberInfo.liveRoom!.roomId}',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(children: [
                            Image.asset(
                              'assets/images/live.gif',
                              height: 10,
                            ),
                            Text(
                              ' 直播中',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .fontSize),
                            )
                          ]),
                        ),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/follow?mid=${memberInfo.mid}&name=${memberInfo.name}');
                          },
                          child: Column(
                            children: [
                              Text(
                                !loadingStatus
                                    ? ctr.userStat!['following'].toString()
                                    : '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '关注',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/fan?mid=${memberInfo.mid}&name=${memberInfo.name}');
                          },
                          child: Column(
                            children: [
                              Text(
                                  !loadingStatus
                                      ? ctr.userStat!['follower'] != null
                                          ? Utils.numFormat(
                                              ctr.userStat!['follower'],
                                            )
                                          : '-'
                                      : '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '粉丝',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                            onTap: null,
                            child: Column(
                              children: [
                                Text(
                                    !loadingStatus
                                        ? ctr.userStat!['likes'] != null
                                            ? Utils.numFormat(
                                                ctr.userStat!['likes'],
                                              )
                                            : '-'
                                        : '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '获赞',
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .fontSize),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (ctr.ownerMid != ctr.mid && ctr.ownerMid != -1) ...[
                    Row(
                      children: [
                        Obx(
                          () => Expanded(
                            child: TextButton(
                              onPressed: () => ctr.actionRelationMod(context),
                              style: TextButton.styleFrom(
                                foregroundColor: ctr.attribute.value == -1
                                    ? Colors.transparent
                                    : ctr.attribute.value != 0
                                        ? Theme.of(context).colorScheme.outline
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                backgroundColor: ctr.attribute.value != 0
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              child: Obx(() => Text(ctr.attributeText.value)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(
                                '/whisperDetail',
                                parameters: {
                                  'talkerId': ctr.mid.toString(),
                                  'name': memberInfo.name!,
                                  'face': memberInfo.face!,
                                  'mid': ctr.mid.toString(),
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                            child: const Text('发消息'),
                          ),
                        )
                      ],
                    )
                  ],
                  if (ctr.ownerMid == ctr.mid && ctr.ownerMid != -1) ...[
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/webview', parameters: {
                          'url': 'https://account.bilibili.com/account/home',
                          'pageTitle': '个人中心（建议浏览器打开）',
                          'type': 'url'
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(' 个人中心(web) '),
                    )
                  ],
                  if (ctr.ownerMid == -1) ...[
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.outline,
                        backgroundColor:
                            Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      child: const Text(' 未登录 '),
                    )
                  ]
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
