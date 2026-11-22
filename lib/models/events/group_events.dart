import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/utils/grid_display_rows.dart';

/// Groups rows by the specified column.
///
/// By default the column is appended as the innermost grouping level, so
/// grouping by several columns in turn nests them. Pass [replace] to make
/// [columnId] the only grouped column instead. No-op if the column is
/// already grouped and [replace] is false.
class GroupByColumnEvent extends DataGridEvent {
  final int columnId;
  final bool replace;

  GroupByColumnEvent({required this.columnId, this.replace = false});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final group = context.state.group;
    if (replace) {
      return context.state.copyWith(
        group: group.copyWith(groupedColumnIds: [columnId]),
      );
    }
    if (group.groupedColumnIds.contains(columnId)) return null;

    return context.state.copyWith(
      group: group.copyWith(
        groupedColumnIds: [...group.groupedColumnIds, columnId],
      ),
    );
  }
}

/// Removes the grouping level for the specified column. Deeper levels move
/// up one level.
class UngroupColumnEvent extends DataGridEvent {
  final int columnId;

  UngroupColumnEvent({required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final group = context.state.group;
    final groupedColumns = List<int>.from(group.groupedColumnIds)
      ..remove(columnId);

    return context.state.copyWith(
      group: group.copyWith(
        groupedColumnIds: groupedColumns,
        expandedGroups: {
          for (final entry in group.expandedGroups.entries)
            if (!groupKeyReferencesColumn(entry.key, columnId))
              entry.key: entry.value,
        },
      ),
    );
  }
}

/// Replaces the grouped columns with [columnIds], outermost level first.
/// Pass an empty list to clear grouping. Resets expansion state, since
/// group keys encode the level order.
class SetGroupedColumnsEvent extends DataGridEvent {
  final List<int> columnIds;

  SetGroupedColumnsEvent({required this.columnIds});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(
      group: context.state.group.copyWith(
        groupedColumnIds: List<int>.unmodifiable(columnIds.toSet()),
        expandedGroups: {},
      ),
    );
  }
}

/// Toggles the expanded/collapsed state of a row group.
class ToggleGroupExpansionEvent extends DataGridEvent {
  final String groupKey;

  ToggleGroupExpansionEvent({required this.groupKey});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final expandedGroups = Map<String, bool>.from(
      context.state.group.expandedGroups,
    );

    // Invert the *effective* state (isGroupExpanded defaults to false when
    // absent), not just the literal map entry — otherwise the first toggle
    // on a never-touched group would set it to `false` (a no-op, since
    // that's already the default) instead of visibly expanding it.
    expandedGroups[groupKey] = !context.state.group.isGroupExpanded(groupKey);

    return context.state.copyWith(
      group: context.state.group.copyWith(expandedGroups: expandedGroups),
    );
  }
}

/// Expands every group at every level for the current rows.
class ExpandAllGroupsEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final state = context.state;
    final keys = collectGroupKeys<T>(
      displayOrder: state.displayOrder,
      rowsById: state.rowsById,
      columns: state.columns,
      group: state.group,
    );
    return state.copyWith(
      group: state.group.copyWith(expandedGroups: {for (final k in keys) k: true}),
    );
  }
}

/// Collapses every group at every level.
class CollapseAllGroupsEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(
      group: context.state.group.copyWith(expandedGroups: {}),
    );
  }
}
