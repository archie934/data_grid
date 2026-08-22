import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

/// Groups rows by the specified column.
///
/// v1 supports only a single active grouped column: applying this event
/// replaces `groupedColumnIds` rather than appending to it. The field stays
/// a `List<int>` for forward compatibility with future multi-level grouping.
class GroupByColumnEvent extends DataGridEvent {
  final int columnId;

  GroupByColumnEvent({required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(
      group: context.state.group.copyWith(groupedColumnIds: [columnId]),
    );
  }
}

/// Removes grouping for the specified column.
class UngroupColumnEvent extends DataGridEvent {
  final int columnId;

  UngroupColumnEvent({required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final groupedColumns = List<int>.from(context.state.group.groupedColumnIds);
    groupedColumns.remove(columnId);

    return context.state.copyWith(
      group: context.state.group.copyWith(groupedColumnIds: groupedColumns),
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
