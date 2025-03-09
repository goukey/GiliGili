import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/tv_mode_detector.dart';

/// 遥控器焦点管理服务
/// 用于管理TV模式下的焦点系统
class RemoteFocusService extends GetxService {
  final FocusNode rootFocusNode = FocusNode(debugLabel: 'Root');
  final Map<String, FocusNode> focusNodes = {};
  final Rx<String?> currentFocusId = Rx<String?>(null);
  
  bool get isTVMode => TVModeDetector().isTVMode.value;

  @override
  void onInit() {
    super.onInit();
    if (isTVMode) {
      rootFocusNode.requestFocus();
    }
  }

  /// 获取指定ID的焦点节点
  /// 如果不存在则创建一个新的
  FocusNode getFocusNode(String id) {
    if (!focusNodes.containsKey(id)) {
      focusNodes[id] = FocusNode(debugLabel: id);
      focusNodes[id]!.addListener(() {
        if (focusNodes[id]!.hasFocus) {
          currentFocusId.value = id;
        }
      });
    }
    return focusNodes[id]!;
  }

  /// 导航到指定ID的可聚焦元素
  void navigateToFocusable(String id) {
    if (focusNodes.containsKey(id)) {
      focusNodes[id]!.requestFocus();
    }
  }

  /// 设置初始焦点
  void setInitialFocus(String id) {
    if (isTVMode && focusNodes.containsKey(id)) {
      Future.microtask(() {
        focusNodes[id]!.requestFocus();
      });
    }
  }

  @override
  void onClose() {
    for (var node in focusNodes.values) {
      node.dispose();
    }
    rootFocusNode.dispose();
    super.onClose();
  }
} 