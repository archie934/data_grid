import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

/// Direction for cell navigation events.
enum CellNavDirection { up, down, left, right }

/// Parses a cell ID (format: "${rowId}_${columnId}") into its components.
(double rowId, int columnId) parseCellId(String cellId) {
  final idx = cellId.lastIndexOf('_');
  return (
    double.parse(cellId.substring(0, idx)),
    int.parse(cellId.substring(idx + 1)),
  );
}

/// Focuses a single cell, replacing the entire focused-cells path.
/// Dispatched on a plain click (no modifiers).
class FocusCellEvent extends DataGridEvent {
  final double rowId;
  final int columnId;

  FocusCellEvent({required this.rowId, required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final cellId = '${rowId}_$columnId';
    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedCells: [cellId]),
    );
  }
}

/// Appends a cell to the focused-cells path (Shift+click).
/// If the cell is already the last in the path, this is a no-op.
/// Preserves all previously focused cells.
class ShiftSelectCellEvent extends DataGridEvent {
  final double rowId;
  final int columnId;

  ShiftSelectCellEvent({required this.rowId, required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final cellId = '${rowId}_$columnId';
    final current = context.state.selection.focusedCells;

    if (current.isEmpty) {
      // No anchor yet — treat like a plain focus
      return context.state.copyWith(
        selection: context.state.selection.copyWith(focusedCells: [cellId]),
      );
    }

    if (current.last == cellId) return null; // already active, no-op

    if (current.contains(cellId)) return null; // already in path, no-op

    return context.state.copyWith(
      selection: context.state.selection.copyWith(
        focusedCells: [...current, cellId],
      ),
    );
  }
}

/// Toggles a cell in/out of the focused-cells path (Ctrl+click).
/// Adds the cell if absent, removes it if present.
class ToggleCellInSelectionEvent extends DataGridEvent {
  final double rowId;
  final int columnId;

  ToggleCellInSelectionEvent({required this.rowId, required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final cellId = '${rowId}_$columnId';
    final current = List<String>.from(context.state.selection.focusedCells);

    if (current.contains(cellId)) {
      current.remove(cellId);
    } else {
      current.add(cellId);
    }

    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedCells: current),
    );
  }
}

/// Clears the focused-cells path entirely.
class ClearCellSelectionEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.focusedCells.isEmpty) return null;
    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedCells: []),
    );
  }
}

/// Navigates focus to an adjacent cell, with optional path extension.
///
/// - [extend] = `false` (plain arrow): resets the path to `[newCell]`.
/// - [extend] = `true` (Shift+Arrow): appends the adjacent cell, or pops the
///   last cell when moving back along the existing path (shrink selection).
///
/// Falls back to row-level navigation (up/down only) when no cell is active.
class NavigateCellEvent extends DataGridEvent {
  final CellNavDirection direction;
  final bool extend;

  NavigateCellEvent(this.direction, {this.extend = false});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final state = context.state;
    final activeCellId = state.selection.activeCellId;

    // ── No active cell: fall back to row navigation (up/down only) ──────────
    if (activeCellId == null) {
      return _rowNavFallback(state);
    }

    // ── Resolve current position ─────────────────────────────────────────────
    final (activeRowId, activeColId) = parseCellId(activeCellId);

    final visibleColumns =
        state.effectiveColumns.where((c) => c.visible).toList();

    // For Shift+Arrow we need the anchor's row/col indices as well as the
    // active cell's. Parse the anchor up front so both can be located in a
    // single scan of displayOrder below — avoiding a second pass or a HashMap.
    final existingPath = state.selection.focusedCells;
    final anchorCellId = extend && existingPath.isNotEmpty
        ? existingPath.first
        : null;
    final anchorParsed =
        anchorCellId != null ? parseCellId(anchorCellId) : null;
    final anchorRowId = anchorParsed?.$1;
    final anchorColId = anchorParsed?.$2;

