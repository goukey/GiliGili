import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/focusable.dart';
import 'package:PiliPlus/services/remote_navigation_service.dart';
import 'package:PiliPlus/utils/tv_mode_detector.dart';
import 'action_item.dart';

/// TV模式下的ActionItem包装器
/// 使ActionItem支持遥控器操作
class TVActionItem extends StatelessWidget {
  final String id;
  final Icon icon;
  final Icon? selectIcon;
  final Function? onTap;
  final Function? onLongPress;
  final bool? loadingStatus;
  final String? text;
  final bool selectStatus;
  final String semanticsLabel;
  final bool needAnim;
  final bool hasTriple;
  final Function? callBack;
  final bool? expand;

  const TVActionItem({
    Key? key,
    required this.id,
    required this.icon,
    this.selectIcon,
    this.onTap,
    this.onLongPress,
    this.loadingStatus,
    this.text,
    this.selectStatus = false,
    this.needAnim = false,
    this.hasTriple = false,
    this.callBack,
    required this.semanticsLabel,
    this.expand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果不是TV模式，直接返回原始ActionItem
    if (!TVModeDetector().isTVMode.value) {
      return ActionItem(
        key: key,
        icon: icon,
        selectIcon: selectIcon,
        onTap: onTap,
        onLongPress: onLongPress,
        loadingStatus: loadingStatus,
        text: text,
        selectStatus: selectStatus,
        needAnim: needAnim,
        hasTriple: hasTriple,
        callBack: callBack,
        semanticsLabel: semanticsLabel,
        expand: expand,
      );
    }

    // TV模式下，使用Focusable包装ActionItem
    return Focusable(
      id: id,
      onSelect: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      scaleOnFocus: true,
      child: ActionItem(
        key: key,
        icon: icon,
        selectIcon: selectIcon,
        onTap: onTap,
        onLongPress: onLongPress,
        loadingStatus: loadingStatus,
        text: text,
        selectStatus: selectStatus,
        needAnim: needAnim,
        hasTriple: hasTriple,
        callBack: callBack,
        semanticsLabel: semanticsLabel,
        expand: expand,
      ),
    );
  }

  /// 注册操作按钮之间的导航关系
  static void registerActionItemsNavigation(List<String> actionIds) {
    if (!TVModeDetector().isTVMode.value || actionIds.isEmpty) return;

    try {
      final navService = Get.find<RemoteNavigationService>();
      
      // 注册左右导航关系
      for (int i = 0; i < actionIds.length - 1; i++) {
        navService.registerBidirectionalNavigation(
          actionIds[i],
          NavigationDirection.right,
          actionIds[i + 1],
        );
      }
    } catch (e) {
      print('Failed to register action items navigation: $e');
    }
  }
} 