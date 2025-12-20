import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';

part 'grid_state.freezed.dart';

@freezed
class DataGridState<T extends DataGridRow> with _$DataGridState<T> {
  const factory DataGridState({
    required List<DataGridColumn> columns,
    required List<T> rows,
    required List<int> displayIndices,
    required ViewportState viewport,
    required SelectionState selection,
    required SortState sort,
    required FilterState filter,
    required GroupState group,
    @Default(false) bool isLoading,
  }) = _DataGridState;

  const DataGridState._();

  factory DataGridState.initial() => DataGridState<T>(
    columns: [],
    rows: [],
    displayIndices: [],
    viewport: ViewportState.initial(),
    selection: SelectionState.initial(),
    sort: SortState.initial(),
    filter: FilterState.initial(),
    group: GroupState.initial(),
  );

  int get visibleRowCount => displayIndices.length;
  List<T> get visibleRows => displayIndices.map((i) => rows[i]).toList();
}

@freezed
class ViewportState with _$ViewportState {
  const factory ViewportState({
    required double scrollOffsetX,
    required double scrollOffsetY,
    required double viewportWidth,
    required double viewportHeight,
    required int firstVisibleRow,
    required int lastVisibleRow,
    required int firstVisibleColumn,
    required int lastVisibleColumn,
  }) = _ViewportState;

  factory ViewportState.initial() => const ViewportState(
    scrollOffsetX: 0,
    scrollOffsetY: 0,
    viewportWidth: 0,
    viewportHeight: 0,
    firstVisibleRow: 0,
    lastVisibleRow: 0,
    firstVisibleColumn: 0,
    lastVisibleColumn: 0,
  );
}

@freezed
class SelectionState with _$SelectionState {
  const factory SelectionState({
    required Set<double> selectedRowIds,
    double? focusedRowId,
    required Set<String> selectedCellIds,
  }) = _SelectionState;

  const SelectionState._();

  factory SelectionState.initial() => const SelectionState(selectedRowIds: {}, selectedCellIds: {});

  bool isRowSelected(double rowId) => selectedRowIds.contains(rowId);
  bool isCellSelected(String cellId) => selectedCellIds.contains(cellId);
}

@freezed
class SortState with _$SortState {
  const factory SortState({required List<SortColumn> sortColumns}) = _SortState;

  const SortState._();

  factory SortState.initial() => const SortState(sortColumns: []);

  bool get hasSort => sortColumns.isNotEmpty;
}

@freezed
class SortColumn with _$SortColumn {
  const factory SortColumn({required int columnId, required SortDirection direction, required int priority}) =
      _SortColumn;
}

enum SortDirection { ascending, descending }

@freezed
class FilterState with _$FilterState {
  const factory FilterState({required Map<int, ColumnFilter> columnFilters}) = _FilterState;

  const FilterState._();

  factory FilterState.initial() => const FilterState(columnFilters: {});

  bool get hasFilters => columnFilters.isNotEmpty;
}

@freezed
class ColumnFilter with _$ColumnFilter {
  const factory ColumnFilter({required int columnId, required FilterOperator operator, required dynamic value}) =
      _ColumnFilter;
}

enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  isEmpty,
  isNotEmpty,
}

@freezed
class GroupState with _$GroupState {
  const factory GroupState({required List<int> groupedColumnIds, required Map<String, bool> expandedGroups}) =
      _GroupState;

  const GroupState._();

  factory GroupState.initial() => const GroupState(groupedColumnIds: [], expandedGroups: {});

  bool get hasGroups => groupedColumnIds.isNotEmpty;
  bool isGroupExpanded(String groupKey) => expandedGroups[groupKey] ?? true;
}