    // ── Row index resolution ─────────────────────────────────────────────────
    // displayOrder can contain hundreds of thousands of entries.
    // List.indexOf is O(n) and building a Map<double,int> allocates on the
    // heap. Instead we do one forward scan that locates both the active row
    // and (when extending) the anchor row simultaneously, breaking as soon
    // as both are found. In the common case — both cells visible on screen —
    // this exits within the first few dozen iterations.
    int rowIndex = -1;
    int anchorRowIdx = -1;
    for (int i = 0; i < state.displayOrder.length; i++) {
      final id = state.displayOrder[i];
      if (rowIndex == -1 && id == activeRowId) rowIndex = i;
      if (anchorRowId != null && anchorRowIdx == -1 && id == anchorRowId) {
        anchorRowIdx = i;
      }
      if (rowIndex != -1 && (anchorRowId == null || anchorRowIdx != -1)) break;
    }

    // Column count is always small (tens), so a straightforward scan is fine.
    // The same two-target pattern is kept for consistency.
    int colIndex = -1;
    int anchorColIdx = -1;
    for (int i = 0; i < visibleColumns.length; i++) {
      final id = visibleColumns[i].id;
      if (colIndex == -1 && id == activeColId) colIndex = i;
      if (anchorColId != null && anchorColIdx == -1 && id == anchorColId) {
        anchorColIdx = i;
      }
      if (colIndex != -1 && (anchorColId == null || anchorColIdx != -1)) break;
    }

    if (rowIndex == -1 || colIndex == -1) return null;

    // ── Compute target position ──────────────────────────────────────────────
    int newRowIndex = rowIndex;
    int newColIndex = colIndex;

    switch (direction) {
      case CellNavDirection.up:
        newRowIndex = rowIndex - 1;
      case CellNavDirection.down:
        newRowIndex = rowIndex + 1;
      case CellNavDirection.left:
        newColIndex = colIndex - 1;
      case CellNavDirection.right:
        newColIndex = colIndex + 1;
    }

    // Clamp to bounds
    if (newRowIndex < 0 ||
        newRowIndex >= state.displayOrder.length ||
        newColIndex < 0 ||
        newColIndex >= visibleColumns.length) {
      return null;
    }

    final newCellId =
        '${state.displayOrder[newRowIndex]}_${visibleColumns[newColIndex].id}';

    // ── Update focused-cells path ────────────────────────────────────────────
    if (!extend) {
      return state.copyWith(
        selection: state.selection.copyWith(focusedCells: [newCellId]),
      );
    }

    // Shift+Arrow: anchor stays fixed, cursor moves to newCell.
    // Rebuild rectangle so selection can shrink/grow in any direction.
    if (anchorRowIdx == -1 || anchorColIdx == -1) {
      return state.copyWith(
        selection: state.selection.copyWith(focusedCells: [newCellId]),
      );
    }

    // Traverse anchor→cursor so focusedCells.first == anchor, .last == cursor.
    final rStep = newRowIndex >= anchorRowIdx ? 1 : -1;
    final cStep = newColIndex >= anchorColIdx ? 1 : -1;
    final cells = <String>[];
    for (int r = anchorRowIdx; r != newRowIndex + rStep; r += rStep) {
      for (int c = anchorColIdx; c != newColIndex + cStep; c += cStep) {
        cells.add('${state.displayOrder[r]}_${visibleColumns[c].id}');
      }
    }

