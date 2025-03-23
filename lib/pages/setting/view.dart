import 'package:PiliPlus/http/login.dart';
import 'package:PiliPlus/pages/about/index.dart';
import 'package:PiliPlus/pages/login/controller.dart';
import 'package:PiliPlus/pages/setting/extra_setting.dart';
import 'package:PiliPlus/pages/setting/play_setting.dart';
import 'package:PiliPlus/pages/setting/privacy_setting.dart';
import 'package:PiliPlus/pages/setting/recommend_setting.dart';
import 'package:PiliPlus/pages/setting/style_setting.dart';
import 'package:PiliPlus/pages/setting/video_setting.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/tv_focus_utils.dart';
import 'package:PiliPlus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'widgets/multi_select_dialog.dart';

class _SettingsModel {
  final String name;
  final String title;
  final String? subtitle;
  final IconData icon;

  const _SettingsModel({
    required this.name,
    required this.title,
    this.subtitle,
    required this.icon,
  });
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late String _type = 'privacySetting';
  final RxBool _noAccount = Accounts.accountMode.isEmpty.obs;
  TextStyle get _titleStyle => Theme.of(context).textTheme.titleMedium!.copyWith(
    fontSize: 16 * TvConfig.fontSizeScale,
  );
  TextStyle get _subTitleStyle => Theme.of(context)
      .textTheme
      .labelMedium!
      .copyWith(
        color: Theme.of(context).colorScheme.outline,
        fontSize: 14 * TvConfig.fontSizeScale,
      );
  bool get _isPortrait => context.orientation == Orientation.portrait;

  // TV平台焦点控制
  final List<FocusNode> _focusNodes = [];
  final ScrollController _scrollController = ScrollController();

