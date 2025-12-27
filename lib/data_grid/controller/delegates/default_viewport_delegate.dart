import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/utils/viewport_calculator.dart';
import 'package:data_grid/data_grid/controller/delegates/viewport_delegate.dart';

/// Default viewport delegate using standard viewport calculations.
class DefaultViewportDelegate<T extends DataGridRow> extends ViewportDelegate<T> {
  final ViewportCalculator _calculator;

  DefaultViewportDelegate({required double rowHeight}) : _calculator = ViewportCalculator(rowHeight: rowHeight);

  @override
  ViewportState handleScroll(ScrollEvent event, DataGridState<T> currentState) {
    final visibleRange = _calculator.calculateVisibleRows(
      event.offsetY,
      currentState.viewport.viewportHeight,
      currentState.displayOrder.length,
    );

    final visibleColumnRange = _calculator.calculateVisibleColumns(
      event.offsetX,
      currentState.columns.map((c) => c.width).toList(),
      currentState.viewport.viewportWidth,
    );

    return currentState.viewport.copyWith(
      scrollOffsetX: event.offsetX,
      scrollOffsetY: event.offsetY,
      firstVisibleRow: visibleRange.start,
      lastVisibleRow: visibleRange.end,
      firstVisibleColumn: visibleColumnRange.start,
      lastVisibleColumn: visibleColumnRange.end,
    );
  }

  @override
  ViewportState handleResize(ViewportResizeEvent event, DataGridState<T> currentState) {
    final visibleRange = _calculator.calculateVisibleRows(
      currentState.viewport.scrollOffsetY,
      event.height,
      currentState.displayOrder.length,
    );

    final visibleColumnRange = _calculator.calculateVisibleColumns(
      currentState.viewport.scrollOffsetX,
      currentState.columns.map((c) => c.width).toList(),
      event.width,
    );

    return currentState.viewport.copyWith(
      viewportWidth: event.width,
      viewportHeight: event.height,
      firstVisibleRow: visibleRange.start,
      lastVisibleRow: visibleRange.end,
      firstVisibleColumn: visibleColumnRange.start,
      lastVisibleColumn: visibleColumnRange.end,
    );
  }
}
