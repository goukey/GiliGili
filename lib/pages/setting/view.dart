import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/pages/about/index.dart';
import 'package:PiliPlus/pages/setting/extra_setting.dart';
import 'package:PiliPlus/pages/setting/play_setting.dart';
import 'package:PiliPlus/pages/setting/privacy_setting.dart';
import 'package:PiliPlus/pages/setting/recommend_setting.dart';
import 'package:PiliPlus/pages/setting/style_setting.dart';
import 'package:PiliPlus/pages/setting/tv_mode_setting.dart';
import 'package:PiliPlus/pages/setting/video_setting.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/login.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../http/init.dart';

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
  final RxBool _isLogin = GStorage.isLogin.obs;
  TextStyle get _titleStyle => Theme.of(context).textTheme.titleMedium!;
  TextStyle get _subTitleStyle => Theme.of(context)
      .textTheme
      .labelMedium!
      .copyWith(color: Theme.of(context).colorScheme.outline);
  bool get _isPortrait => context.orientation == Orientation.portrait;

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
    _SettingsModel(
      name: 'tvModeSetting',
      title: 'TV模式设置',
      subtitle: '配置TV模式和遥控器支持',
      icon: MdiIcons.television,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'tvModeSetting' => 'TV模式设置',
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
                    'tvModeSetting' => const TVModeSetting(showAppBar: false),
                    _ => const SizedBox.shrink(),
                  },
                )
              ],
            ),
    );
  }

  void _toPage(String name) {
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
      children: [
        _buildSearchItem,
        ..._items.sublist(0, _items.length - 1).map(
              (item) => ListTile(
                tileColor: _getTileColor(item.name),
                onTap: () => _toPage(item.name),
                leading: Icon(item.icon),
                title: Text(item.title, style: _titleStyle),
                subtitle: item.subtitle == null
                    ? null
                    : Text(item.subtitle!, style: _subTitleStyle),
              ),
            ),
        _buildLoginItem,
        ListTile(
          tileColor: _getTileColor(_items.last.name),
          onTap: () => _toPage(_items.last.name),
          leading: Icon(_items.last.icon),
          title: Text(_items.last.title, style: _titleStyle),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 80),
      ],
    );
  }

  Widget get _buildLoginItem => Obx(
        () => _isLogin.value.not
            ? const SizedBox.shrink()
            : ListTile(
                leading: const Icon(Icons.logout_outlined),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('提示'),
                        content: const Text('确认要退出登录吗'),
                        actions: [
                          TextButton(
                            onPressed: Get.back,
                            child: Text(
                              '点错了',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          if (BuildConfig.isDebug)
                            TextButton(
                              onPressed: () {
                                Get.back();
                                _isLogin.value = false;
                                LoginUtils.onLogout();
                              },
                              child: Text(
                                '仅登出',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () async {
                              SmartDialog.showLoading();
                              dynamic res = await Request().post(
                                'https://passport.bilibili.com/login/exit/v2',
                                data: {
                                  'biliCSRF': await Request.getCsrf(),
                                },
                                options: Options(
                                  contentType:
                                      Headers.formUrlEncodedContentType,
                                ),
                              );
                              if (res.data['code'] == 0) {
                                await LoginUtils.onLogout();
                                _isLogin.value = false;
                                SmartDialog.dismiss();
                                Get.back();
                              } else {
                                SmartDialog.dismiss();
                                SmartDialog.showToast('${res.data['message']}');
                              }
                            },
                            child: const Text('确认'),
                          )
                        ],
                      );
                    },
                  );
                },
                title: Text('退出登录', style: _titleStyle),
              ),
      );

  Widget get _buildSearchItem => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
        child: InkWell(
          onTap: () => Get.toNamed('/settingsSearch'),
          borderRadius: BorderRadius.circular(50),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    size: MediaQuery.textScalerOf(context).scale(18),
                    Icons.search,
                  ),
                  const Text(' 搜索'),
                ],
              ),
            ),
          ),
        ),
      );
}
