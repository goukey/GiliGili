import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/remote_focus_service.dart';
import '../../utils/tv_mode_detector.dart';

/// 可聚焦组件包装器
/// 用于包装需要在TV模式下可聚焦的组件
class Focusable extends StatelessWidget {
  /// 唯一标识符，用于焦点管理
  final String id;
  
  /// 被包装的子组件
  final Widget child;
  
  /// 选择（确认）按钮回调
  final VoidCallback? onSelect;
  
  /// 长按回调
  final VoidCallback? onLongPress;
  
  /// 焦点边距
  final EdgeInsets focusPadding;
  
  /// 焦点颜色
  final Color? focusColor;
  
  /// 焦点边框宽度
  final double focusBorderWidth;
  
  /// 焦点边框圆角
  final double focusBorderRadius;
  
  /// 是否在获得焦点时放大
  final bool scaleOnFocus;
  
  /// 放大比例
  final double scaleFactor;
  
  /// 是否自动获取焦点
  final bool autofocus;
  
  /// 自定义焦点装饰
  final Widget Function(BuildContext, bool, Widget)? focusBuilder;

  const Focusable({
    Key? key,
    required this.id,
    required this.child,
    this.onSelect,
    this.onLongPress,
    this.focusPadding = const EdgeInsets.all(4.0),
    this.focusColor,
    this.focusBorderWidth = 2.0,
    this.focusBorderRadius = 4.0,
    this.scaleOnFocus = false,
    this.scaleFactor = 1.05,
    this.autofocus = false,
    this.focusBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果不是TV模式，直接返回原始子组件
    if (!TVModeDetector().isTVMode.value) {
      return child;
    }
    
    // 获取焦点服务
    final RemoteFocusService focusService;
    try {
      focusService = Get.find<RemoteFocusService>();
    } catch (e) {
      // 如果焦点服务不可用，直接返回原始子组件
      return child;
    }
    
    // 获取焦点节点
    final focusNode = focusService.getFocusNode(id);
    
    // 如果需要自动获取焦点
    if (autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
    }
    
    // 创建焦点组件
    return Focus(
      focusNode: focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (onSelect != null) {
              onSelect!();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: onSelect,
        onLongPress: onLongPress,
        child: Obx(() {
          final hasFocus = focusService.currentFocusId.value == id;
          
          // 如果提供了自定义焦点构建器，使用它
          if (focusBuilder != null) {
            return focusBuilder!(context, hasFocus, child);
          }
          
          // 默认焦点视觉效果
          Widget result = Container(
            decoration: hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: focusColor ?? Theme.of(context).colorScheme.primary,
                      width: focusBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(focusBorderRadius),
                  )
                : null,
            padding: hasFocus ? focusPadding : EdgeInsets.zero,
            child: child,
          );
          
          // 如果需要在获得焦点时放大
          if (scaleOnFocus) {
            result = AnimatedScale(
              scale: hasFocus ? scaleFactor : 1.0,
              duration: const Duration(milliseconds: 200),
              child: result,
            );
          }
          
          return result;
        }),
      ),
    );
  }
} 