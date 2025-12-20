import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/utils/data_indexer.dart';
import 'package:data_grid/data_grid/utils/viewport_calculator.dart';

export 'package:data_grid/data_grid/utils/data_indexer.dart' show CellValueAccessor;

class DataGridController<T extends DataGridRow> {
  final BehaviorSubject<DataGridState<T>> _stateSubject;
  final PublishSubject<DataGridEvent> _eventSubject = PublishSubject();
  final StreamController<void> _disposeController = StreamController.broadcast();

  final DataIndexer<T> _dataIndexer;
  final ViewportCalculator _viewportCalculator;

  DataGridController({
    List<DataGridColumn>? initialColumns,
    List<T>? initialRows,
    double rowHeight = 48.0,
    CellValueAccessor<T>? cellValueAccessor,
  }) : _dataIndexer = DataIndexer<T>(cellValueAccessor: cellValueAccessor),
       _viewportCalculator = ViewportCalculator(rowHeight: rowHeight),
       _stateSubject = BehaviorSubject<DataGridState<T>>.seeded(DataGridState<T>.initial()) {
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
    switch (event) {
      case ScrollEvent():
        _handleScroll(event);
      case ViewportResizeEvent():
        _handleViewportResize(event);
      case ColumnResizeEvent():
        _handleColumnResize(event);
      case ColumnReorderEvent():
        _handleColumnReorder(event);
      case SortEvent():
        _handleSort(event);
      case FilterEvent():
        _handleFilter(event);
      case ClearFilterEvent():
        _handleClearFilter(event);
      case SelectRowEvent():
        _handleSelectRow(event);
      case SelectRowsRangeEvent():
        _handleSelectRowsRange(event);
      case ClearSelectionEvent():
        _handleClearSelection();
      case GroupByColumnEvent():
        _handleGroupByColumn(event);
      case UngroupColumnEvent():
        _handleUngroupColumn(event);
      case ToggleGroupExpansionEvent():
        _handleToggleGroupExpansion(event);
      case LoadDataEvent<T>():
        _handleLoadData(event);
      case RefreshDataEvent():
        _handleRefreshData();
    }
  }

  void addEvent(DataGridEvent event) => _eventSubject.add(event);

  void _handleScroll(ScrollEvent event) {
    final visibleRange = _viewportCalculator.calculateVisibleRows(
      event.offsetY,
      state.viewport.viewportHeight,
      state.displayIndices.length,
    );

    final visibleColumnRange = _viewportCalculator.calculateVisibleColumns(
      event.offsetX,
      state.columns.map((c) => c.width).toList(),
      state.viewport.viewportWidth,
    );

    _stateSubject.add(
      state.copyWith(
        viewport: state.viewport.copyWith(
          scrollOffsetX: event.offsetX,
          scrollOffsetY: event.offsetY,
          firstVisibleRow: visibleRange.start,
          lastVisibleRow: visibleRange.end,
          firstVisibleColumn: visibleColumnRange.start,
          lastVisibleColumn: visibleColumnRange.end,
        ),
      ),
    );
  }

  void _handleViewportResize(ViewportResizeEvent event) {
    final visibleRange = _viewportCalculator.calculateVisibleRows(
      state.viewport.scrollOffsetY,
      event.height,
      state.displayIndices.length,
    );

    final visibleColumnRange = _viewportCalculator.calculateVisibleColumns(
      state.viewport.scrollOffsetX,
      state.columns.map((c) => c.width).toList(),
      event.width,
    );

    _stateSubject.add(
      state.copyWith(
        viewport: state.viewport.copyWith(
          viewportWidth: event.width,
          viewportHeight: event.height,
          firstVisibleRow: visibleRange.start,
          lastVisibleRow: visibleRange.end,
          firstVisibleColumn: visibleColumnRange.start,
          lastVisibleColumn: visibleColumnRange.end,
        ),
      ),
    );
  }

  void _handleColumnResize(ColumnResizeEvent event) {
    final updatedColumns = state.columns.map((col) {
      if (col.id == event.columnId) {
        return col.copyWith(width: event.newWidth);
      }
      return col;
    }).toList();

    _stateSubject.add(state.copyWith(columns: updatedColumns));
  }

  void _handleColumnReorder(ColumnReorderEvent event) {
    final reorderedColumns = List<DataGridColumn>.from(state.columns);
    final column = reorderedColumns.removeAt(event.oldIndex);
    reorderedColumns.insert(event.newIndex, column);

    _stateSubject.add(state.copyWith(columns: reorderedColumns));
  }

  void _handleSort(SortEvent event) {
    List<SortColumn> newSortColumns;

    if (event.multiSort) {
      newSortColumns = List.from(state.sort.sortColumns);
      final existingIndex = newSortColumns.indexWhere((s) => s.columnId == event.columnId);

      if (existingIndex >= 0) {
        if (event.direction == null) {
          newSortColumns.removeAt(existingIndex);
        } else {
          newSortColumns[existingIndex] = newSortColumns[existingIndex].copyWith(direction: event.direction!);
        }
      } else if (event.direction != null) {
        newSortColumns.add(
          SortColumn(columnId: event.columnId, direction: event.direction!, priority: newSortColumns.length),
        );
      }
    } else {
      if (event.direction == null) {
        newSortColumns = [];
      } else {
        newSortColumns = [SortColumn(columnId: event.columnId, direction: event.direction!, priority: 0)];
      }
    }

    final sortedIndices = _dataIndexer.sort(state.rows, newSortColumns, state.columns);

    _stateSubject.add(
      state.copyWith(
        sort: state.sort.copyWith(sortColumns: newSortColumns),
        displayIndices: sortedIndices,
      ),
    );
  }