    return state.copyWith(
      selection: state.selection.copyWith(focusedCells: cells),
    );
  }

  /// Row-level fallback for up/down when no cell is focused.
  DataGridState<T>? _rowNavFallback<T extends DataGridRow>(
    DataGridState<T> state,
  ) {
    if (direction != CellNavDirection.up &&
        direction != CellNavDirection.down) {
      return null;
    }

    // Respect row-selection mode guard
    if (state.selection.mode == SelectionMode.none) return null;

    final focusedRowId = state.selection.focusedRowId;

    if (direction == CellNavDirection.down) {
      if (focusedRowId == null) {
        if (state.displayOrder.isEmpty) return null;
        final first = state.displayOrder.first;
        return state.copyWith(
          selection: state.selection.copyWith(
            focusedRowId: first,
            selectedRowIds: {first},
          ),
        );
      }
      final idx = state.displayOrder.indexOf(focusedRowId);
      if (idx >= state.displayOrder.length - 1) return null;
      final next = state.displayOrder[idx + 1];
      return state.copyWith(
        selection: state.selection.copyWith(
          focusedRowId: next,
          selectedRowIds: {next},
        ),
      );
    } else {
      // up
      if (focusedRowId == null) return null;
      final idx = state.displayOrder.indexOf(focusedRowId);
      if (idx <= 0) return null;
      final prev = state.displayOrder[idx - 1];
      return state.copyWith(
        selection: state.selection.copyWith(
          focusedRowId: prev,
          selectedRowIds: {prev},
        ),
      );
    }
  }
}

/// Replaces the focused-cells path with the given list.
/// No SelectionMode guard — works regardless of mode.
class SetFocusedCellsEvent extends DataGridEvent {
  final List<String> cellIds;
  SetFocusedCellsEvent(this.cellIds);

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedCells: cellIds),
    );
  }
}

/// Copies the values of all focused cells to the system clipboard as TSV.
/// Cells are sorted by display-order row, then by column index.
/// Returns `null` — no state change, side-effect only.
class CopyCellsEvent extends DataGridEvent {
  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    final state = context.state;
    final focused = state.selection.focusedCells;
    if (focused.isEmpty) return null;

    // Build a column-id → column map for fast lookup
    final columnMap = <int, DataGridColumn<T>>{
      for (final col in state.columns) col.id: col,
    };

    // Parse and sort cells: by row display-order index, then column index
    final visibleColumns =
        state.effectiveColumns.where((c) => c.visible).toList();
    final colIndexMap = <int, int>{
      for (int i = 0; i < visibleColumns.length; i++) visibleColumns[i].id: i,
    };
    final rowIndexMap = <double, int>{
      for (int i = 0; i < state.displayOrder.length; i++)
        state.displayOrder[i]: i,
    };

    final parsed = <({int rowIdx, int colIdx, double rowId, int colId})>[];
    for (final cellId in focused) {
      final (rowId, colId) = parseCellId(cellId);
      final rowIdx = rowIndexMap[rowId];
      final colIdx = colIndexMap[colId];
      if (rowIdx == null || colIdx == null) continue;
      parsed.add((rowIdx: rowIdx, colIdx: colIdx, rowId: rowId, colId: colId));
    }

    // Build (rowIdx, colIdx) → value map
    final cellValues = <(int, int), String>{};
    for (final cell in parsed) {
      final row = state.rowsById[cell.rowId];
      final col = columnMap[cell.colId];
      final value = (row != null && col?.valueAccessor != null)
          ? col!.valueAccessor!(row)?.toString() ?? ''
          : '';
      cellValues[(cell.rowIdx, cell.colIdx)] = value;
    }

    // Collect unique sorted row and column indices
    final rowIndices = parsed.map((c) => c.rowIdx).toSet().toList()..sort();
    final colIndices = parsed.map((c) => c.colIdx).toSet().toList()..sort();

    // Build CSV: for every selected row, output a value for every selected
    // column index in order, using '' for gaps (cells not in the selection).
    // Values are quoted when they contain a comma, double-quote, or newline.
    String csvQuote(String value) {
      if (value.contains(',') || value.contains('"') || value.contains('\n')) {
        return '"${value.replaceAll('"', '""')}"';
      }
      return value;
    }

    final lines = rowIndices.map((rowIdx) {
      return colIndices
          .map((colIdx) => csvQuote(cellValues[(rowIdx, colIdx)] ?? ''))
          .join(',');
    });

    final csv = lines.join('\n');
    await Clipboard.setData(ClipboardData(text: csv));

    return null;
  }
}
