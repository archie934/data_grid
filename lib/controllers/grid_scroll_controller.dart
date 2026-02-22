import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class GridScrollController {
  final ScrollController horizontalController;
  final ScrollController verticalController;

  final BehaviorSubject<ScrollMetrics?> _horizontalMetricsSubject =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<ScrollMetrics?> _verticalMetricsSubject =
      BehaviorSubject.seeded(null);

  GridScrollController({
    ScrollController? horizontal,
    ScrollController? vertical,
  }) : horizontalController = horizontal ?? ScrollController(),
       verticalController = vertical ?? ScrollController() {
    _setupListeners();
  }

  Stream<ScrollMetrics?> get horizontalMetrics$ =>
      _horizontalMetricsSubject.stream;
  Stream<ScrollMetrics?> get verticalMetrics$ => _verticalMetricsSubject.stream;

  double get horizontalOffset =>
      horizontalController.hasClients ? horizontalController.offset : 0;
  double get verticalOffset =>
      verticalController.hasClients ? verticalController.offset : 0;

  void _setupListeners() {
    horizontalController.addListener(_onHorizontalScroll);
    verticalController.addListener(_onVerticalScroll);
  }

  void _onHorizontalScroll() {
    if (horizontalController.hasClients) {
      _horizontalMetricsSubject.add(horizontalController.position);
    }
  }

  void _onVerticalScroll() {
    if (verticalController.hasClients) {
      _verticalMetricsSubject.add(verticalController.position);
    }
  }

  Future<void> scrollToRow(
    int rowIndex, {
    required double rowHeight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!verticalController.hasClients) return;

    final offset = rowIndex * rowHeight;
    await verticalController.animateTo(
      offset,
      duration: duration,
      curve: curve,
    );
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

    await horizontalController.animateTo(
      offset,
      duration: duration,
      curve: curve,
    );
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
    horizontalController.removeListener(_onHorizontalScroll);
    verticalController.removeListener(_onVerticalScroll);
    horizontalController.dispose();
    verticalController.dispose();
    _horizontalMetricsSubject.close();
    _verticalMetricsSubject.close();
  }
}
