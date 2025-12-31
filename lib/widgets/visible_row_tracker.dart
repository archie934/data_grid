import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';

class VisibleRowTracker<T extends DataGridRow> extends StatefulWidget {
  final double rowId;
  final int rowIndex;
  final double rowHeight;
  final DataGridController<T> controller;
  final Widget child;

  const VisibleRowTracker({
    super.key,
    required this.rowId,
    required this.rowIndex,
    required this.rowHeight,
    required this.controller,
    required this.child,
  });

  @override
  State<VisibleRowTracker<T>> createState() => _VisibleRowTrackerState<T>();
}

class _VisibleRowTrackerState<T extends DataGridRow>
    extends State<VisibleRowTracker<T>> {
  StreamSubscription? _viewportSubscription;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
    _viewportSubscription = widget.controller.viewport$.listen((_) {
      _checkVisibility();
    });
  }

  @override
  void dispose() {
    _viewportSubscription?.cancel();
    if (_isVisible) {
      widget.controller.unregisterRenderedRow(widget.rowId);
    }
    super.dispose();
  }

  void _checkVisibility() {
    final viewport = widget.controller.state.viewport;
    final scrollOffset = viewport.scrollOffsetY;
    final viewportHeight = viewport.viewportHeight;

    final rowTop = widget.rowIndex * widget.rowHeight;
    final rowBottom = rowTop + widget.rowHeight;
    final viewportBottom = scrollOffset + viewportHeight;

    final nowVisible = rowBottom > scrollOffset && rowTop < viewportBottom;

    if (_isVisible != nowVisible) {
      _isVisible = nowVisible;
      if (nowVisible) {
        widget.controller.registerRenderedRow(widget.rowId);
      } else {
        widget.controller.unregisterRenderedRow(widget.rowId);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
