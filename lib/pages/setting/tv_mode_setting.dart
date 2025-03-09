import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/tv_mode_detector.dart';

/// TV模式设置页面
/// 允许用户启用或禁用TV模式
class TVModeSetting extends StatefulWidget {
  const TVModeSetting({Key? key}) : super(key: key);

  @override
  State<TVModeSetting> createState() => _TVModeSettingState();
}

class _TVModeSettingState extends State<TVModeSetting> {
  late Box setting;
  final RxBool _enableTVMode = false.obs;
  final RxBool _autoDetectTVMode = true.obs;
  
  @override
  void initState() {
    super.initState();
    setting = GStorage.setting;
    _enableTVMode.value = setting.get(SettingBoxKey.enableTVMode, defaultValue: false);
    _autoDetectTVMode.value = setting.get(SettingBoxKey.autoDetectTVMode, defaultValue: true);
  }
  
  void _setEnableTVMode(bool value) {
    _enableTVMode.value = value;
    setting.put(SettingBoxKey.enableTVMode, value);
    
    // 显示重启提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存，重启应用后生效'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  void _setAutoDetectTVMode(bool value) {
    _autoDetectTVMode.value = value;
    setting.put(SettingBoxKey.autoDetectTVMode, value);
    
    // 如果禁用自动检测，则启用手动设置
    if (!value && !_enableTVMode.value) {
      _setEnableTVMode(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV模式设置'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('TV模式说明'),
            subtitle: Text('TV模式下将优化界面布局和交互方式，使应用更适合在电视上使用，支持遥控器操作'),
          ),
          const Divider(),
          Obx(
            () => SwitchListTile(
              title: const Text('自动检测TV设备'),
              subtitle: const Text('自动检测当前设备是否为TV，并启用相应模式'),
              value: _autoDetectTVMode.value,
              onChanged: _setAutoDetectTVMode,
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: const Text('手动启用TV模式'),
              subtitle: const Text('强制启用TV模式，适用于自动检测失败的情况'),
              value: _enableTVMode.value,
              onChanged: !_autoDetectTVMode.value ? _setEnableTVMode : null,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('当前状态'),
            subtitle: Obx(() => Text(
                  TVModeDetector().isTVMode.value
                      ? '已启用TV模式'
                      : '未启用TV模式',
                  style: TextStyle(
                    color: TVModeDetector().isTVMode.value
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                )),
          ),
          const Divider(),
          const ListTile(
            title: Text('TV模式操作说明'),
            subtitle: Text(
              '方向键：导航\n'
              '确认键：选择/点击\n'
              '返回键：返回上一级\n'
              '播放器中：\n'
              '左右键：快退/快进\n'
              '上下键：音量调节\n'
              '确认键：播放/暂停\n',
            ),
          ),
        ],
      ),
    );
  }
} 