import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/delegates/header_layout_delegate.dart';
import 'package:flutter_data_grid/renderers/filter_renderer.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class DataGridFilterRow<T extends DataGridRow> extends StatelessWidget {
  final FilterRenderer defaultFilterRenderer;

  const DataGridFilterRow({super.key, required this.defaultFilterRenderer});

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;
    final hasFilterableColumns = state.columns.any(
      (col) => col.filterable && col.visible,
    );

    if (!hasFilterableColumns) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: AnimatedBuilder(
        animation: scrollController.horizontalController,
        builder: (context, child) {
          final horizontalOffset =
              scrollController.horizontalController.hasClients
              ? scrollController.horizontalController.offset
              : 0.0;

          // Render unpinned columns first, then pinned columns last for correct z-ordering
          final visibleColumns = state.effectiveColumns
              .where((c) => c.visible)
              .toList();
          final unpinnedFirst = [
            ...visibleColumns.where((c) => !c.pinned),
            ...visibleColumns.where((c) => c.pinned),
          ];

          return CustomMultiChildLayout(
            delegate: HeaderLayoutDelegate(
              columns: state.effectiveColumns,
              horizontalOffset: horizontalOffset,
            ),
            children: [
              for (var column in unpinnedFirst)
                LayoutId(
                  id: column.id,
                  child: _FilterCell<T>(
                    column: column,
                    defaultFilterRenderer: defaultFilterRenderer,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterCell<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final FilterRenderer defaultFilterRenderer;

  const _FilterCell({
    required this.column,
    required this.defaultFilterRenderer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
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
