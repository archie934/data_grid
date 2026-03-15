import 'package:flutter/foundation.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/events/edit_events.dart';
import 'package:flutter_data_grid_example/models/product_row.dart';

/// Logs every grid event and any errors to the debug console.
///
/// Attach to the controller via the [interceptors] constructor parameter or
/// [DataGridController.addInterceptor].
class LoggingInterceptor extends DataGridInterceptor<ProductRow> {
  const LoggingInterceptor();

  @override
  DataGridEvent? onBeforeEvent(
    DataGridEvent event,
    DataGridState<ProductRow> currentState,
  ) {
    debugPrint('[DataGrid] event: ${_describe(event)}');
    return event;
  }

  @override
  void onError(Object error, StackTrace stackTrace, DataGridEvent? event) {
    debugPrint(
      '[DataGrid] ERROR during ${event.runtimeType}: $error\n$stackTrace',
    );
  }

  // ---------------------------------------------------------------------------

  String _describe(DataGridEvent event) {
    final type = event.runtimeType.toString();
    final extra = _extra(event);
    return extra.isEmpty ? type : '$type($extra)';
  }

  /// Returns a compact string of the most useful fields for each event type.
  /// Falls back to an empty string for events with no interesting payload.
  String _extra(DataGridEvent event) => switch (event) {
    // Data
    LoadDataEvent e => 'rows=${e.rows.length}, append=${e.append}',
    InsertRowEvent e => 'rowId=${e.row.id}, position=${e.position}',
    InsertRowsEvent e => 'count=${e.rows.length}',
    DeleteRowEvent e => 'rowId=${e.rowId}',
    DeleteRowsEvent e => 'rowIds=${e.rowIds}',
    UpdateRowEvent e => 'rowId=${e.rowId}',
    UpdateCellEvent e =>
      'rowId=${e.rowId}, colId=${e.columnId}, value=${e.value}',
    SetLoadingEvent e =>
      'isLoading=${e.isLoading}${e.message != null ? ", msg=${e.message}" : ""}',
    // Editing
    StartCellEditEvent e => 'rowId=${e.rowId}, colId=${e.columnId}',
    UpdateCellEditValueEvent e => 'value=${e.value}',
    // Pagination
    SetPageEvent e => 'page=${e.page}',
    SetPageSizeEvent e => 'pageSize=${e.pageSize}',
    EnablePaginationEvent e => 'enabled=${e.enabled}',
    // Selection / navigation
    SetSelectionModeEvent e => 'mode=${e.mode}',
    FocusCellEvent e => 'rowId=${e.rowId}, colId=${e.columnId}',
    ShiftSelectCellEvent e => 'rowId=${e.rowId}, colId=${e.columnId}',
    ToggleCellInSelectionEvent e => 'rowId=${e.rowId}, colId=${e.columnId}',
    NavigateCellEvent e => '${e.direction.name}, extend=${e.extend}',
    SortEvent e => 'colId=${e.columnId}, dir=${e.direction}',
    _ => '',
  };
}
