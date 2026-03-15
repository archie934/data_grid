import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

part 'grid_state.freezed.dart';

/// Immutable snapshot of the entire data grid state.
///
/// Includes row data, column definitions, selection, sort, filter, group,
/// edit, and pagination sub-states.
@freezed
abstract class DataGridState<T extends DataGridRow> with _$DataGridState<T> {
  const factory DataGridState({
    required List<DataGridColumn<T>> columns,
    required Map<double, T> rowsById,
    required List<double> displayOrder,
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

  /// Creates an empty initial state with default sub-states.
  factory DataGridState.initial() => DataGridState<T>(
    columns: [],
    rowsById: {},
    displayOrder: [],
    selection: SelectionState.initial(),
    sort: SortState.initial(),
    filter: FilterState.initial(),
    group: GroupState.initial(),
    edit: EditState.initial(),
    pagination: PaginationState.initial(),
    totalItems: 0,
  );

  /// Number of rows currently visible (after filtering/pagination).
  int get visibleRowCount => displayOrder.length;

  /// Materialised list of visible rows in display order.
  List<T> get visibleRows => displayOrder.map((id) => rowsById[id]!).toList();

  /// Columns including the auto-generated selection checkbox column
  /// when multi-select mode is active.
  List<DataGridColumn<T>> get effectiveColumns {
    if (selection.mode == SelectionMode.multiple) {
      final selectionColumn = DataGridColumn<T>.selection(pinned: true);
      return [selectionColumn, ...columns];
    }
    return columns;
  }

  /// Whether any form of row selection is enabled.
  bool get isSelectionEnabled => selection.mode != SelectionMode.none;

  /// 1-based index of the first item on the current page.
  int get currentPageStart {
    if (!pagination.enabled) return 0;
    return (pagination.currentPage - 1) * pagination.pageSize + 1;
  }

  /// 1-based index of the last item on the current page.
  int get currentPageEnd {
    if (!pagination.enabled) return totalItems;
    return math.min(pagination.currentPage * pagination.pageSize, totalItems);
  }

  /// Whether a next page is available.
  bool get hasNextPage {
    if (!pagination.enabled) return false;
    return pagination.currentPage < pagination.totalPages(totalItems);
  }

  /// Whether a previous page is available.
  bool get hasPreviousPage {
    if (!pagination.enabled) return false;
    return pagination.currentPage > 1;
  }
}

/// Row and cell selection state.
@freezed
abstract class SelectionState with _$SelectionState {
  const factory SelectionState({
    required Set<double> selectedRowIds,
    double? focusedRowId,
    @Default([]) List<String> focusedCells,
    required SelectionMode mode,
  }) = _SelectionState;

  const SelectionState._();

  /// Creates an initial selection state with no selection.
  factory SelectionState.initial() => const SelectionState(
    selectedRowIds: {},
    mode: SelectionMode.none,
  );

  /// Returns `true` if the row with [rowId] is currently selected.
  bool isRowSelected(double rowId) => selectedRowIds.contains(rowId);

  /// Returns `true` if [cellId] is anywhere in the focused cells path.
  bool isCellFocused(String cellId) => focusedCells.contains(cellId);

  /// Returns `true` if [cellId] is the active (last) cell in the focused path.
  bool isActiveCellId(String cellId) =>
      focusedCells.isNotEmpty && focusedCells.last == cellId;

  /// The anchor cell (first in path), or `null` if no cells are focused.
  String? get anchorCellId => focusedCells.isEmpty ? null : focusedCells.first;

  /// The active/cursor cell (last in path), or `null` if no cells are focused.
  String? get activeCellId => focusedCells.isEmpty ? null : focusedCells.last;
}

/// Current sort configuration.
@freezed
abstract class SortState with _$SortState {
  const factory SortState({SortColumn? sortColumn}) = _SortState;

  const SortState._();

  /// Creates an initial state with no active sort.
  factory SortState.initial() => const SortState();

  /// Whether any column sort is active.
  bool get hasSort => sortColumn != null;
}

/// Identifies a sorted column and its direction.
@freezed
abstract class SortColumn with _$SortColumn {
  const factory SortColumn({
    required int columnId,
    required SortDirection direction,
  }) = _SortColumn;
}

/// Active column filters, keyed by column ID.
@freezed
abstract class FilterState with _$FilterState {
  const factory FilterState({required Map<int, ColumnFilter> columnFilters}) =
      _FilterState;

  const FilterState._();

  /// Creates an initial state with no filters applied.
  factory FilterState.initial() => const FilterState(columnFilters: {});

  /// Whether any column filter is active.
  bool get hasFilters => columnFilters.isNotEmpty;
}

/// A single column filter with an operator and comparison value.
@freezed
abstract class ColumnFilter with _$ColumnFilter {
  const factory ColumnFilter({
    required int columnId,
    required FilterOperator operator,
    required dynamic value,
  }) = _ColumnFilter;
}

/// Row grouping state.
@freezed
abstract class GroupState with _$GroupState {
  const factory GroupState({
    required List<int> groupedColumnIds,
    required Map<String, bool> expandedGroups,
  }) = _GroupState;

  const GroupState._();

  /// Creates an initial state with no groups.
  factory GroupState.initial() =>
      const GroupState(groupedColumnIds: [], expandedGroups: {});

  /// Whether any column grouping is active.
  bool get hasGroups => groupedColumnIds.isNotEmpty;

  /// Returns `true` if the group identified by [groupKey] is expanded.
  bool isGroupExpanded(String groupKey) => expandedGroups[groupKey] ?? true;
}

/// Inline cell editing state.
@freezed
abstract class EditState with _$EditState {
  const factory EditState({String? editingCellId, dynamic editingValue}) =
      _EditState;

  const EditState._();

  /// Creates an initial state with no active edit.
  factory EditState.initial() => const EditState();

  /// Whether a cell is currently being edited.
  bool get isEditing => editingCellId != null;

  /// Returns `true` if the cell at [rowId] / [columnId] is being edited.
  bool isCellEditing(double rowId, int columnId) {
    return editingCellId == '${rowId}_$columnId';
  }

  /// Builds a composite cell ID string from [rowId] and [columnId].
  String createCellId(double rowId, int columnId) => '${rowId}_$columnId';
}

/// Pagination configuration and position.
@freezed
abstract class PaginationState with _$PaginationState {
  const factory PaginationState({
    @Default(1) int currentPage,
    @Default(50) int pageSize,
    @Default(false) bool enabled,
    @Default(false) bool serverSide,
  }) = _PaginationState;

  const PaginationState._();

  /// Creates an initial state with pagination disabled, page 1, 50 rows/page.
  factory PaginationState.initial() => const PaginationState();

  /// Calculates the total number of pages for [totalItems].
  int totalPages(int totalItems) {
    if (totalItems == 0) return 1;
    return math.max(1, (totalItems / pageSize).ceil());
  }

  /// Returns the 0-based start index for the current page.
  int startIndex(int totalItems) {
    if (!enabled) return 0;
    return (currentPage - 1) * pageSize;
  }

  /// Returns the exclusive end index for the current page.
  int endIndex(int totalItems) {
    if (!enabled) return totalItems;
    return math.min(startIndex(totalItems) + pageSize, totalItems);
  }
}
