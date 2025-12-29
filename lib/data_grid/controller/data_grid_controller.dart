import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';
import 'package:data_grid/data_grid/models/events/edit_events.dart';
import 'package:data_grid/data_grid/utils/data_indexer.dart';
import 'package:data_grid/data_grid/controller/delegates/viewport_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/default_viewport_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/sort_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/default_sort_delegate.dart';
import 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';

export 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';
export 'package:data_grid/data_grid/controller/delegates/viewport_delegate.dart';
export 'package:data_grid/data_grid/controller/delegates/sort_delegate.dart';

class DataGridController<T extends DataGridRow> {
  final BehaviorSubject<DataGridState<T>> _stateSubject;
  final PublishSubject<DataGridEvent> _eventSubject = PublishSubject();
  final StreamController<void> _disposeController = StreamController.broadcast();
  final BehaviorSubject<Set<double>> _renderedRowIds = BehaviorSubject.seeded({});

  final DataIndexer<T> _dataIndexer;

  late final ViewportDelegate<T> _viewportDelegate;
  late final SortDelegate<T> _sortDelegate;

  final List<DataGridInterceptor<T>> _interceptors = [];

  final bool Function(double rowId, int columnId)? canEditCell;
  final bool Function(double rowId)? canSelectRow;
  final Future<bool> Function(double rowId, int columnId, dynamic oldValue, dynamic newValue)? onCellCommit;

  DataGridController({
    List<DataGridColumn<T>>? initialColumns,
    List<T>? initialRows,
    double rowHeight = 48.0,
    Duration sortDebounce = const Duration(milliseconds: 300),
    int sortIsolateThreshold = 10000,
    ViewportDelegate<T>? viewportDelegate,
    SortDelegate<T>? sortDelegate,
    List<DataGridInterceptor<T>>? interceptors,
    this.canEditCell,
    this.canSelectRow,
    this.onCellCommit,
  }) : _dataIndexer = DataIndexer<T>(),
       _stateSubject = BehaviorSubject<DataGridState<T>>.seeded(DataGridState<T>.initial()) {
    _viewportDelegate = viewportDelegate ?? DefaultViewportDelegate<T>(rowHeight: rowHeight);
    _sortDelegate =
        sortDelegate ??
        DefaultSortDelegate<T>(
          dataIndexer: _dataIndexer,
          sortDebounce: sortDebounce,
          isolateThreshold: sortIsolateThreshold,
        );

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }

