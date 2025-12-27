import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';
import 'package:data_grid/data_grid/utils/data_indexer.dart';
import 'package:data_grid/data_grid/controller/delegates/viewport_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/default_viewport_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/sort_delegate.dart';
import 'package:data_grid/data_grid/controller/delegates/default_sort_delegate.dart';
import 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';

export 'package:data_grid/data_grid/utils/data_indexer.dart' show CellValueAccessor;
export 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';
export 'package:data_grid/data_grid/controller/delegates/viewport_delegate.dart';
export 'package:data_grid/data_grid/controller/delegates/sort_delegate.dart';

class DataGridController<T extends DataGridRow> {
  final BehaviorSubject<DataGridState<T>> _stateSubject;
  final PublishSubject<DataGridEvent> _eventSubject = PublishSubject();
  final StreamController<void> _disposeController = StreamController.broadcast();

  final DataIndexer<T> _dataIndexer;

  late final ViewportDelegate<T> _viewportDelegate;
  late final SortDelegate<T> _sortDelegate;

  final List<DataGridInterceptor<T>> _interceptors = [];

  DataGridController({
    List<DataGridColumn>? initialColumns,
    List<T>? initialRows,
    double rowHeight = 48.0,
    CellValueAccessor<T>? cellValueAccessor,
    Duration sortDebounce = const Duration(milliseconds: 300),
    int sortIsolateThreshold = 10000,
    ViewportDelegate<T>? viewportDelegate,
    SortDelegate<T>? sortDelegate,
    List<DataGridInterceptor<T>>? interceptors,
  }) : _dataIndexer = DataIndexer<T>(cellValueAccessor: cellValueAccessor),
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

  void _initialize(List<DataGridColumn> columns, List<T> rows) {
    _dataIndexer.setData(rows);
    final displayIndices = List<int>.generate(rows.length, (i) => i);

    _stateSubject.add(state.copyWith(columns: columns, rows: rows, displayIndices: displayIndices));
  }

  void _setupEventHandlers() {
    _eventSubject.takeUntil(_disposeController.stream).listen((event) => _handleEvent(event));
  }

  void _handleEvent(DataGridEvent event) {
    try {
      final interceptedEvent = _runBeforeEventInterceptors(event);
      if (interceptedEvent == null) return;

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

  void setColumns(List<DataGridColumn> columns) {
    _updateStateWithInterceptors(state.copyWith(columns: columns), null);
  }

  void setRows(List<T> rows) {
    addEvent(LoadDataEvent(rows: rows));
  }

  void dispose() {
    _viewportDelegate.dispose();
    _sortDelegate.dispose();
    _disposeController.add(null);
    _disposeController.close();
    _eventSubject.close();
    _stateSubject.close();
  }
}
