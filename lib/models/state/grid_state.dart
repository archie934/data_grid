import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

part 'grid_state.freezed.dart';

@freezed
abstract class DataGridState<T extends DataGridRow> with _$DataGridState<T> {
  const factory DataGridState({
    required List<DataGridColumn<T>> columns,
    required Map<double, T> rowsById,
    required List<double> displayOrder,
    required ViewportState viewport,
    required SelectionState selection,
    required SortState sort,
    required FilterState filter,
    required GroupState group,
    required EditState edit,
    required PaginationState pagination,
    @Default(0) int totalItems,
    @Default(false) bool isLoading,
    String? loadingMessage,
  }) = _DataGridState;

  const DataGridState._();

  factory DataGridState.initial() => DataGridState<T>(
    columns: [],
    rowsById: {},
    displayOrder: [],
    viewport: ViewportState.initial(),
    selection: SelectionState.initial(),
    sort: SortState.initial(),
    filter: FilterState.initial(),
    group: GroupState.initial(),
    edit: EditState.initial(),
    pagination: PaginationState.initial(),
    totalItems: 0,
  );

  int get visibleRowCount => displayOrder.length;
  List<T> get visibleRows => displayOrder.map((id) => rowsById[id]!).toList();

  List<DataGridColumn<T>> get effectiveColumns {
    if (selection.mode == SelectionMode.multiple) {
      final hasPinnedColumns = columns.any((col) => col.pinned);
      final selectionColumn = DataGridColumn<T>.selection(
        pinned: hasPinnedColumns,
      );
      return [selectionColumn, ...columns];
    }
    return columns;
  }

  bool get isSelectionEnabled => selection.mode != SelectionMode.none;

  int get currentPageStart {
    if (!pagination.enabled) return 0;
    return (pagination.currentPage - 1) * pagination.pageSize + 1;
  }

  int get currentPageEnd {
    if (!pagination.enabled) return totalItems;
    return math.min(pagination.currentPage * pagination.pageSize, totalItems);
  }

  bool get hasNextPage {
    if (!pagination.enabled) return false;
    return pagination.currentPage < pagination.totalPages(totalItems);
  }

  bool get hasPreviousPage {
    if (!pagination.enabled) return false;
    return pagination.currentPage > 1;
  }
}

@freezed
abstract class ViewportState with _$ViewportState {
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
abstract class SelectionState with _$SelectionState {
  const factory SelectionState({
    required Set<double> selectedRowIds,
    double? focusedRowId,
    required Set<String> selectedCellIds,
    required SelectionMode mode,
  }) = _SelectionState;

  const SelectionState._();

  factory SelectionState.initial() => const SelectionState(
    selectedRowIds: {},
    selectedCellIds: {},
    mode: SelectionMode.single,
  );

  bool isRowSelected(double rowId) => selectedRowIds.contains(rowId);
  bool isCellSelected(String cellId) => selectedCellIds.contains(cellId);
}

@freezed
abstract class SortState with _$SortState {
  const factory SortState({SortColumn? sortColumn}) = _SortState;

  const SortState._();

  factory SortState.initial() => const SortState();

  bool get hasSort => sortColumn != null;
}

@freezed
abstract class SortColumn with _$SortColumn {
  const factory SortColumn({
    required int columnId,
    required SortDirection direction,
  }) = _SortColumn;
}

@freezed
abstract class FilterState with _$FilterState {
  const factory FilterState({required Map<int, ColumnFilter> columnFilters}) =
      _FilterState;

  const FilterState._();

  factory FilterState.initial() => const FilterState(columnFilters: {});

  bool get hasFilters => columnFilters.isNotEmpty;
}

@freezed
abstract class ColumnFilter with _$ColumnFilter {
  const factory ColumnFilter({
    required int columnId,
    required FilterOperator operator,
    required dynamic value,
  }) = _ColumnFilter;
}

@freezed
abstract class GroupState with _$GroupState {
  const factory GroupState({
    required List<int> groupedColumnIds,
    required Map<String, bool> expandedGroups,
  }) = _GroupState;

  const GroupState._();

  factory GroupState.initial() =>
      const GroupState(groupedColumnIds: [], expandedGroups: {});

  bool get hasGroups => groupedColumnIds.isNotEmpty;
  bool isGroupExpanded(String groupKey) => expandedGroups[groupKey] ?? true;
}

@freezed
abstract class EditState with _$EditState {
  const factory EditState({String? editingCellId, dynamic editingValue}) =
      _EditState;

  const EditState._();

  factory EditState.initial() => const EditState();

  bool get isEditing => editingCellId != null;

  bool isCellEditing(double rowId, int columnId) {
    return editingCellId == '${rowId}_$columnId';
  }

  String createCellId(double rowId, int columnId) => '${rowId}_$columnId';
}

@freezed
abstract class PaginationState with _$PaginationState {
  const factory PaginationState({
    @Default(1) int currentPage,
    @Default(50) int pageSize,
    @Default(false) bool enabled,
    @Default(false) bool serverSide,
  }) = _PaginationState;

  const PaginationState._();

  factory PaginationState.initial() => const PaginationState();

  int totalPages(int totalItems) {
    if (totalItems == 0) return 1;
    return math.max(1, (totalItems / pageSize).ceil());
  }

  int startIndex(int totalItems) {
    if (!enabled) return 0;
    return (currentPage - 1) * pageSize;
  }

  int endIndex(int totalItems) {
    if (!enabled) return totalItems;
    return math.min(startIndex(totalItems) + pageSize, totalItems);
  }
}
