import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_header_viewport.dart';
import 'package:flutter_data_grid/renderers/filter_renderer.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class DataGridFilterRow<T extends DataGridRow> extends StatelessWidget {
  final FilterRenderer defaultFilterRenderer;

  const DataGridFilterRow({super.key, required this.defaultFilterRenderer});

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>({DataGridAspect.columns})!;
    final scrollController = context.gridScrollController<T>()!;
    final theme = DataGridTheme.of(context);
    final hasFilterableColumns = state.columns.any(
      (col) => col.filterable && col.visible,
    );

    if (!hasFilterableColumns) {
      return const SizedBox.shrink();
    }

    final columns = context.dataGridEffectiveColumns<T>()!;
    final visibleColumns = columns
        .where((c) => c.visible)
        .toList();
    final unpinnedFirst = [
      ...visibleColumns.where((c) => !c.pinned),
      ...visibleColumns.where((c) => c.pinned),
    ];

    return DataGridHeaderViewport<T>(
      columns: columns,
      horizontalController: scrollController.horizontalController,
      pinnedBackgroundColor: theme.colors.filterBackgroundColor,
      childColumnIds: unpinnedFirst.map((c) => c.id).toList(),
      children: [
        for (var column in unpinnedFirst)
          _FilterCell<T>(
            key: ValueKey('filter_${column.id}'),
            column: column,
            defaultFilterRenderer: defaultFilterRenderer,
          ),
      ],
    );
  }
}

class _FilterCell<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final FilterRenderer defaultFilterRenderer;

  const _FilterCell({
    super.key,
    required this.column,
    required this.defaultFilterRenderer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({DataGridAspect.filter})!;
    final controller = context.dataGridController<T>()!;

    Widget cell;
    if (!column.filterable) {
      cell = Container(
        decoration: BoxDecoration(
          color: theme.colors.filterBackgroundColor,
          border: theme.borders.filterBorder,
        ),
      );
    } else {
      final currentFilter = state.filter.columnFilters[column.id];
      final renderer = column.filterRenderer ?? defaultFilterRenderer;

      cell = renderer.buildFilter(
        context,
        column,
        currentFilter,
        (operator, value) {
          controller.addEvent(
            FilterEvent(columnId: column.id, operator: operator, value: value),
          );
        },
        () {
          controller.addEvent(ClearFilterEvent(columnId: column.id));
        },
      );
    }

    // Add pinned column styling
    if (column.pinned) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colors.evenRowColor,
          border: theme.borders.pinnedBorder,
          boxShadow: theme.borders.pinnedShadow,
        ),
        child: cell,
      );
    }

    return cell;
  }
}
