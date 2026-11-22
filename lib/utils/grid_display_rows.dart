import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

// Unit separator: won't collide with characters found in ordinary cell values.
const _groupKeySeparator = '\u001F';

/// Whether [groupKey] contains a level grouped by [columnId].
bool groupKeyReferencesColumn(String groupKey, int columnId) {
  final prefix = '$columnId:';
  return groupKey
      .split(_groupKeySeparator)
      .any((segment) => segment.startsWith(prefix));
}

/// Turns [displayOrder] into the flat list of visual row slots the
/// virtualized grid body renders, applying (possibly nested) row grouping
/// when `group.hasGroups` is true.
///
/// Ungrouped rows pass through unchanged, one [GridDataRow] per id. Grouped
/// rows are partitioned level by level, in `group.groupedColumnIds` order,
/// via a **stable bucket-by-value** pass (not a re-sort), so both the order
/// groups first appear in and the relative order of rows within a group are
/// preserved regardless of the current sort column. A [GridGroupHeaderRow]
/// precedes each group's contents; contents are omitted when the group (or
/// any ancestor group) is collapsed.
List<GridDisplayRow<T>> computeDisplayRows<T extends DataGridRow>({
  required List<double> displayOrder,
  required Map<double, T> rowsById,
  required List<DataGridColumn<T>> columns,
  required GroupState group,
}) {
  final levels = _resolveGroupColumns(columns, group);
  if (levels.isEmpty) {
    return [for (final id in displayOrder) GridDataRow<T>(id)];
  }

  final result = <GridDisplayRow<T>>[];

  void emit(List<_Bucket> buckets, int level) {
    final column = levels[level];
    final isInnermost = level == levels.length - 1;
    final formatter = column.cellFormatter as CellFormatter<T>?;

    for (final bucket in buckets) {
      final isExpanded = group.isGroupExpanded(bucket.key);
      final children = isInnermost
          ? null
          : _bucketize(bucket.ids, rowsById, levels[level + 1], bucket.key);
      final firstRow = rowsById[bucket.ids.first]!;

      result.add(
        GridGroupHeaderRow<T>(
          groupKey: bucket.key,
          depth: level,
          columnId: column.id,
          columnTitle: column.title,
          value: bucket.value,
          displayLabel:
              formatter?.call(firstRow, column) ?? bucket.value.toString(),
          rowCount: bucket.ids.length,
          subgroupCount: children?.length,
          isExpanded: isExpanded,
        ),
      );

      if (!isExpanded) continue;
      if (children != null) {
        emit(children, level + 1);
      } else {
        for (final id in bucket.ids) {
          result.add(GridDataRow<T>(id));
        }
      }
    }
  }

  emit(_bucketize(displayOrder, rowsById, levels.first, null), 0);
  return result;
}

/// Every group key that grouping [displayOrder] by `group.groupedColumnIds`
/// would produce, at all levels, ignoring expansion state.
List<String> collectGroupKeys<T extends DataGridRow>({
  required List<double> displayOrder,
  required Map<double, T> rowsById,
  required List<DataGridColumn<T>> columns,
  required GroupState group,
}) {
  final levels = _resolveGroupColumns(columns, group);
  final keys = <String>[];

  void walk(List<double> ids, int level, String? parentKey) {
    if (level >= levels.length) return;
    for (final bucket in _bucketize(ids, rowsById, levels[level], parentKey)) {
      keys.add(bucket.key);
      walk(bucket.ids, level + 1, bucket.key);
    }
  }

  walk(displayOrder, 0, null);
  return keys;
}

List<DataGridColumn<T>> _resolveGroupColumns<T extends DataGridRow>(
  List<DataGridColumn<T>> columns,
  GroupState group,
) {
  if (!group.hasGroups) return const [];
  final byId = {for (final c in columns) c.id: c};
  return [
    for (final id in group.groupedColumnIds)
      if (byId[id] case final column?) column,
  ];
}

class _Bucket {
  final String key;
  final dynamic value;
  final List<double> ids = [];

  _Bucket(this.key, this.value);
}

List<_Bucket> _bucketize<T extends DataGridRow>(
  List<double> ids,
  Map<double, T> rowsById,
  DataGridColumn<T> column,
  String? parentKey,
) {
  final buckets = <String, _Bucket>{};
  for (final id in ids) {
    final row = rowsById[id];
    if (row == null) continue;

    final value = column.valueAccessor?.call(row);
    final segment = '${column.id}:$value';
    final key = parentKey == null
        ? segment
        : '$parentKey$_groupKeySeparator$segment';
    buckets.putIfAbsent(key, () => _Bucket(key, value)).ids.add(id);
  }
  return buckets.values.toList();
}
