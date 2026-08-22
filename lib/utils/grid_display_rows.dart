import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

/// Turns [displayOrder] into the flat list of visual row slots the
/// virtualized grid body renders, applying row grouping when
/// `group.hasGroups` is true.
///
/// Ungrouped rows pass through unchanged, one [GridDataRow] per id. Grouped
/// rows are partitioned by the grouped column's value via a **stable
/// bucket-by-value** pass over [displayOrder] (not a re-sort), so both the
/// order groups first appear in and the relative order of rows within a
/// group are preserved regardless of the current sort column. A
/// [GridGroupHeaderRow] precedes each group's [GridDataRow] members; members
/// are omitted when the group is collapsed.
List<GridDisplayRow<T>> computeDisplayRows<T extends DataGridRow>({
  required List<double> displayOrder,
  required Map<double, T> rowsById,
  required List<DataGridColumn<T>> columns,
  required GroupState group,
}) {
  if (!group.hasGroups) {
    return [for (final id in displayOrder) GridDataRow<T>(id)];
  }

  DataGridColumn<T>? column;
  for (final c in columns) {
    if (c.id == group.groupedColumnIds.first) {
      column = c;
      break;
    }
  }
  if (column == null) {
    return [for (final id in displayOrder) GridDataRow<T>(id)];
  }
  final groupColumn = column;

  final bucketOrder = <String>[];
  final bucketIds = <String, List<double>>{};
  final bucketValues = <String, dynamic>{};

  for (final id in displayOrder) {
    final row = rowsById[id];
    if (row == null) continue;

    final value = groupColumn.valueAccessor?.call(row);
    final groupKey = '${groupColumn.id}:$value';

    final bucket = bucketIds.putIfAbsent(groupKey, () {
      bucketOrder.add(groupKey);
      bucketValues[groupKey] = value;
      return <double>[];
    });
    bucket.add(id);
  }

  final result = <GridDisplayRow<T>>[];
  for (final groupKey in bucketOrder) {
    final ids = bucketIds[groupKey]!;
    final value = bucketValues[groupKey];
    final isExpanded = group.isGroupExpanded(groupKey);
    final firstRow = rowsById[ids.first]!;
    final formatter = groupColumn.cellFormatter as CellFormatter<T>?;
    final displayLabel = formatter?.call(firstRow, groupColumn) ?? value.toString();

    result.add(
      GridGroupHeaderRow<T>(
        groupKey: groupKey,
        columnId: groupColumn.id,
        columnTitle: groupColumn.title,
        value: value,
        displayLabel: displayLabel,
        rowCount: ids.length,
        isExpanded: isExpanded,
      ),
    );

    if (isExpanded) {
      for (final id in ids) {
        result.add(GridDataRow<T>(id));
      }
    }
  }

  return result;
}
