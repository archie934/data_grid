import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/auto_height.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_header_cell.dart';
import 'package:flutter_data_grid/widgets/data_grid_filter_row.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/overlays/column_header_context_menu.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_header_viewport.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class DataGridHeader<T extends DataGridRow> extends StatelessWidget {
  final Widget defaultFilterWidget;
  final double headerHeight;

  /// When non-null, the header row measures its content and sizes itself
  /// (clamped to its min/max) instead of using the fixed [headerHeight].
  final AutoHeaderHeight? autoHeaderHeight;

  /// Called when the auto-measured header height changes. Ignored when
  /// [autoHeaderHeight] is null.
  final ValueChanged<double>? onHeightChanged;

  const DataGridHeader({
    super.key,
    required this.defaultFilterWidget,
    required this.headerHeight,
    this.autoHeaderHeight,
    this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({DataGridAspect.columns})!;
    final hasFilterableColumns = state.columns.any(
      (col) => col.filterable && col.visible,
    );

    final autoHeaderHeight = this.autoHeaderHeight;
    final headerRow = autoHeaderHeight != null
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: autoHeaderHeight.minHeight,
              maxHeight: autoHeaderHeight.maxHeight,
            ),
            child: _HeaderRow<T>(
              autoHeaderHeight: autoHeaderHeight,
              onHeightChanged: onHeightChanged,
            ),
          )
        : SizedBox(height: headerHeight, child: _HeaderRow<T>());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        headerRow,
        if (hasFilterableColumns)
          SizedBox(
            height: theme.dimensions.filterRowHeight,
            child: DataGridFilterRow<T>(
              defaultFilterWidget: defaultFilterWidget,
            ),
          ),
      ],
    );
  }
}

class _HeaderRow<T extends DataGridRow> extends StatelessWidget {
  final AutoHeaderHeight? autoHeaderHeight;
  final ValueChanged<double>? onHeightChanged;

  const _HeaderRow({this.autoHeaderHeight, this.onHeightChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>({
      DataGridAspect.columns,
      DataGridAspect.sort,
      DataGridAspect.group,
    })!;
    final scrollController = context.gridScrollController<T>()!;
    final theme = DataGridTheme.of(context);

    final columns = context.dataGridEffectiveColumns<T>()!;
    final visibleColumns = columns.where((c) => c.visible).toList();
    final unpinnedFirst = [
      ...visibleColumns.where((c) => !c.pinned),
      ...visibleColumns.where((c) => c.pinned),
    ];

    return DataGridHeaderViewport<T>(
      columns: columns,
      horizontalController: scrollController.horizontalController,
      pinnedBackgroundColor: theme.colors.headerColor,
      childColumnIds: unpinnedFirst.map((c) => c.id).toList(),
      autoHeaderHeight: autoHeaderHeight,
      onHeightChanged: onHeightChanged,
      children: [
        for (var column in unpinnedFirst)
          _HeaderCellWrapper<T>(
            key: ValueKey('header_${column.id}'),
            column: column,
            sortState: state.sort,
            groupState: state.group,
          ),
      ],
    );
  }
}

class _HeaderCellWrapper<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final SortState sortState;
  final GroupState groupState;

  const _HeaderCellWrapper({
    super.key,
    required this.column,
    required this.sortState,
    required this.groupState,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.dataGridController<T>()!;
    final theme = DataGridTheme.of(context);

    Widget cell;
    if (column.id == kSelectionColumnId) {
      cell = const SizedBox.expand();
    } else {
      // For pinned columns suppress the inner right border — the outer
      // wrapper Container already draws pinnedBorder on the right edge.
      final effectiveBorder = column.pinned
          ? Border(bottom: theme.borders.headerBorder.bottom)
          : null;

      cell = GestureDetector(
        onSecondaryTapDown: (details) => showColumnHeaderContextMenu<T>(
          context: context,
          globalPosition: details.globalPosition,
          column: column as DataGridColumn<T>,
          sortState: sortState,
          groupState: groupState,
          controller: controller,
        ),
        child: DataGridHeaderCell(
          column: column,
          sortState: sortState,
          borderOverride: effectiveBorder,
          onSort: (direction) {
            controller.addEvent(
              SortEvent(columnId: column.id, direction: direction),
            );
          },
          // newWidth is already clamped by the cell — just dispatch the event.
          onResize: (newWidth) {
            controller.addEvent(
              ColumnResizeEvent(columnId: column.id, newWidth: newWidth),
            );
          },
        ),
      );
    }

    // Add pinned column styling
    if (column.pinned) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colors.headerColor,
          border: theme.borders.pinnedBorder,
          boxShadow: theme.borders.pinnedShadow,
        ),
        child: cell,
      );
    }

    return cell;
  }
}
