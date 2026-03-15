part of 'custom_layout_grid_body.dart';

mixin _GridBodyScrollMixin<T extends DataGridRow>
    on State<CustomLayoutGridBody<T>>
    implements ScrollContext {
  late final ValueNotifier<double> _hOffset;
  late final ValueNotifier<double> _vOffset;

  // -- Drag-scroll state ------------------------------------------------------
  Offset? _dragStart;
  double _dragStartH = 0;
  double _dragStartV = 0;

  // -- Pan-zoom (trackpad) state ----------------------------------------------
  Offset? _panZoomStartOffset;

  // -- Axis lock --------------------------------------------------------------
  Axis? _scrollLockedAxis;
  static const double _axisLockThreshold = 10.0;

  // -- Ballistic animation state ---------------------------------------------
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

  // -- ScrollContext implementation -------------------------------------------

  @override
  BuildContext? get notificationContext => null;

  @override
  BuildContext get storageContext => context;

  /// Provided by [TickerProviderStateMixin] in the concrete class.
  @override
  TickerProvider get vsync;

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

  // -- Lifecycle -------------------------------------------------------------

  void _scrollInitState() {
    _hOffset = ValueNotifier(0.0);
    _vOffset = ValueNotifier(0.0);
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

  void _scrollDidChangeDependencies() {
    final controller = context.gridScrollController<T>();
    _cachedScrollController = controller;
    if (controller == null) return;

    if (!controller.horizontalController.positions.contains(_hScrollPosition)) {
      controller.horizontalController.attach(_hScrollPosition);
      controller.horizontalController.addListener(_onHorizontalControllerChanged);
    }
    if (!controller.verticalController.positions.contains(_vScrollPosition)) {
      controller.verticalController.attach(_vScrollPosition);
      controller.verticalController.addListener(_onVerticalControllerChanged);
    }
  }

  void _scrollDispose() {
    _hOffset.removeListener(_pushHorizontalOffset);
    _vOffset.removeListener(_pushVerticalOffset);
    final controller = _cachedScrollController;
    if (controller != null) {
      controller.horizontalController.removeListener(_onHorizontalControllerChanged);
      if (controller.horizontalController.positions.contains(_hScrollPosition)) {
        controller.horizontalController.detach(_hScrollPosition);
      }
      controller.verticalController.removeListener(_onVerticalControllerChanged);
      if (controller.verticalController.positions.contains(_vScrollPosition)) {
        controller.verticalController.detach(_vScrollPosition);
      }
    }
    _hScrollPosition.dispose();
    _vScrollPosition.dispose();
    _hOffset.dispose();
    _vOffset.dispose();
    _cancelBallistic();
  }

  // -- Offset ↔ position sync ------------------------------------------------

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
    final ctrl = AnimationController.unbounded(vsync: vsync);
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

  // -- Scroll dimensions sync ------------------------------------------------

  void _syncScrollDimensions({
    required double scrollableViewportWidth,
    required double viewportHeight,
    required double unpinnedWidth,
    required double totalHeight,
  }) {
    _maxVScroll = (totalHeight - viewportHeight).clamp(0.0, double.infinity);
    _maxHScroll = (unpinnedWidth - scrollableViewportWidth).clamp(0.0, double.infinity);

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
  }

  // -- Axis lock -------------------------------------------------------------

  Axis? _resolveAxis(double dx, double dy) {
    final absDx = dx.abs();
    final absDy = dy.abs();
    if (absDx < _axisLockThreshold && absDy < _axisLockThreshold) return null;
    return absDx >= absDy ? Axis.horizontal : Axis.vertical;
  }

  // -- Pointer handlers (scroll) ---------------------------------------------

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _cancelBallistic();
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

  void _scrollPointerDown(PointerDownEvent event) {
    _cancelBallistic();
    _dragStart = event.position;
    _dragStartH = _hOffset.value;
    _dragStartV = _vOffset.value;
    _scrollLockedAxis = null;
    _velocityTrackerH = VelocityTracker.withKind(event.kind);
    _velocityTrackerV = VelocityTracker.withKind(event.kind);
  }

  void _scrollPointerMove(PointerMoveEvent event) {
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

    if (locked != Axis.vertical) _hOffset.value = (_dragStartH + delta.dx).clamp(0.0, _maxHScroll);
    if (locked != Axis.horizontal) _vOffset.value = (_dragStartV + delta.dy).clamp(0.0, _maxVScroll);

    _velocityTrackerH?.addPosition(event.timeStamp, Offset(_hOffset.value, 0));
    _velocityTrackerV?.addPosition(event.timeStamp, Offset(0, _vOffset.value));
  }

  void _scrollPointerUp(PointerUpEvent event) {
    _dragStart = null;
    _scrollLockedAxis = null;
    _startBallistic();
  }

  void _scrollPointerCancel(PointerCancelEvent event) {
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

    if (locked != Axis.vertical) {
      _hOffset.value = (start.dx - event.pan.dx).clamp(0.0, _maxHScroll);
    }
    if (locked != Axis.horizontal) {
      _vOffset.value = (start.dy - event.pan.dy).clamp(0.0, _maxVScroll);
    }

    _velocityTrackerH?.addPosition(event.timeStamp, Offset(_hOffset.value, 0));
    _velocityTrackerV?.addPosition(event.timeStamp, Offset(0, _vOffset.value));
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    _panZoomStartOffset = null;
    _scrollLockedAxis = null;
    _startBallistic();
  }
}
