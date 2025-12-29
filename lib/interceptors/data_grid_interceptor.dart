import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/grid_events.dart';

/// Base class for DataGrid interceptors.
///
/// Interceptors allow you to hook into the event and state update lifecycle
/// to add custom behavior, logging, validation, or modifications.
///
/// Example use cases:
/// - Logging all events and state changes
/// - Validating events before processing
/// - Modifying events or state
/// - Canceling/preventing certain events
/// - Triggering side effects (analytics, persistence, etc.)
abstract class DataGridInterceptor<T extends DataGridRow> {
  const DataGridInterceptor();

  /// Called before an event is processed.
  ///
  /// Return:
  /// - The same event to continue processing
  /// - A modified event to change behavior
  /// - null to cancel the event (it won't be processed)
  DataGridEvent? onBeforeEvent(DataGridEvent event, DataGridState<T> currentState) => event;

  /// Called after event is processed but before state is updated.
  ///
  /// Return:
  /// - The same state to continue with the update
  /// - A modified state to change what gets applied
  /// - null to cancel the state update
  DataGridState<T>? onBeforeStateUpdate(DataGridState<T> newState, DataGridState<T> oldState, DataGridEvent? event) =>
      newState;

  /// Called after state has been updated.
  ///
  /// Use this for side effects like logging, analytics, or triggering other actions.
  void onAfterStateUpdate(DataGridState<T> newState, DataGridState<T> oldState, DataGridEvent? event) {}

  /// Called when an error occurs during event processing.
  void onError(Object error, StackTrace stackTrace, DataGridEvent? event) {}
}
