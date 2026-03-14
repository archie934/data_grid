import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/custom_layout/external_scroll_position.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_pinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_unpinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/scroll/vertical_scrollbar.dart';
import 'package:flutter_data_grid/widgets/scroll/horizontal_scrollbar.dart';
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

  // -- Drag state -----------------------------------------------------------
  Offset? _dragStart;
  double _dragStartH = 0;
  double _dragStartV = 0;

  // -- Pan-zoom (trackpad) state --------------------------------------------
  Offset? _panZoomStartOffset;

  // -- Axis lock (prevents accidental cross-axis scroll) --------------------
  Axis? _scrollLockedAxis;
  static const double _axisLockThreshold = 10.0;

  // -- Ballistic animation state --------------------------------------------
  VelocityTracker? _velocityTrackerH;
  VelocityTracker? _velocityTrackerV;
  AnimationController? _ballisticH;
  AnimationController? _ballisticV;

  double _maxHScroll = 0;
  double _maxVScroll = 0;

  /// External scroll positions bridging the internal offsets to [GridScrollController].
  late final ExternalScrollPosition _hScrollPosition;
  late final ExternalScrollPosition _vScrollPosition;

  /// Guards against feedback loops in the two-way offset ↔ position sync.
  bool _updatingHOffset = false;
  bool _updatingVOffset = false;

  GridScrollController? _cachedScrollController;

  @override
  void initState() {
    super.initState();
    _hScrollPosition = ExternalScrollPosition(
      physics: const NeverScrollableScrollPhysics(),
      context: this,
      initialPixels: 0,
    );
    _vScrollPosition = ExternalScrollPosition(
      physics: const NeverScrollableScrollPhysics(),
      context: this,
      initialPixels: 0,
    );
    _hOffset.addListener(_pushHorizontalOffset);
    _vOffset.addListener(_pushVerticalOffset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.gridScrollController<T>();
    _cachedScrollController = controller;
    if (controller == null) return;

    if (!controller.horizontalController.positions.contains(_hScrollPosition)) {
      controller.horizontalController.attach(_hScrollPosition);
      controller.horizontalController.addListener(
        _onHorizontalControllerChanged,
      );
    }
    if (!controller.verticalController.positions.contains(_vScrollPosition)) {
      controller.verticalController.attach(_vScrollPosition);
      controller.verticalController.addListener(_onVerticalControllerChanged);
    }
  }

  @override
  void dispose() {
    _hOffset.removeListener(_pushHorizontalOffset);
    _vOffset.removeListener(_pushVerticalOffset);
    final controller = _cachedScrollController;
    if (controller != null) {
      controller.horizontalController.removeListener(
        _onHorizontalControllerChanged,
      );
      if (controller.horizontalController.positions.contains(
        _hScrollPosition,
      )) {
        controller.horizontalController.detach(_hScrollPosition);
      }
      controller.verticalController.removeListener(
        _onVerticalControllerChanged,
      );
      if (controller.verticalController.positions.contains(_vScrollPosition)) {
        controller.verticalController.detach(_vScrollPosition);
      }
    }
    _hScrollPosition.dispose();
    _vScrollPosition.dispose();
    _hOffset.dispose();
    _vOffset.dispose();
    _cancelBallistic();
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

  // -- Offset ↔ position sync -----------------------------------------------

  void _pushHorizontalOffset() {
    _updatingHOffset = true;
    _hScrollPosition.syncPixels(_hOffset.value);
    _updatingHOffset = false;
  }

  void _pushVerticalOffset() {
    _updatingVOffset = true;
    _vScrollPosition.syncPixels(_vOffset.value);
    _updatingVOffset = false;
  }

  /// Updates [_hOffset] when position is changed externally (e.g. [GridScrollController.scrollToColumn]).
  void _onHorizontalControllerChanged() {
    if (!_updatingHOffset) {
      _hOffset.value = _hScrollPosition.pixels.clamp(0.0, _maxHScroll);
    }
  }

  /// Updates [_vOffset] when position is changed externally (e.g. [GridScrollController.scrollToRow]).
  void _onVerticalControllerChanged() {
    if (!_updatingVOffset) {
      _vOffset.value = _vScrollPosition.pixels.clamp(0.0, _maxVScroll);
    }
  }

  // -- Ballistic helpers -----------------------------------------------------

  void _cancelBallistic() {
    final h = _ballisticH;
    _ballisticH = null;
    h?.stop();
    h?.dispose();

    final v = _ballisticV;
    _ballisticV = null;
    v?.stop();
    v?.dispose();
  }

  void _startBallistic() {
    final velH = _velocityTrackerH?.getVelocity().pixelsPerSecond.dx ?? 0;
    final velV = _velocityTrackerV?.getVelocity().pixelsPerSecond.dy ?? 0;
    _velocityTrackerH = null;
    _velocityTrackerV = null;
    _animateAxis(velH, _hOffset, () => _maxHScroll, (c) => _ballisticH = c);
    _animateAxis(velV, _vOffset, () => _maxVScroll, (c) => _ballisticV = c);
  }

  void _animateAxis(
    double velocity,
    ValueNotifier<double> offset,
    double Function() maxScroll,
    void Function(AnimationController) store,
  ) {
    const frictionTolerance = 50.0;
    if (velocity.abs() < frictionTolerance) return;
    final ctrl = AnimationController.unbounded(vsync: this);
    store(ctrl);
    final sim = ClampingScrollSimulation(
      position: offset.value,
      velocity: velocity,
      friction: 0.015,
    );
    ctrl.addListener(() {
      final raw = ctrl.value;
      final max = maxScroll();
      if (raw <= 0.0 || raw >= max) {
        offset.value = raw.clamp(0.0, max);
        ctrl.stop();
      } else {
        offset.value = raw;
      }
    });
    ctrl.animateWith(sim);
  }

  // -- Pointer event handlers ------------------------------------------------

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _cancelBallistic();
      final dy = event.scrollDelta.dy;
      final dx = event.scrollDelta.dx;

      if (HardwareKeyboard.instance.isShiftPressed) {
        _hOffset.value = (_hOffset.value + dy).clamp(0.0, _maxHScroll);
      } else {
        if (dx != 0)
          _hOffset.value = (_hOffset.value + dx).clamp(0.0, _maxHScroll);
        if (dy != 0)
          _vOffset.value = (_vOffset.value + dy).clamp(0.0, _maxVScroll);
      }
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _cancelBallistic();
    _dragStart = event.position;
    _dragStartH = _hOffset.value;
    _dragStartV = _vOffset.value;
    _scrollLockedAxis = null;
    _velocityTrackerH = VelocityTracker.withKind(event.kind);
    _velocityTrackerV = VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final start = _dragStart;
    if (start == null) return;

    if (event.kind != PointerDeviceKind.touch &&
        event.kind != PointerDeviceKind.trackpad &&
        event.kind != PointerDeviceKind.mouse) {
      return;
    }

    final delta = start - event.position;
    _scrollLockedAxis ??= _resolveAxis(delta.dx, delta.dy);
    final locked = _scrollLockedAxis;

    if (locked != Axis.vertical)
      _hOffset.value = (_dragStartH + delta.dx).clamp(0.0, _maxHScroll);
    if (locked != Axis.horizontal)
      _vOffset.value = (_dragStartV + delta.dy).clamp(0.0, _maxVScroll);

    _velocityTrackerH?.addPosition(event.timeStamp, Offset(_hOffset.value, 0));
    _velocityTrackerV?.addPosition(event.timeStamp, Offset(0, _vOffset.value));
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragStart = null;
    _scrollLockedAxis = null;
    _startBallistic();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _dragStart = null;
    _scrollLockedAxis = null;
    _velocityTrackerH = null;
    _velocityTrackerV = null;
  }

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    _cancelBallistic();
    _panZoomStartOffset = Offset(_hOffset.value, _vOffset.value);
    _scrollLockedAxis = null;
    _velocityTrackerH = VelocityTracker.withKind(PointerDeviceKind.trackpad);
    _velocityTrackerV = VelocityTracker.withKind(PointerDeviceKind.trackpad);
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    final start = _panZoomStartOffset;
    if (start == null) return;

    _scrollLockedAxis ??= _resolveAxis(event.pan.dx, event.pan.dy);
    final locked = _scrollLockedAxis;

    if (locked != Axis.vertical)
      _hOffset.value = (start.dx - event.pan.dx).clamp(0.0, _maxHScroll);
    if (locked != Axis.horizontal)
      _vOffset.value = (start.dy - event.pan.dy).clamp(0.0, _maxVScroll);

    _velocityTrackerH?.addPosition(event.timeStamp, Offset(_hOffset.value, 0));
    _velocityTrackerV?.addPosition(event.timeStamp, Offset(0, _vOffset.value));
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    _panZoomStartOffset = null;
    _scrollLockedAxis = null;
    _startBallistic();
  }

  Axis? _resolveAxis(double dx, double dy) {
    final absDx = dx.abs();
    final absDy = dy.abs();
    if (absDx < _axisLockThreshold && absDy < _axisLockThreshold) return null;
    return absDx >= absDy ? Axis.horizontal : Axis.vertical;
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

    if (state.displayOrder.isEmpty) return const SizedBox.expand();

    final scrollbarWidth = theme.dimensions.scrollbarWidth;
    final scrollController = _cachedScrollController;

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

          if (_hOffset.value > _maxHScroll) _hOffset.value = _maxHScroll;
          if (_vOffset.value > _maxVScroll) _vOffset.value = _maxVScroll;

          _hScrollPosition.syncDimensions(
            viewportExtent: scrollableViewportWidth,
            maxScrollExtent: _maxHScroll,
          );
          _vScrollPosition.syncDimensions(
            viewportExtent: viewportHeight,
            maxScrollExtent: _maxVScroll,
          );

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: _onPointerSignal,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            onPointerPanZoomStart: _onPointerPanZoomStart,
            onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
            onPointerPanZoomEnd: _onPointerPanZoomEnd,
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
                if (scrollController != null && _maxVScroll > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: _maxHScroll > 0 ? scrollbarWidth : 0,
                    child: VerticalDataGridScrollbar(
                      controller: scrollController.verticalController,
                    ),
                  ),
                if (scrollController != null && _maxHScroll > 0)
                  Positioned(
                    left: pinnedWidth,
                    right: _maxVScroll > 0 ? scrollbarWidth : 0,
                    bottom: 0,
                    child: HorizontalDataGridScrollbar(
                      controller: scrollController.horizontalController,
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
