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
final class GridGroupHeaderRow<T extends DataGridRow>
    extends GridDisplayRow<T> {
  /// Deterministic path key. A top-level group is `'$columnId:$value'`; a
  /// nested group appends its own segment to its parent's key, joined by
  /// `\u001F`. Passed to `ToggleGroupExpansionEvent` and used as the
  /// `GroupState.expandedGroups` key.
  final String groupKey;

  /// Nesting level, 0 for the outermost grouped column.
  final int depth;

  /// The id of the column rows are grouped by.
  final int columnId;

  /// Display title of the grouped column.
  final String columnTitle;

  /// Raw group value shared by every row in this group.
  final dynamic value;

  /// Formatted label shown in the band.
  final String displayLabel;

  /// Number of data rows in this group at any depth, regardless of expansion
  /// state.
  final int rowCount;

  /// Number of direct child groups, or `null` for the innermost level.
  final int? subgroupCount;

  /// Whether this group's contents are currently shown below the band.
  final bool isExpanded;

  const GridGroupHeaderRow({
    required this.groupKey,
    this.depth = 0,
    this.subgroupCount,
    required this.columnId,
    required this.columnTitle,
    required this.value,
    required this.displayLabel,
    required this.rowCount,
    required this.isExpanded,
  });
}