  void _handleFilter(FilterEvent event) {
    final newFilters = Map<int, ColumnFilter>.from(state.filter.columnFilters);
    newFilters[event.columnId] = ColumnFilter(columnId: event.columnId, operator: event.operator, value: event.value);

    final filteredIndices = _dataIndexer.filter(state.rows, newFilters.values.toList(), state.columns);

    final sortedIndices = state.sort.hasSort
        ? _dataIndexer.sortIndices(state.rows, filteredIndices, state.sort.sortColumns, state.columns)
        : filteredIndices;

    _stateSubject.add(
      state.copyWith(
        filter: state.filter.copyWith(columnFilters: newFilters),
        displayIndices: sortedIndices,
      ),
    );
  }

  void _handleClearFilter(ClearFilterEvent event) {
    final newFilters = Map<int, ColumnFilter>.from(state.filter.columnFilters);

    if (event.columnId != null) {
      newFilters.remove(event.columnId);
    } else {
      newFilters.clear();
    }

    final filteredIndices = newFilters.isEmpty
        ? List<int>.generate(state.rows.length, (i) => i)
        : _dataIndexer.filter(state.rows, newFilters.values.toList(), state.columns);

    final sortedIndices = state.sort.hasSort
        ? _dataIndexer.sortIndices(state.rows, filteredIndices, state.sort.sortColumns, state.columns)
        : filteredIndices;

    _stateSubject.add(
      state.copyWith(
        filter: state.filter.copyWith(columnFilters: newFilters),
        displayIndices: sortedIndices,
      ),
    );
  }

  void _handleSelectRow(SelectRowEvent event) {
    final Set<double> newSelection;
    if (event.multiSelect) {
      newSelection = Set<double>.from(state.selection.selectedRowIds);
      if (newSelection.contains(event.rowId)) {
        newSelection.remove(event.rowId);
      } else {
        newSelection.add(event.rowId);
      }
    } else {
      newSelection = {event.rowId};
    }

    _stateSubject.add(
      state.copyWith(
        selection: state.selection.copyWith(selectedRowIds: newSelection, focusedRowId: event.rowId),
      ),
    );
  }

  void _handleSelectRowsRange(SelectRowsRangeEvent event) {
    final startIndex = state.rows.indexWhere((r) => r.id == event.startRowId);
    final endIndex = state.rows.indexWhere((r) => r.id == event.endRowId);

    if (startIndex < 0 || endIndex < 0) return;

    final minIndex = startIndex < endIndex ? startIndex : endIndex;
    final maxIndex = startIndex > endIndex ? startIndex : endIndex;

    final selectedIds = <double>{};
    for (var i = minIndex; i <= maxIndex; i++) {
      selectedIds.add(state.rows[i].id);
    }

    _stateSubject.add(state.copyWith(selection: state.selection.copyWith(selectedRowIds: selectedIds)));
  }

  void _handleClearSelection() {
    _stateSubject.add(state.copyWith(selection: SelectionState.initial()));
  }

  void _handleGroupByColumn(GroupByColumnEvent event) {
    final newGroupedColumns = List<int>.from(state.group.groupedColumnIds);
    if (!newGroupedColumns.contains(event.columnId)) {
      newGroupedColumns.add(event.columnId);
    }

    _stateSubject.add(state.copyWith(group: state.group.copyWith(groupedColumnIds: newGroupedColumns)));
  }

  void _handleUngroupColumn(UngroupColumnEvent event) {
    final newGroupedColumns = List<int>.from(state.group.groupedColumnIds)..remove(event.columnId);

    _stateSubject.add(state.copyWith(group: state.group.copyWith(groupedColumnIds: newGroupedColumns)));
  }

  void _handleToggleGroupExpansion(ToggleGroupExpansionEvent event) {
    final newExpandedGroups = Map<String, bool>.from(state.group.expandedGroups);
    newExpandedGroups[event.groupKey] = !(newExpandedGroups[event.groupKey] ?? true);

    _stateSubject.add(state.copyWith(group: state.group.copyWith(expandedGroups: newExpandedGroups)));
  }

  void _handleLoadData(LoadDataEvent<T> event) {
    final newRows = event.append ? [...state.rows, ...event.rows] : event.rows;

    _dataIndexer.setData(newRows);

    final filteredIndices = state.filter.hasFilters
        ? _dataIndexer.filter(newRows, state.filter.columnFilters.values.toList(), state.columns)
        : List<int>.generate(newRows.length, (i) => i);

    final sortedIndices = state.sort.hasSort
        ? _dataIndexer.sortIndices(newRows, filteredIndices, state.sort.sortColumns, state.columns)
        : filteredIndices;

    _stateSubject.add(state.copyWith(rows: newRows, displayIndices: sortedIndices, isLoading: false));
  }

  void _handleRefreshData() {
    _stateSubject.add(state.copyWith(isLoading: true));
  }

  void setColumns(List<DataGridColumn> columns) {
    _stateSubject.add(state.copyWith(columns: columns));
  }

  void setRows(List<T> rows) {
    addEvent(LoadDataEvent(rows: rows));
  }

  void dispose() {
    _disposeController.add(null);
    _disposeController.close();
    _eventSubject.close();
    _stateSubject.close();
  }
}
