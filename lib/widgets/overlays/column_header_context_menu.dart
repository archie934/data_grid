import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

/// Shows the header right-click context menu for [column] at [globalPosition]:
/// sort actions (if sortable), group/ungroup (if groupable), and hide column.
void showColumnHeaderContextMenu<T extends DataGridRow>({
  required BuildContext context,
  required Offset globalPosition,
  required DataGridColumn<T> column,
  required SortState sortState,
  required GroupState groupState,
  required DataGridController<T> controller,
}) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final position = RelativeRect.fromRect(
    globalPosition & const Size(1, 1),
    Offset.zero & overlay.size,
  );

  final isGrouped = groupState.groupedColumnIds.contains(column.id);

  showMenu<void>(
    context: context,
    position: position,
    items: [
      if (column.sortable) ...[
        _SortAscendingMenuItem(columnId: column.id, controller: controller),
        _SortDescendingMenuItem(columnId: column.id, controller: controller),
        _ClearSortMenuItem(columnId: column.id, controller: controller),
      ],
      if (column.sortable && (column.groupable || column.visible))
        const PopupMenuDivider(),
      if (column.groupable)
        _GroupByMenuItem(
          columnId: column.id,
          isGrouped: isGrouped,
          controller: controller,
        ),
      if (column.groupable && column.visible) const PopupMenuDivider(),
      if (column.visible)
        _HideColumnMenuItem(columnId: column.id, controller: controller),
    ],
  );
}

class _SortAscendingMenuItem extends PopupMenuItem<void> {
  _SortAscendingMenuItem({
    required int columnId,
    required DataGridController controller,
  }) : super(
         onTap: () => controller.addEvent(
           SortEvent(columnId: columnId, direction: SortDirection.ascending),
         ),
         child: const Text('Sort Ascending'),
       );
}

class _SortDescendingMenuItem extends PopupMenuItem<void> {
  _SortDescendingMenuItem({
    required int columnId,
    required DataGridController controller,
  }) : super(
         onTap: () => controller.addEvent(
           SortEvent(columnId: columnId, direction: SortDirection.descending),
         ),
         child: const Text('Sort Descending'),
       );
}

class _ClearSortMenuItem extends PopupMenuItem<void> {
  _ClearSortMenuItem({
    required int columnId,
    required DataGridController controller,
  }) : super(
         onTap: () => controller.addEvent(SortEvent(columnId: columnId)),
         child: const Text('Clear Sort'),
       );
}

class _GroupByMenuItem extends PopupMenuItem<void> {
  _GroupByMenuItem({
    required int columnId,
    required bool isGrouped,
    required DataGridController controller,
  }) : super(
         onTap: () => controller.addEvent(
           isGrouped
               ? UngroupColumnEvent(columnId: columnId)
               : GroupByColumnEvent(columnId: columnId),
         ),
         child: Text(isGrouped ? 'Remove Grouping' : 'Group by This Column'),
       );
}

class _HideColumnMenuItem extends PopupMenuItem<void> {
  _HideColumnMenuItem({
    required int columnId,
    required DataGridController controller,
  }) : super(
         onTap: () => controller.addEvent(
           SetColumnVisibilityEvent(columnId: columnId, visible: false),
         ),
         child: const Text('Hide Column'),
       );
}
