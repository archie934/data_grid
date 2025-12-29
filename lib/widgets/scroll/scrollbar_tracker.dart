import 'package:flutter/material.dart';

/// Widget that tracks scroll controller changes and rebuilds its child.
/// 
/// This is used to synchronize scrollbars with scroll position changes.
/// It listens to the scroll controller and triggers rebuilds when scrolling occurs.
class ScrollbarTracker extends StatefulWidget {
  final Axis axis;
  final ScrollController controller;
  final Widget child;

  const ScrollbarTracker({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
  });

  @override
  State<ScrollbarTracker> createState() => _ScrollbarTrackerState();
}

class _ScrollbarTrackerState extends State<ScrollbarTracker> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ScrollbarTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

