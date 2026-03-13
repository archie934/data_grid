import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/custom_layout/external_scroll_position.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_pinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_unpinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/offset_scrollbar.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';

class CustomLayoutGridBody<T extends DataGridRow> extends StatefulWidget {
  final double rowHeight;
  final double cacheExtent;

  const CustomLayoutGridBody({
    super.key,
    required this.rowHeight,
    required this.cacheExtent,
  });

  @override
  State<CustomLayoutGridBody<T>> createState() =>
      _CustomLayoutGridBodyState<T>();
}

class _CustomLayoutGridBodyState<T extends DataGridRow>
    extends State<CustomLayoutGridBody<T>>
    with TickerProviderStateMixin
    implements ScrollContext {
  late final ValueNotifier<double> _hOffset = ValueNotifier(0.0);
  late final ValueNotifier<double> _vOffset = ValueNotifier(0.0);

  Offset? _dragStart;
  double _dragStartH = 0;
  double _dragStartV = 0;

  double _maxHScroll = 0;
  double _maxVScroll = 0;

  /// A real [ScrollPosition] attached to the shared horizontal
  /// [ScrollController] so the header/filter row can read its offset.
  late final ExternalScrollPosition _hScrollPosition;

  /// Cached reference so dispose() doesn't look up an InheritedWidget on a
  /// deactivated element (which Flutter forbids and causes test failures).
  GridScrollController? _cachedScrollController;

  @override
  void initState() {
    super.initState();
    _hScrollPosition = ExternalScrollPosition(
      physics: const NeverScrollableScrollPhysics(),
      context: this,
      initialPixels: 0,
    );
    _hOffset.addListener(_pushHorizontalOffset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.gridScrollController<T>();
    _cachedScrollController = controller;
    if (controller != null &&
        !controller.horizontalController.positions.contains(_hScrollPosition)) {
      controller.horizontalController.attach(_hScrollPosition);
    }
  }

  void _pushHorizontalOffset() {
    _hScrollPosition.syncPixels(_hOffset.value);
  }

  @override
  void dispose() {
    _hOffset.removeListener(_pushHorizontalOffset);
    final controller = _cachedScrollController;
    if (controller != null &&
        controller.horizontalController.positions.contains(_hScrollPosition)) {
      controller.horizontalController.detach(_hScrollPosition);
    }
    _hScrollPosition.dispose();
    _hOffset.dispose();
    _vOffset.dispose();
    super.dispose();
  }

  // -- ScrollContext implementation ------------------------------------------

  @override
  BuildContext? get notificationContext => null;

  @override
  BuildContext get storageContext => context;

  @override
  TickerProvider get vsync => this;

  @override
  AxisDirection get axisDirection => AxisDirection.right;

  @override
  double get devicePixelRatio => View.of(context).devicePixelRatio;

  @override
  void setIgnorePointer(bool value) {}

  @override
  void setCanDrag(bool value) {}

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {}

  @override
  void saveOffset(double offset) {}

  // -- Pointer event handlers ------------------------------------------------

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final dy = event.scrollDelta.dy;
      final dx = event.scrollDelta.dx;

      if (HardwareKeyboard.instance.isShiftPressed) {
        _hOffset.value = (_hOffset.value + dy).clamp(0.0, _maxHScroll);
      } else {
        if (dx != 0) {
          _hOffset.value = (_hOffset.value + dx).clamp(0.0, _maxHScroll);
        }
        if (dy != 0) {
          _vOffset.value = (_vOffset.value + dy).clamp(0.0, _maxVScroll);
        }
      }
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    _dragStartH = _hOffset.value;
    _dragStartV = _vOffset.value;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final start = _dragStart;
    if (start == null) return;

    if (event.kind == PointerDeviceKind.mouse) return;

    final delta = start - event.position;
    _hOffset.value = (_dragStartH + delta.dx).clamp(0.0, _maxHScroll);
    _vOffset.value = (_dragStartV + delta.dy).clamp(0.0, _maxVScroll);
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragStart = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _dragStart = null;
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({
      DataGridAspect.data,
      DataGridAspect.columns,
    });
    if (state == null) return const SizedBox.expand();

    final columns = context.dataGridEffectiveColumns<T>();
    if (columns == null) return const SizedBox.expand();

    if (state.displayOrder.isEmpty) {
      return const SizedBox.expand();
    }

    final scrollbarWidth = theme.dimensions.scrollbarWidth;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final viewportHeight = constraints.maxHeight;

          final pinnedIndices = <int>[];
          final unpinnedIndices = <int>[];
          double pinnedWidth = 0;
          double unpinnedWidth = 0;

          for (int i = 0; i < columns.length; i++) {
            if (columns[i].pinned) {
              pinnedIndices.add(i);
              pinnedWidth += columns[i].width;
            } else {
              unpinnedIndices.add(i);
              unpinnedWidth += columns[i].width;
            }
          }

          final rowCount = state.displayOrder.length;
          final totalHeight = rowCount * widget.rowHeight;
          final scrollableViewportWidth = viewportWidth - pinnedWidth;

          _maxVScroll = (totalHeight - viewportHeight).clamp(
            0.0,
            double.infinity,
          );
          _maxHScroll = (unpinnedWidth - scrollableViewportWidth).clamp(
            0.0,
            double.infinity,
          );

          if (_hOffset.value > _maxHScroll) {
            _hOffset.value = _maxHScroll;
          }
          if (_vOffset.value > _maxVScroll) {
            _vOffset.value = _maxVScroll;
          }

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: _onPointerSignal,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GridUnpinnedQuadrant<T>(
                    columns: columns,
                    unpinnedIndices: unpinnedIndices,
                    pinnedWidth: pinnedWidth,
                    viewportWidth: viewportWidth,
                    viewportHeight: viewportHeight,
                    displayOrder: state.displayOrder,
                    rowsById: state.rowsById,
                    rowCount: rowCount,
                    rowHeight: widget.rowHeight,
                    cacheExtent: widget.cacheExtent,
                    hOffset: _hOffset,
                    vOffset: _vOffset,
                  ),
                ),
                if (pinnedWidth > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: pinnedWidth,
                    child: GridPinnedQuadrant<T>(
                      columns: columns,
                      pinnedIndices: pinnedIndices,
                      viewportHeight: viewportHeight,
                      displayOrder: state.displayOrder,
                      rowsById: state.rowsById,
                      rowCount: rowCount,
                      rowHeight: widget.rowHeight,
                      cacheExtent: widget.cacheExtent,
                      backgroundColor: theme.colors.evenRowColor,
                      vOffset: _vOffset,
                    ),
                  ),
                if (_maxVScroll >= 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: scrollbarWidth,
                    child: OffsetScrollbar(
                      offset: _vOffset,
                      maxScroll: _maxVScroll,
                      axis: Axis.vertical,
                      viewportExtent: viewportHeight,
                      contentExtent: totalHeight,
                    ),
                  ),
                if (_maxHScroll >= 0)
                  Positioned(
                    left: pinnedWidth,
                    right: scrollbarWidth,
                    bottom: 0,
                    child: OffsetScrollbar(
                      offset: _hOffset,
                      maxScroll: _maxHScroll,
                      axis: Axis.horizontal,
                      viewportExtent: scrollableViewportWidth,
                      contentExtent: unpinnedWidth,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
