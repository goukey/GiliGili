import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/storage.dart';

/// TV模式检测器
/// 用于检测当前设备是否为AndroidTV，并提供相关配置
class TVModeDetector {
  static final _instance = TVModeDetector._internal();
  factory TVModeDetector() => _instance;
  TVModeDetector._internal();

  final RxBool isTVMode = false.obs;
  final methodChannel = const MethodChannel('com.gili.tv_detector');

  /// 初始化TV模式检测
  Future<void> initialize() async {
    // 检查是否手动启用TV模式
    final bool enableTVMode = GStorage.setting.get(SettingBoxKey.enableTVMode, defaultValue: false);
    final bool autoDetectTVMode = GStorage.setting.get(SettingBoxKey.autoDetectTVMode, defaultValue: true);
    
    // 如果手动启用且不自动检测，直接设置为TV模式
    if (enableTVMode && !autoDetectTVMode) {
      isTVMode.value = true;
      await _setupTVModeOrientation();
      _setupTVModeSettings();
      return;
    }
    
    // 否则，尝试自动检测
    if (Platform.isAndroid) {
      try {
        // 尝试通过平台通道检测是否为TV设备
        final bool isTV = await methodChannel.invokeMethod('isTVDevice');
        isTVMode.value = isTV;
        
        if (isTV) {
          await _setupTVModeOrientation();
          _setupTVModeSettings();
        }
      } catch (e) {
        // 如果无法通过平台通道检测，尝试使用备用方法
        _detectTVModeByFallback();
        print('Failed to detect TV mode via method channel: $e');
      }
    }
  }

  /// 设置TV模式下的屏幕方向
  Future<void> _setupTVModeOrientation() async {
    // 强制横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 备用方法检测TV模式
  void _detectTVModeByFallback() {
    try {
      // 可以通过检查是否存在某些TV特有的系统属性来判断
      // 这里我们简单地设置为false，实际应用中可以添加更复杂的检测逻辑
      isTVMode.value = false;
      
      // 开发测试时可以手动启用TV模式
      // isTVMode.value = true;
    } catch (e) {
      print('Failed to detect TV mode by fallback: $e');
      isTVMode.value = false;
    }
  }

  /// 设置TV模式下的特殊配置
  void _setupTVModeSettings() {
    // 在TV模式下可能需要的特殊设置
    // 例如调整UI缩放、禁用某些移动端特有功能等
  }
} 