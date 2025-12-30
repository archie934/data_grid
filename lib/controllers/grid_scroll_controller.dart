import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';

class GridScrollController {
  final ScrollController horizontalController;
  final ScrollController verticalController;

  final PublishSubject<ScrollEvent> _scrollEventSubject = PublishSubject();
  final BehaviorSubject<ScrollMetrics?> _horizontalMetricsSubject = BehaviorSubject.seeded(null);
  final BehaviorSubject<ScrollMetrics?> _verticalMetricsSubject = BehaviorSubject.seeded(null);

  Timer? _scrollDebounceTimer;
  final Duration scrollDebounce;

  GridScrollController({
    ScrollController? horizontal,
    ScrollController? vertical,
    this.scrollDebounce = const Duration(milliseconds: 16),
  }) : horizontalController = horizontal ?? ScrollController(),
       verticalController = vertical ?? ScrollController() {
    _setupListeners();
  }

  Stream<ScrollEvent> get scrollEvent$ => _scrollEventSubject.stream;
  Stream<ScrollMetrics?> get horizontalMetrics$ => _horizontalMetricsSubject.stream;
  Stream<ScrollMetrics?> get verticalMetrics$ => _verticalMetricsSubject.stream;

  double get horizontalOffset => horizontalController.hasClients ? horizontalController.offset : 0;
  double get verticalOffset => verticalController.hasClients ? verticalController.offset : 0;

  void _setupListeners() {
    horizontalController.addListener(_onHorizontalScroll);
    verticalController.addListener(_onVerticalScroll);
  }

  void _onHorizontalScroll() {
    if (horizontalController.hasClients) {
      _horizontalMetricsSubject.add(horizontalController.position);
      _emitScrollEvent();
    }
  }

  void _onVerticalScroll() {
    if (verticalController.hasClients) {
      _verticalMetricsSubject.add(verticalController.position);
      _emitScrollEvent();
    }
  }

  void _emitScrollEvent() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(scrollDebounce, () {
      _scrollEventSubject.add(ScrollEvent(offsetX: horizontalOffset, offsetY: verticalOffset));
    });
  }

  Future<void> scrollToRow(
    int rowIndex, {
    required double rowHeight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!verticalController.hasClients) return;

    final offset = rowIndex * rowHeight;
    await verticalController.animateTo(offset, duration: duration, curve: curve);
  }

  Future<void> scrollToColumn(
    int columnIndex, {
    required List<double> columnWidths,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!horizontalController.hasClients) return;

    double offset = 0;
    for (var i = 0; i < columnIndex && i < columnWidths.length; i++) {
      offset += columnWidths[i];
    }

    await horizontalController.animateTo(offset, duration: duration, curve: curve);
  }

  void jumpToRow(int rowIndex, {required double rowHeight}) {
    if (!verticalController.hasClients) return;
    final offset = rowIndex * rowHeight;
    verticalController.jumpTo(offset);
  }

  void jumpToColumn(int columnIndex, {required List<double> columnWidths}) {
    if (!horizontalController.hasClients) return;

    double offset = 0;
    for (var i = 0; i < columnIndex && i < columnWidths.length; i++) {
      offset += columnWidths[i];
    }

    horizontalController.jumpTo(offset);
  }

  void dispose() {
    _scrollDebounceTimer?.cancel();
    horizontalController.removeListener(_onHorizontalScroll);
    verticalController.removeListener(_onVerticalScroll);
    horizontalController.dispose();
    verticalController.dispose();
    _scrollEventSubject.close();
    _horizontalMetricsSubject.close();
    _verticalMetricsSubject.close();
  }
}