  final List<_SettingsModel> _items = [
    _SettingsModel(
      name: 'privacySetting',
      title: '隐私设置',
      subtitle: '黑名单、无痕模式',
      icon: Icons.privacy_tip_outlined,
    ),
    _SettingsModel(
      name: 'recommendSetting',
      title: '推荐流设置',
      subtitle: '推荐来源（web/app）、刷新保留内容、过滤器',
      icon: Icons.explore_outlined,
    ),
    _SettingsModel(
      name: 'videoSetting',
      title: '音视频设置',
      subtitle: '画质、音质、解码、缓冲、音频输出等',
      icon: Icons.video_settings_outlined,
    ),
    _SettingsModel(
      name: 'playSetting',
      title: '播放器设置',
      subtitle: '双击/长按、全屏、后台播放、弹幕、字幕、底部进度条等',
      icon: Icons.touch_app_outlined,
    ),
    _SettingsModel(
      name: 'styleSetting',
      title: '外观设置',
      subtitle: '横屏适配（平板）、侧栏、列宽、首页、动态红点、主题、字号、图片、帧率等',
      icon: Icons.style_outlined,
    ),
    _SettingsModel(
      name: 'extraSetting',
      title: '其它设置',
      subtitle: '震动、搜索、收藏、ai、评论、动态、代理、更新检查等',
      icon: Icons.extension_outlined,
    ),
    _SettingsModel(
      name: 'about',
      title: '关于',
      icon: Icons.info_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 为每个设置项创建FocusNode
    _focusNodes.clear();
    for (int i = 0; i < _items.length + 2; i++) {
      _focusNodes.add(TvFocusUtils.createFocusNode());
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: _isPortrait
              ? const Text('设置')
              : Text(switch (_type) {
                  'privacySetting' => '隐私设置',
                  'recommendSetting' => '推荐流设置',
                  'videoSetting' => '音视频设置',
                  'playSetting' => '播放器设置',
                  'styleSetting' => '外观设置',
                  'extraSetting' => '其它设置',
                  'about' => '关于',
                  _ => '设置',
                }),
        ),
        body: _isPortrait
            ? _buildList
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 40, child: _buildList),
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                  Expanded(
                    flex: 60,
                    child: switch (_type) {
                      'privacySetting' => PrivacySetting(showAppBar: false),
                      'recommendSetting' => RecommendSetting(showAppBar: false),
                      'videoSetting' => VideoSetting(showAppBar: false),
                      'playSetting' => PlaySetting(showAppBar: false),
                      'styleSetting' => StyleSetting(showAppBar: false),
                      'extraSetting' => ExtraSetting(showAppBar: false),
                      'about' => AboutPage(showAppBar: false),
                      _ => const SizedBox.shrink(),
                    },
                  )
                ],
              ),
      ),
    );
  }

  // 处理遥控器按键事件
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // 向下导航
        _scrollController.animateTo(
          _scrollController.offset + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // 向上导航
        _scrollController.animateTo(
          (_scrollController.offset - 80).clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _toPage(String name) {
    feedBack();
    if (_isPortrait) {
      Get.toNamed('/$name');
    } else {
      _type = name;
      setState(() {});
    }
  }

  Color? _getTileColor(String name) {
    if (_isPortrait) {
      return null;
    } else {
      return name == _type
          ? Theme.of(context).colorScheme.onInverseSurface
          : null;
    }
  }

  Widget get _buildList {
    return ListView(
      controller: _scrollController,
      children: [
        _buildSearchItem,
        ..._items.sublist(0, _items.length - 1).asMap().entries.map(
              (entry) {
                final int index = entry.key;
                final item = entry.value;
                return TvFocusable(
                  focusNode: _focusNodes[index],
                  autoFocus: index == 0,
                  onTap: () => _toPage(item.name),
                  child: ListTile(
                    tileColor: _getTileColor(item.name),
                    leading: Icon(item.icon),
                    title: Text(item.title, style: _titleStyle),
                    subtitle: item.subtitle == null
                        ? null
                        : Text(item.subtitle!, style: _subTitleStyle),
                  ),
                );
              },
            ),
        TvFocusable(
          focusNode: _focusNodes[_items.length - 1],
          onTap: () => LoginPageController.switchAccountDialog(context),
          child: ListTile(
            leading: const Icon(Icons.switch_account_outlined),
            title: Text('设置账号模式', style: _titleStyle),
          ),
        ),
        Obx(
          () => _noAccount.value
              ? const SizedBox.shrink()
              : TvFocusable(
                  focusNode: _focusNodes[_items.length],
                  onTap: () => _logoutDialog(context),
                  child: ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: Text('退出登录', style: _titleStyle),
                  ),
                ),
        ),
        TvFocusable(
          focusNode: _focusNodes[_items.length + 1],
          onTap: () => _toPage(_items.last.name),
          child: ListTile(
            tileColor: _getTileColor(_items.last.name),
            leading: Icon(_items.last.icon),
            title: Text(_items.last.title, style: _titleStyle),
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 80),
      ],
    );
  }

  Future<void> _logoutDialog(BuildContext context) async {
    feedBack();
    final result = await showDialog<Set<LoginAccount>>(
      context: context,
      builder: (context) {
        return MultiSelectDialog<LoginAccount>(
          title: '选择要登出的账号uid',
          initValues: Iterable.empty(),
          values: {for (var i in Accounts.account.values) i: i.mid.toString()},
        );
      },
    );
    if (!context.mounted || result.isNullOrEmpty) return;
    Future<void> logout() {
      _noAccount.value = result!.length == Accounts.account.length;
      return Accounts.deleteAll(result);
    }

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('提示'),
            content: Text(
                "确认要退出以下账号登录吗\n\n${result!.map((i) => i.mid.toString()).join('\n')}"),
            actions: [
              TvFocusable(
                onTap: Get.back,
                child: TextButton(
                  onPressed: () {
                    feedBack();
                    Get.back();
                  },
                  child: Text(
                    '点错了',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
              TvFocusable(
                onTap: () {
                  feedBack();
                  Get.back();
                  logout();
                },
                child: TextButton(
                  onPressed: null,
                  child: Text(
                    '仅登出',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
              TvFocusable(
                onTap: () async {
                  feedBack();
                  SmartDialog.showLoading();
                  final res = await LoginHttp.logout(Accounts.main);
                  if (res['status']) {
                    SmartDialog.dismiss();
                    logout();
                    Get.back();
                  } else {
                    SmartDialog.dismiss();
                    SmartDialog.showToast(res['msg']);
                  }
                },
                child: TextButton(
                  onPressed: null,
                  child: Text('登出并通知服务器'),
                ),
              ),
            ],
          );
        });
  }

  Widget get _buildSearchItem {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TvFocusable(
        onTap: () => Get.toNamed('/searchPage'),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            children: [
              Icon(Icons.search),
              SizedBox(width: 10),
              Text('搜索设置'),
            ],
          ),
        ),
      ),
    );
  }
}
