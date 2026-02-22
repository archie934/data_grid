import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

/// Manages horizontal and vertical scroll controllers for the data grid,
/// exposing reactive streams for scroll metric changes.
class GridScrollController {
  /// The scroll controller driving horizontal movement.
  final ScrollController horizontalController;

  /// The scroll controller driving vertical movement.
  final ScrollController verticalController;

  final BehaviorSubject<ScrollMetrics?> _horizontalMetricsSubject =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<ScrollMetrics?> _verticalMetricsSubject =
      BehaviorSubject.seeded(null);

  /// Creates a [GridScrollController] with optional pre-existing controllers.
  GridScrollController({
    ScrollController? horizontal,
    ScrollController? vertical,
  }) : horizontalController = horizontal ?? ScrollController(),
       verticalController = vertical ?? ScrollController() {
    _setupListeners();
  }

  /// Stream of horizontal scroll metric updates.
  Stream<ScrollMetrics?> get horizontalMetrics$ =>
      _horizontalMetricsSubject.stream;

  /// Stream of vertical scroll metric updates.
  Stream<ScrollMetrics?> get verticalMetrics$ => _verticalMetricsSubject.stream;

  /// Current horizontal scroll offset, or 0 if no clients are attached.
  double get horizontalOffset =>
      horizontalController.hasClients ? horizontalController.offset : 0;

  /// Current vertical scroll offset, or 0 if no clients are attached.
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

  /// Animates the vertical scroll to bring [rowIndex] into view.
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

  /// Animates the horizontal scroll to bring [columnIndex] into view.
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

  /// Instantly scrolls vertically to [rowIndex] without animation.
  void jumpToRow(int rowIndex, {required double rowHeight}) {
    if (!verticalController.hasClients) return;
    final offset = rowIndex * rowHeight;
    verticalController.jumpTo(offset);
  }

  /// Instantly scrolls horizontally to [columnIndex] without animation.
  void jumpToColumn(int columnIndex, {required List<double> columnWidths}) {
    if (!horizontalController.hasClients) return;

    double offset = 0;
    for (var i = 0; i < columnIndex && i < columnWidths.length; i++) {
      offset += columnWidths[i];
    }

    horizontalController.jumpTo(offset);
  }

  /// Disposes both scroll controllers and closes metric streams.
  void dispose() {
    horizontalController.removeListener(_onHorizontalScroll);
    verticalController.removeListener(_onVerticalScroll);
    horizontalController.dispose();
    verticalController.dispose();
    _horizontalMetricsSubject.close();
    _verticalMetricsSubject.close();
  }
}
