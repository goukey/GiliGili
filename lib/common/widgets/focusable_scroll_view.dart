import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/remote_focus_service.dart';
import '../../utils/tv_mode_detector.dart';

/// 可滚动的焦点视图
/// 用于处理列表和网格的焦点导航
class FocusableScrollView extends StatefulWidget {
  /// 子组件构建器
  final Widget Function(BuildContext context, ScrollController controller) builder;
  
  /// 滚动控制器
  final ScrollController? controller;
  
  /// 滚动方向
  final Axis scrollDirection;
  
  /// 滚动速度
  final double scrollSpeed;
  
  /// 是否启用键盘导航
  final bool enableKeyboardNavigation;

  const FocusableScrollView({
    Key? key,
    required this.builder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.scrollSpeed = 300.0,
    this.enableKeyboardNavigation = true,
  }) : super(key: key);

  @override
  State<FocusableScrollView> createState() => _FocusableScrollViewState();
}

class _FocusableScrollViewState extends State<FocusableScrollView> {
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  
  bool get isTVMode => TVModeDetector().isTVMode.value;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    
    if (isTVMode && widget.enableKeyboardNavigation) {
      _focusNode.addListener(_onFocusChange);
    }
  }
  
  void _onFocusChange() {
    // 当获得焦点时，可以执行一些操作
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTVMode || !widget.enableKeyboardNavigation) {
      return widget.builder(context, _scrollController);
    }
    
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: widget.builder(context, _scrollController),
    );
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    if (widget.scrollDirection == Axis.vertical) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scroll(-widget.scrollSpeed);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scroll(widget.scrollSpeed);
      }
    } else {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _scroll(-widget.scrollSpeed);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _scroll(widget.scrollSpeed);
      }
    }
  }
  
  void _scroll(double delta) {
    final double newOffset = _scrollController.offset + delta;
    _scrollController.animateTo(
      newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}

/// 可聚焦的列表视图
/// 用于在TV模式下处理列表的焦点导航
class FocusableListView extends StatelessWidget {
  /// 列表项构建器
  final Widget Function(BuildContext context, int index) itemBuilder;
  
  /// 列表项数量
  final int itemCount;
  
  /// 列表项分隔构建器
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  
  /// 滚动控制器
  final ScrollController? controller;
  
  /// 滚动方向
  final Axis scrollDirection;
  
  /// 滚动速度
  final double scrollSpeed;
  
  /// 内边距
  final EdgeInsets? padding;
  
  /// 物理滚动特性
  final ScrollPhysics? physics;
  
  /// 是否收缩包装
  final bool shrinkWrap;

  const FocusableListView({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.separatorBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.scrollSpeed = 300.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableScrollView(
      controller: controller,
      scrollDirection: scrollDirection,
      scrollSpeed: scrollSpeed,
      builder: (context, scrollController) {
        if (separatorBuilder != null) {
          return ListView.separated(
            controller: scrollController,
            scrollDirection: scrollDirection,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder!,
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
          );
        } else {
          return ListView.builder(
            controller: scrollController,
            scrollDirection: scrollDirection,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            padding: padding,
            physics: physics,
            shrinkWrap: shrinkWrap,
          );
        }
      },
    );
  }
}

/// 可聚焦的网格视图
/// 用于在TV模式下处理网格的焦点导航
class FocusableGridView extends StatelessWidget {
  /// 网格项构建器
  final Widget Function(BuildContext context, int index) itemBuilder;
  
  /// 网格项数量
  final int itemCount;
  
  /// 滚动控制器
  final ScrollController? controller;
  
  /// 滚动方向
  final Axis scrollDirection;
  
  /// 滚动速度
  final double scrollSpeed;
  
  /// 内边距
  final EdgeInsets? padding;
  
  /// 物理滚动特性
  final ScrollPhysics? physics;
  
  /// 是否收缩包装
  final bool shrinkWrap;
  
  /// 网格委托
  final SliverGridDelegate gridDelegate;

  const FocusableGridView({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.gridDelegate,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.scrollSpeed = 300.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableScrollView(
      controller: controller,
      scrollDirection: scrollDirection,
      scrollSpeed: scrollSpeed,
      builder: (context, scrollController) {
        return GridView.builder(
          controller: scrollController,
          scrollDirection: scrollDirection,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          gridDelegate: gridDelegate,
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
} 