    _initialize(initialColumns ?? [], initialRows ?? []);
    _setupEventHandlers();
  }

  Stream<DataGridState<T>> get state$ => _stateSubject.stream;
  DataGridState<T> get state => _stateSubject.value;

  Stream<ViewportState> get viewport$ => _stateSubject.stream.map((s) => s.viewport).distinct();
  Stream<SelectionState> get selection$ => _stateSubject.stream.map((s) => s.selection).distinct();
  Stream<SortState> get sort$ => _stateSubject.stream.map((s) => s.sort).distinct();
  Stream<FilterState> get filter$ => _stateSubject.stream.map((s) => s.filter).distinct();
  Stream<GroupState> get group$ => _stateSubject.stream.map((s) => s.group).distinct();

  Stream<Set<double>> get renderedRowIds$ => _renderedRowIds.stream;
  Set<double> get renderedRowIds => _renderedRowIds.value;

  void _initialize(List<DataGridColumn<T>> columns, List<T> rows) {
    final rowsById = {for (var row in rows) row.id: row};
    final displayOrder = rows.map((r) => r.id).toList();
    _dataIndexer.setData(rowsById);

    _stateSubject.add(state.copyWith(columns: columns, rowsById: rowsById, displayOrder: displayOrder));
  }

  void _setupEventHandlers() {
    _eventSubject.takeUntil(_disposeController.stream).listen((event) => _handleEvent(event));
  }

  void _handleEvent(DataGridEvent event) async {
    try {
      final interceptedEvent = _runBeforeEventInterceptors(event);
      if (interceptedEvent == null) return;

      if (interceptedEvent is CommitCellEditEvent && onCellCommit != null && state.edit.isEditing) {
        final cellId = state.edit.editingCellId!;
        final parts = cellId.split('_');
        final rowId = double.parse(parts[0]);
        final columnId = int.parse(parts[1]);
        final row = state.rowsById[rowId];
        final column = state.columns.firstWhere((c) => c.id == columnId);
        final oldValue = row != null ? _dataIndexer.getCellValue(row, column) : null;
        final newValue = state.edit.editingValue;

        final allowed = await onCellCommit!(rowId, columnId, oldValue, newValue);
        if (!allowed) {
          return;
        }
      }

      final shouldShowLoading = interceptedEvent.shouldShowLoading(state);
      if (shouldShowLoading) {
        _updateStateWithInterceptors(
          state.copyWith(isLoading: true, loadingMessage: interceptedEvent.loadingMessage()),
          null,
        );
      }

      final newState = interceptedEvent.apply(_createContext());
      if (newState != null) {
        _updateStateWithInterceptors(newState, interceptedEvent);

        if (shouldShowLoading) {
          _updateStateWithInterceptors(state.copyWith(isLoading: false), null);
        }
      }
    } catch (error, stackTrace) {
      _runErrorInterceptors(error, stackTrace, event);
    }
  }

  EventContext<T> _createContext() {
    return EventContext<T>(
      state: state,
      viewportDelegate: _viewportDelegate,
      sortDelegate: _sortDelegate,
      dataIndexer: _dataIndexer,
      dispatchEvent: addEvent,
      canEditCell: canEditCell,
      canSelectRow: canSelectRow,
      onCellCommit: onCellCommit,
    );
  }

  void addEvent(DataGridEvent event) => _eventSubject.add(event);

  void addInterceptor(DataGridInterceptor<T> interceptor) {
    _interceptors.add(interceptor);
  }

  void removeInterceptor(DataGridInterceptor<T> interceptor) {
    _interceptors.remove(interceptor);
  }

  void clearInterceptors() {
    _interceptors.clear();
  }

  DataGridEvent? _runBeforeEventInterceptors(DataGridEvent event) {
    DataGridEvent? currentEvent = event;
    for (final interceptor in _interceptors) {
      currentEvent = interceptor.onBeforeEvent(currentEvent!, state);
      if (currentEvent == null) break;
    }
    return currentEvent;
  }

  void _updateStateWithInterceptors(DataGridState<T> newState, DataGridEvent? event) {
    final oldState = state;
    DataGridState<T>? interceptedState = newState;

    for (final interceptor in _interceptors) {
      interceptedState = interceptor.onBeforeStateUpdate(interceptedState!, oldState, event);
      if (interceptedState == null) return;
    }

    final finalState = interceptedState!;
    _stateSubject.add(finalState);

    for (final interceptor in _interceptors) {
      interceptor.onAfterStateUpdate(finalState, oldState, event);
    }
  }

  void _runErrorInterceptors(Object error, StackTrace stackTrace, DataGridEvent? event) {
    for (final interceptor in _interceptors) {
      interceptor.onError(error, stackTrace, event);
    }
  }

  void setColumns(List<DataGridColumn<T>> columns) {
    _updateStateWithInterceptors(state.copyWith(columns: columns), null);
  }

  void setRows(List<T> rows) {
    addEvent(LoadDataEvent(rows: rows));
  }

  void insertRow(T row, {int? position}) {
    addEvent(InsertRowEvent(row: row, position: position));
  }

  void insertRows(List<T> rows) {
    addEvent(InsertRowsEvent(rows: rows));
  }

  void deleteRow(double rowId) {
    addEvent(DeleteRowEvent(rowId: rowId));
  }

  void deleteRows(Set<double> rowIds) {
    addEvent(DeleteRowsEvent(rowIds: rowIds));
  }

  void updateRow(double rowId, T newRow) {
    addEvent(UpdateRowEvent(rowId: rowId, newRow: newRow));
  }

  void updateCell(double rowId, int columnId, dynamic value) {
    addEvent(UpdateCellEvent(rowId: rowId, columnId: columnId, value: value));
  }

  void setSelectionMode(SelectionMode mode) {
    addEvent(SetSelectionModeEvent(mode: mode));
  }

  void enableMultiSelect(bool enable) {
    setSelectionMode(enable ? SelectionMode.multiple : SelectionMode.single);
  }

  void startEditCell(double rowId, int columnId) {
    addEvent(StartCellEditEvent(rowId: rowId, columnId: columnId));
  }

  void updateCellEditValue(dynamic value) {
    addEvent(UpdateCellEditValueEvent(value: value));
  }

  void commitCellEdit() {
    addEvent(CommitCellEditEvent());
  }

  void cancelCellEdit() {
    addEvent(CancelCellEditEvent());
  }

  void registerRenderedRow(double rowId) {
    final updated = Set<double>.from(_renderedRowIds.value)..add(rowId);
    _renderedRowIds.add(updated);
  }

  void unregisterRenderedRow(double rowId) {
    final updated = Set<double>.from(_renderedRowIds.value)..remove(rowId);
    _renderedRowIds.add(updated);
  }

  void dispose() {
    _viewportDelegate.dispose();
    _sortDelegate.dispose();
    _disposeController.add(null);
    _disposeController.close();
    _eventSubject.close();
    _stateSubject.close();
    _renderedRowIds.close();
  }
}
