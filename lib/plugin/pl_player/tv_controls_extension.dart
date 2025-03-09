import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import '../../utils/tv_mode_detector.dart';
import './index.dart';  // 导入原始播放器

/// 视频播放器的TV控制扩展
/// 用于处理遥控器对视频播放的控制
class TVPlayerControlsExtension {
  final PlPlayerController controller;
  FocusNode? _playerFocusNode;
  bool _isControlsVisible = false;
  Timer? _controlsVisibilityTimer;
  
  TVPlayerControlsExtension(this.controller);
  
  /// 设置TV控制
  void setupTVControls(BuildContext context) {
    if (!TVModeDetector().isTVMode.value) return;
    
    // 创建一个焦点节点专门用于视频播放器
    _playerFocusNode = FocusNode(debugLabel: 'VideoPlayer');
    
    // 监听键盘事件
    RawKeyboard.instance.addListener(_handlePlayerKeyEvent);
    
    // 在组件销毁时清理
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _playerFocusNode?.requestFocus();
        });
      }
    });
  }
  
  /// 清理资源
  void dispose() {
    if (_playerFocusNode != null) {
      RawKeyboard.instance.removeListener(_handlePlayerKeyEvent);
      _playerFocusNode!.dispose();
      _playerFocusNode = null;
    }
    _controlsVisibilityTimer?.cancel();
  }
  
  /// 处理播放器键盘事件
  void _handlePlayerKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || _playerFocusNode == null || !_playerFocusNode!.hasFocus) {
      return;
    }
    
    // 显示控制UI
    _showControls();
    
    // 播放/暂停
    if (event.logicalKey == LogicalKeyboardKey.select || 
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (controller.isPlaying.value) {
        controller.pause();
      } else {
        controller.play();
      }
    }
    
    // 快进
    else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _seekRelative(10);
      _showSeekToast(10);
    }
    
    // 快退
    else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _seekRelative(-10);
      _showSeekToast(-10);
    }
    
    // 音量增加
    else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _changeVolume(0.1);
      _showVolumeToast();
    }
    
    // 音量减少
    else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _changeVolume(-0.1);
      _showVolumeToast();
    }
    
    // 全屏切换
    else if (event.logicalKey == LogicalKeyboardKey.keyF) {
      controller.toggleFullScreen();
    }
    
    // 下一集
    else if (event.logicalKey == LogicalKeyboardKey.keyN) {
      controller.playNext();
    }
    
    // 上一集
    else if (event.logicalKey == LogicalKeyboardKey.keyP) {
      controller.playPrevious();
    }
  }
  
  /// 相对当前位置跳转
  void _seekRelative(int seconds) {
    final newPosition = controller.position.value + Duration(seconds: seconds);
    controller.seekTo(newPosition);
  }
  
  /// 调整音量
  void _changeVolume(double delta) {
    final newVolume = (controller.volume.value + delta).clamp(0.0, 1.0);
    controller.setVolume(newVolume);
  }
  
  /// 显示控制UI
  void _showControls() {
    _isControlsVisible = true;
    controller.showControls();
    
    // 设置定时器，自动隐藏控制UI
    _controlsVisibilityTimer?.cancel();
    _controlsVisibilityTimer = Timer(const Duration(seconds: 5), () {
      if (_isControlsVisible) {
        _isControlsVisible = false;
        controller.hideControls();
      }
    });
  }
  
  /// 显示跳转提示
  void _showSeekToast(int seconds) {
    final prefix = seconds > 0 ? "快进" : "快退";
    final absSeconds = seconds.abs();
    SmartDialog.showToast("$prefix ${absSeconds}秒");
  }
  
  /// 显示音量提示
  void _showVolumeToast() {
    final volumePercentage = (controller.volume.value * 100).toInt();
    SmartDialog.showToast("音量: $volumePercentage%");
  }
} 