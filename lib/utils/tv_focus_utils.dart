import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GiliGili/main.dart';

/// TV平台焦点导航工具类
class TvFocusUtils {
  /// 创建一个用于TV平台焦点导航的FocusNode
  /// 
  /// [onKey] 按键事件回调
  /// [onFocusChange] 焦点变化回调
  static FocusNode createFocusNode({
    ValueChanged<bool>? onFocusChange,
    KeyEventResult Function(FocusNode, RawKeyEvent)? onKey,
  }) {
    return FocusNode(
      onKeyEvent: onKey != null 
        ? (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          }
        : null,
      debugLabel: 'TvFocusNode',
    )..addListener(() {
        if (onFocusChange != null) {
          onFocusChange(FocusScope.of(TvFocusUtils._buildContext!).hasFocus);
        }
      });
  }

  static BuildContext? _buildContext;
  
  static void setBuildContext(BuildContext context) {
    _buildContext = context;
  }

  /// 默认的按键处理函数，处理方向键导航和确认键操作
  static KeyEventResult _defaultOnKey(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      return KeyEventResult.handled;
    }
    
    if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      return KeyEventResult.handled;
    }
    
    return KeyEventResult.ignored;
  }

  /// 为TV平台创建特定的手势检测器
  static Widget createTvDetector({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onFocus,
    VoidCallback? onBlur,
    FocusNode? focusNode,
  }) {
    final FocusNode node = focusNode ?? FocusNode(
      debugLabel: 'TvDetectorFocusNode',
    );
    
    // 添加焦点监听器
    if (onFocus != null || onBlur != null) {
      node.addListener(() {
        if (node.hasFocus) {
          onFocus?.call();
        } else {
          onBlur?.call();
        }
      });
    }

    return Focus(
      focusNode: node,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// 为TV平台提供的焦点包装器
class TvFocusable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final FocusNode? focusNode;
  final bool autoFocus;
  final double focusBorderWidth;
  final Color? focusBorderColor;
  final BorderRadius? borderRadius;

  const TvFocusable({
    Key? key,
    required this.child,
    this.onTap,
    this.onFocus,
    this.onBlur,
    this.focusNode,
    this.autoFocus = false,
    this.focusBorderWidth = 0, // 如果为0，则使用TvConfig.focusBorderWidth
    this.focusBorderColor, // 如果为null，则使用TvConfig.focusBorderColor
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 存储BuildContext
    TvFocusUtils.setBuildContext(context);
    
    final FocusNode node = focusNode ?? FocusNode(
      debugLabel: 'TvFocusableFocusNode',
    );
    
    // 添加焦点监听器
    if (onFocus != null || onBlur != null) {
      node.addListener(() {
        if (node.hasFocus) {
          onFocus?.call();
        } else {
          onBlur?.call();
        }
      });
    }

    return Focus(
      focusNode: node,
      autofocus: autoFocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            onTap?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          
          return GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: hasFocus ? Border.all(
                  color: focusBorderColor ?? TvConfig.focusBorderColor,
                  width: focusBorderWidth > 0 ? focusBorderWidth : TvConfig.focusBorderWidth,
                ) : null,
                borderRadius: borderRadius ?? BorderRadius.circular(4.0),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// 一个适用于TV平台的焦点网格，可以使用方向键在项目之间导航
class TvFocusGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  
  const TvFocusGrid({
    Key? key,
    required this.children,
    this.crossAxisCount = 3,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 16/12,
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}

/// 一个适用于TV平台的列表项，可以显示焦点状态
class TvListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool autoFocus;
  
  const TvListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.autoFocus = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autoFocus: autoFocus,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16 * TvConfig.fontSizeScale,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14 * TvConfig.fontSizeScale,
              ),
            ) 
          : null,
        leading: leading,
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
} 