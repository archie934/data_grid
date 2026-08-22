import 'package:flutter_data_grid/models/data/row.dart';

/// A single visual row slot in the virtualized grid body: either a data row
/// or a group header band. Produced by `computeDisplayRows`.
sealed class GridDisplayRow<T extends DataGridRow> {
  const GridDisplayRow();
}

/// A slot rendering the row identified by [rowId] (an id from
/// `DataGridState.displayOrder` / a key into `DataGridState.rowsById`).
final class GridDataRow<T extends DataGridRow> extends GridDisplayRow<T> {
  final double rowId;

  const GridDataRow(this.rowId);
}

/// A slot rendering a collapsible group header band.
final class GridGroupHeaderRow<T extends DataGridRow> extends GridDisplayRow<T> {
  /// Deterministic key, e.g. `'$columnId:$value'`. Passed to
  /// `ToggleGroupExpansionEvent` and used as the `GroupState.expandedGroups` key.
  final String groupKey;

  /// The id of the column rows are grouped by.
  final int columnId;

  /// Display title of the grouped column.
  final String columnTitle;

  /// Raw group value shared by every row in this group.
  final dynamic value;

  /// Formatted label shown in the band.
  final String displayLabel;

  /// Number of rows in this group, regardless of expansion state.
  final int rowCount;

  /// Whether this group's rows are currently shown below the band.
  final bool isExpanded;

  const GridGroupHeaderRow({
    required this.groupKey,
    required this.columnId,
    required this.columnTitle,
    required this.value,
    required this.displayLabel,
    required this.rowCount,
    required this.isExpanded,
  });
}
