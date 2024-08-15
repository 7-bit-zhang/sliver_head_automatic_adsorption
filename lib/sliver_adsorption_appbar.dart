// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_head_automatic_adsorption/animation/animation_enum.dart';
import 'package:sliver_head_automatic_adsorption/sliver_adsorption_header.dart';

class SliverAdsorption extends StatefulWidget {
  /// 滚动控制器
  final ScrollController controller;

  /// 列表
  final List<Widget> slivers;

  /// 是否固定
  final bool pinned;

  /// 折叠高度
  final double collapsedHeight;

  /// 展开高度
  final double expandedHeight;

  /// 顶部距离
  final double? paddingTop;

  /// 折叠后显示组件
  final Widget? collapsedWidget;

  /// 展开后显示组件
  final Widget expandedWidget;

  /// 展开时的背景颜色
  final Color? expandedColors;

  /// 折叠时的背景颜色
  final Color? collapsedColors;

  /// 默认的折叠组件Title
  final String? defaultCollapsedTitle;

  /// 默认的折叠组件Color
  final Color defaultCollapsedColor;

  /// 动画执行时间
  /// 默认 300ms
  late Duration durationAnimation;

  /// 更新背景颜色
  final Function(Color)? updateBackgroundColor;

  /// 动画曲线
  final Curve? curve;

  final AnimationEnum animationEnum;

  /// 构造函数
  SliverAdsorption({
    super.key,
    this.pinned = true,
    this.expandedColors,
    this.collapsedColors,
    this.defaultCollapsedTitle,
    this.defaultCollapsedColor = Colors.black,
    this.collapsedWidget,
    this.paddingTop,
    this.curve,
    this.collapsedHeight = 60,
    this.expandedHeight = 400,
    this.animationEnum = AnimationEnum.upToDown,
    this.durationAnimation = const Duration(milliseconds: 300),
    this.updateBackgroundColor,
    required this.controller,
    required this.slivers,
    required this.expandedWidget,
  }) : assert(
            slivers.every((widget) =>
                widget is RenderObjectWidget ||
                slivers.every((widget) => widget is RenderSliver) ||
                slivers.every((widget) => widget is SliverConstraints)),
            'slivers list child must be a of RenderObjectWidgets||RenderSliver||SliverConstraints ');
  @override
  State<SliverAdsorption> createState() => _SliverAdsorptionState();
}

class _SliverAdsorptionState extends State<SliverAdsorption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<dynamic> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.durationAnimation,
      vsync: this,
    );

    /// 初始化动画
    _initAnimation(widget.animationEnum);
  }

  /// 初始化动画【根据枚举类型初始化动画】
  /// [AnimationEnum]
  _initAnimation(AnimationEnum aEnum) {
    switch (aEnum) {
      case AnimationEnum.fadeIn:
        _animation = Tween<double>(
          begin: 0, // 透明度开始0
          end: 1, // 控制透明度结束
        ).animate(CurvedAnimation(
            parent: _controller, curve: widget.curve ?? Curves.easeInOut));
        return;
      case AnimationEnum.upToDown:
        _animation = Tween<Offset>(
          begin: const Offset(0, -2), // 控制动画起始位置 (屏幕下方)
          end: const Offset(0, 0), // 控制动画结束位置 (屏幕中间)
        ).animate(CurvedAnimation(
            parent: _controller, curve: widget.curve ?? Curves.easeInOut));
        return;
      case AnimationEnum.leftToRight:
        return;
    }
  }

  /// 动画组件
  Widget? _getAnimationWidget() {
    switch (widget.animationEnum) {
      case AnimationEnum.fadeIn:
        return FadeTransition(
            opacity: _animation as Animation<double>,
            child: widget.collapsedWidget);
      case AnimationEnum.upToDown:
        return SlideTransition(
            position: _animation as Animation<Offset>,
            child: widget.collapsedWidget);
      case AnimationEnum.leftToRight:
        return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverPersistentHeader(
          pinned: widget.pinned,
          floating: false,
          delegate: SliverHeaderAutomaticDelegate(
            controller: widget.controller,
            collapsedHeight: widget.collapsedHeight,
            animationController: _controller,
            collapsedWidget: _getAnimationWidget(),
            expandedHeight: widget.expandedHeight,
            paddingTop: widget.paddingTop ?? MediaQuery.of(context).padding.top,
            defaultCollapsedColor: widget.defaultCollapsedColor,
            collapsedColors: widget.collapsedColors,
            updateBackgroundColor: widget.updateBackgroundColor,
            expandedWidget: widget.expandedWidget,
          ),
        ),
        for (var sliver in widget.slivers) sliver,
      ],
    );
  }
}
