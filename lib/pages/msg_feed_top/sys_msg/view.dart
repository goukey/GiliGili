import 'dart:convert';

import 'package:PiliPlus/common/widgets/loading_widget.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SysMsgPage extends StatefulWidget {
  const SysMsgPage({super.key});

  @override
  State<SysMsgPage> createState() => _SysMsgPageState();
}

class _SysMsgPageState extends State<SysMsgPage> {
  late final _sysMsgController = Get.put(SysMsgController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统通知'),
      ),
      body: refreshIndicator(
        onRefresh: () async {
          await _sysMsgController.onRefresh();
        },
        child: Obx(() => _buildBody(_sysMsgController.loadingState.value)),
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? ListView.separated(
              itemCount: loadingState.response.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 80),
              itemBuilder: (context, int index) {
                if (index == loadingState.response.length - 1) {
                  _sysMsgController.onLoadMore();
                }

                String? content = loadingState.response[index].content;
                if (content != null) {
                  try {
                    dynamic jsonContent = json.decode(content);
                    if (jsonContent != null && jsonContent['web'] != null) {
                      content = jsonContent['web'];
                    }
                  } catch (_) {}
                }
                return ListTile(
                  onTap: () {},
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('确定删除该通知?'),
                              actions: [
                                TextButton(
                                  onPressed: Get.back,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    _sysMsgController.onRemove(
                                      loadingState.response[index].id,
                                      index,
                                    );
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            ));
                  },
                  title: Text(
                    "${loadingState.response[index].title}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text.rich(
                        _buildContent(content ?? ''),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          "${loadingState.response[index].timeAt}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  indent: 72,
                  endIndent: 20,
                  height: 6,
                  color: Colors.grey.withOpacity(0.1),
                );
              },
            )
          : scrollErrorWidget(callback: _sysMsgController.onReload),
      Error() => scrollErrorWidget(
          errMsg: loadingState.errMsg,
          callback: _sysMsgController.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }

  InlineSpan _buildContent(String content) {
    final List<InlineSpan> spanChildren = <InlineSpan>[];
    RegExp urlRegExp = RegExp(
        r'#\{([^}]*)\}\{([^}]*)\}|https?:\/\/[^\s/\$.?#].[^\s]*|www\.[^\s/\$.?#].[^\s]*|【(.*?)】');
    content.splitMapJoin(
      urlRegExp,
      onMatch: (Match match) {
        String matchStr = match[0]!;
        if (matchStr.startsWith('#')) {
          spanChildren.add(
            TextSpan(
              text: match[1],
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  try {
                    PiliScheme.routePushFromUrl(match[2]!.replaceAll('"', ''));
                  } catch (err) {
                    SmartDialog.showToast(err.toString());
                  }
                },
            ),
          );
        } else if (matchStr.startsWith('【')) {
          try {
            bool isBV = match[3]?.startsWith('BV') == true;
            // validate
            if (isBV) {
              IdUtils.bv2av(match[3]!);
            } else {
              IdUtils.av2bv(int.parse(match[3]!));
            }
            spanChildren.add(TextSpan(text: '【'));
            spanChildren.add(
              TextSpan(
                text: match[3],
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    try {
                      PiliScheme.routePushFromUrl(match[3]!);
                    } catch (err) {
                      SmartDialog.showToast(err.toString());
                    }
                  },
              ),
            );
            spanChildren.add(TextSpan(text: '】'));
          } catch (e) {
            spanChildren.add(
              TextSpan(text: match[0]),
            );
          }
        } else {
          spanChildren.add(
            TextSpan(
              text: '\u{1F517}网页链接',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  try {
                    PiliScheme.routePushFromUrl(match[0]!);
                  } catch (err) {
                    SmartDialog.showToast(err.toString());
                    Utils.copyText(match[0] ?? '');
                  }
                },
            ),
          );
        }
        return '';
      },
      onNonMatch: (String nonMatchStr) {
        spanChildren.add(
          TextSpan(text: nonMatchStr),
        );
        return '';
      },
    );
    return TextSpan(children: spanChildren);
  }
}
