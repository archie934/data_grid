/// How a cell value was persisted.
enum CellValueChangeSource {
  /// Written via [DataGridController.updateCell] or [UpdateCellEvent].
  programmatic,

  /// Written when an inline edit is committed.
  editCommit,

  /// Not a write at all — an explicit [RefreshCellsEvent] asking the affected
  /// cells to re-read their value. Used when a row was mutated outside the
  /// grid's own edit path, or when a custom `cellWidget` renders something the
  /// grid can't see (see [CellValueChange.forcesRefresh]).
  refresh,
}

/// Notification that a single cell value was persisted in place.
///
/// Emitted on [DataGridController.cellValueChanges] when [UpdateCellEvent] or
/// [CommitCellEditEvent] runs without replacing the row map.
class CellValueChange {
  /// Row identifier of the updated cell.
  final double rowId;

  /// Column identifier of the updated cell.
  final int columnId;

  /// Value written by the column's [DataGridColumn.cellValueSetter].
  final dynamic value;

  /// Whether the change came from programmatic update or edit commit.
  final CellValueChangeSource source;

  /// Creates a [CellValueChange] for the cell at [rowId] / [columnId].
  const CellValueChange({
    required this.rowId,
    required this.columnId,
    required this.value,
    this.source = CellValueChangeSource.programmatic,
  });

  /// Composite cell id (`"${rowId}_${columnId}"`).
  String get cellId => '${rowId}_$columnId';

  /// Whether this change applies to the cell at [rowId] / [columnId].
  bool affectsCell(double rowId, int columnId) =>
      this.rowId == rowId && this.columnId == columnId;

  /// Whether this change could affect any cell of [rowId].
  ///
  /// This is the *candidate* filter, not the rebuild decision. A
  /// [DataGridColumn.valueAccessor] is handed the whole row, so a
  /// `cellValueSetter` that touches anything beyond the column it was invoked
  /// for changes other columns too — the example's Quantity setter calls
  /// `row.updateTotal()`, and the Total column reads `row.total`. Filtering on
  /// [affectsCell] alone left every such derived cell stale until something
  /// unrelated happened to rebuild it.
  ///
  /// Widening the filter to the row is *not* on its own the fix: that would
  /// rebuild all 60 cells of a 60-column row for a one-field edit. So the row
  /// is only where the search starts — each candidate cell then re-runs its own
  /// `valueAccessor` and rebuilds only if the value it renders actually
  /// changed. See `_DataGridCellState._shouldRefreshValue`.
  bool affectsRow(double rowId) => this.rowId == rowId;

  /// Whether candidate cells must rebuild without consulting the value diff.
  ///
  /// The diff can only see what `valueAccessor` returns. A column with no
  /// accessor, or a custom `cellWidget` that reads fields straight off
  /// `CellScope.row`, renders something the grid cannot compare — so an
  /// explicit [RefreshCellsEvent] bypasses the diff entirely.
  bool get forcesRefresh => source == CellValueChangeSource.refresh;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellValueChange &&
          rowId == other.rowId &&
          columnId == other.columnId &&
          value == other.value &&
          source == other.source;

  @override
  int get hashCode => Object.hash(rowId, columnId, value, source);
}
