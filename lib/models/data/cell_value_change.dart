enum CellValueChangeSource { programmatic, editCommit }

class CellValueChange {
  final double rowId;
  final int columnId;
  final dynamic value;
  final CellValueChangeSource source;

  const CellValueChange({
    required this.rowId,
    required this.columnId,
    required this.value,
    this.source = CellValueChangeSource.programmatic,
  });

  String get cellId => '${rowId}_$columnId';

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
