/// How a cell value was persisted.
enum CellValueChangeSource {
  /// Written via [DataGridController.updateCell] or [UpdateCellEvent].
  programmatic,

  /// Written when an inline edit is committed.
  editCommit,
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
