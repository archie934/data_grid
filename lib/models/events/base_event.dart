import 'dart:async';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/event_context.dart';

abstract class DataGridEvent {
  const DataGridEvent();

  /// Apply this event's transformation to the state.
  /// Returns the new state, or null if no state change should occur.
  /// Can return a Future for async operations.
  FutureOr<DataGridState<T>?> apply<T extends DataGridRow>(EventContext<T> context);

  /// Whether this event should show loading indicator for large datasets
  bool shouldShowLoading(DataGridState state) => false;

  /// Custom loading message
  String? loadingMessage() => null;
}
