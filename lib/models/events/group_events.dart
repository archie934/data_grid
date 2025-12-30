import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

class GroupByColumnEvent extends DataGridEvent {
  final int columnId;

  GroupByColumnEvent({required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final groupedColumns = List<int>.from(context.state.group.groupedColumnIds);

    if (!groupedColumns.contains(columnId)) {
      groupedColumns.add(columnId);
    }

    return context.state.copyWith(group: context.state.group.copyWith(groupedColumnIds: groupedColumns));
  }
}

class UngroupColumnEvent extends DataGridEvent {
  final int columnId;

  UngroupColumnEvent({required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final groupedColumns = List<int>.from(context.state.group.groupedColumnIds);
    groupedColumns.remove(columnId);

    return context.state.copyWith(group: context.state.group.copyWith(groupedColumnIds: groupedColumns));
  }
}

class ToggleGroupExpansionEvent extends DataGridEvent {
  final String groupKey;

  ToggleGroupExpansionEvent({required this.groupKey});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final expandedGroups = Map<String, bool>.from(context.state.group.expandedGroups);

    if (expandedGroups.containsKey(groupKey)) {
      expandedGroups[groupKey] = !expandedGroups[groupKey]!;
    } else {
      expandedGroups[groupKey] = true;
    }

    return context.state.copyWith(group: context.state.group.copyWith(expandedGroups: expandedGroups));
  }
}
