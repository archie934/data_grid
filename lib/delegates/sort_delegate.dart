import 'dart:async';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';

/// Abstract delegate for handling sort operations.
///
/// Implement this to create custom sorting behavior with different
/// algorithms, debouncing strategies, or async processing.
abstract class SortDelegate<T extends DataGridRow> {
  const SortDelegate();

  /// Handle a sort event and invoke the callback with the result.
  ///
  /// The delegate is responsible for:
  /// - Processing the sort event
  /// - Updating sort columns state
  /// - Computing sorted indices
  /// - Calling onComplete with the result
  ///
  /// Returns a Future that completes when the operation finishes.
  Future<SortResult?> handleSort(
    SortEvent event,
    DataGridState<T> currentState,
    void Function(SortResult) onComplete,
  );

  /// Dispose any resources (timers, subscriptions, etc.)
  void dispose();
}

/// Result of a sort operation.
class SortResult {
  final SortState sortState;
  final List<double> displayOrder;

  SortResult({required this.sortState, required this.displayOrder});
}
