import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import './remote_focus_service.dart';
import '../utils/tv_mode_detector.dart';

/// 导航方向枚举
enum NavigationDirection {
  up,
  down,
  left,
  right,
}

/// 遥控器导航服务
/// 用于处理遥控器方向键导航
class RemoteNavigationService extends GetxService {
  late final RemoteFocusService _focusService;
  
  // 定义导航映射，记录每个元素的上下左右导航目标
  final Map<String, Map<NavigationDirection, String>> _navigationMap = {};
  
  bool get isTVMode => TVModeDetector().isTVMode.value;
  
  @override
  void onInit() {
    super.onInit();
    if (isTVMode) {
      _focusService = Get.find<RemoteFocusService>();
      // 添加全局键盘监听
      RawKeyboard.instance.addListener(_handleKeyEvent);
    }
  }
  
  /// 处理键盘事件
  void _handleKeyEvent(RawKeyEvent event) {
    if (!isTVMode || event is! RawKeyDownEvent) return;
    
    final currentFocusId = _focusService.currentFocusId.value;
    if (currentFocusId == null) return;
    
    NavigationDirection? direction;
    
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      direction = NavigationDirection.up;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      direction = NavigationDirection.down;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      direction = NavigationDirection.left;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      direction = NavigationDirection.right;
    }
    
    if (direction != null && _navigationMap.containsKey(currentFocusId)) {
      final targetId = _navigationMap[currentFocusId]![direction];
      if (targetId != null) {
        _focusService.navigateToFocusable(targetId);
      }
    }
  }
  
  /// 注册导航关系
  /// 设置从sourceId到targetId的direction方向导航
  void registerNavigation(String sourceId, NavigationDirection direction, String targetId) {
    if (!_navigationMap.containsKey(sourceId)) {
      _navigationMap[sourceId] = {};
    }
    _navigationMap[sourceId]![direction] = targetId;
  }
  
  /// 注册双向导航关系
  /// 同时设置从sourceId到targetId和从targetId到sourceId的导航
  void registerBidirectionalNavigation(
    String sourceId, 
    NavigationDirection direction, 
    String targetId
  ) {
    registerNavigation(sourceId, direction, targetId);
    
    NavigationDirection oppositeDirection;
    switch (direction) {
      case NavigationDirection.up:
        oppositeDirection = NavigationDirection.down;
        break;
      case NavigationDirection.down:
        oppositeDirection = NavigationDirection.up;
        break;
      case NavigationDirection.left:
        oppositeDirection = NavigationDirection.right;
        break;
      case NavigationDirection.right:
        oppositeDirection = NavigationDirection.left;
        break;
    }
    
    registerNavigation(targetId, oppositeDirection, sourceId);
  }
  
  /// 注册网格导航
  /// 为网格布局的元素自动设置导航关系
  void registerGridNavigation(List<String> ids, int columns) {
    if (ids.isEmpty || columns <= 0) return;
    
    final rows = (ids.length / columns).ceil();
    
    for (int i = 0; i < ids.length; i++) {
      final row = i ~/ columns;
      final col = i % columns;
      
      // 上方元素
      if (row > 0) {
        final upIndex = (row - 1) * columns + col;
        if (upIndex < ids.length) {
          registerBidirectionalNavigation(
            ids[i], 
            NavigationDirection.up, 
            ids[upIndex]
          );
        }
      }
      
      // 下方元素
      if (row < rows - 1) {
        final downIndex = (row + 1) * columns + col;
        if (downIndex < ids.length) {
          registerBidirectionalNavigation(
            ids[i], 
            NavigationDirection.down, 
            ids[downIndex]
          );
        }
      }
      
      // 左侧元素
      if (col > 0) {
        registerBidirectionalNavigation(
          ids[i], 
          NavigationDirection.left, 
          ids[i - 1]
        );
      }
      
      // 右侧元素
      if (col < columns - 1 && i + 1 < ids.length) {
        registerBidirectionalNavigation(
          ids[i], 
          NavigationDirection.right, 
          ids[i + 1]
        );
      }
    }
  }
  
  @override
  void onClose() {
    if (isTVMode) {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
    super.onClose();
  }
} 