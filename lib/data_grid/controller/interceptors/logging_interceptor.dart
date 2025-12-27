import 'package:flutter/foundation.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';

/// Example interceptor that logs all events and state changes.
class LoggingInterceptor<T extends DataGridRow> extends DataGridInterceptor<T> {
  final bool logEvents;
  final bool logStateChanges;
  final bool logErrors;

  const LoggingInterceptor({this.logEvents = true, this.logStateChanges = true, this.logErrors = true});

  @override
  DataGridEvent? onBeforeEvent(DataGridEvent event, DataGridState<T> currentState) {
    if (logEvents && kDebugMode) {
      print('[DataGrid] Event: ${event.runtimeType}');
    }
    return super.onBeforeEvent(event, currentState);
  }

  @override
  void onAfterStateUpdate(DataGridState<T> newState, DataGridState<T> oldState, DataGridEvent? event) {
    if (logStateChanges && kDebugMode) {
      print('[DataGrid] State updated: ${_describeStateChange(newState, oldState)}');
    }
    super.onAfterStateUpdate(newState, oldState, event);
  }

  @override
  void onError(Object error, StackTrace stackTrace, DataGridEvent? event) {
    if (logErrors && kDebugMode) {
      print('[DataGrid] Error during ${event?.runtimeType}: $error');
      print('[DataGrid] Stack trace: $stackTrace');
    }
    super.onError(error, stackTrace, event);
  }

  String _describeStateChange(DataGridState<T> newState, DataGridState<T> oldState) {
    final changes = <String>[];

    if (newState.rowsById.length != oldState.rowsById.length) {
      changes.add('rows: ${oldState.rowsById.length} → ${newState.rowsById.length}');
    }

    if (newState.columns.length != oldState.columns.length) {
      changes.add('columns: ${oldState.columns.length} → ${newState.columns.length}');
    }

    if (newState.selection != oldState.selection) {
      changes.add('selection changed');
    }

    if (newState.sort != oldState.sort) {
      changes.add('sort changed');
    }

    if (newState.filter != oldState.filter) {
      changes.add('filter changed');
    }

    return changes.isEmpty ? 'no changes' : changes.join(', ');
  }
}
