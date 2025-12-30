import 'package:flutter/material.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/grid_events.dart';
import 'package:data_grid/delegates/header_layout_delegate.dart';
import 'package:data_grid/widgets/cells/data_grid_header_cell.dart';
import 'package:data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:data_grid/widgets/data_grid_filter_row.dart';
import 'package:data_grid/widgets/data_grid_inherited.dart';
import 'package:data_grid/renderers/filter_renderer.dart';
import 'package:data_grid/theme/data_grid_theme.dart';

class DataGridHeader<T extends DataGridRow> extends StatelessWidget {
  final FilterRenderer defaultFilterRenderer;
  final double headerHeight;

  const DataGridHeader({super.key, required this.defaultFilterRenderer, required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
    final hasFilterableColumns = state.columns.any((col) => col.filterable && col.visible);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: headerHeight, child: _HeaderRow<T>()),
        if (hasFilterableColumns)
          SizedBox(
            height: theme.dimensions.filterRowHeight,
            child: DataGridFilterRow<T>(defaultFilterRenderer: defaultFilterRenderer),
          ),
      ],
    );
  }
}

class _HeaderRow<T extends DataGridRow> extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;

    return ClipRect(
      child: AnimatedBuilder(
        animation: scrollController.horizontalController,
        builder: (context, child) {
          final horizontalOffset = scrollController.horizontalController.hasClients
              ? scrollController.horizontalController.offset
              : 0.0;

          // Render unpinned columns first, then pinned columns last for correct z-ordering
          final visibleColumns = state.effectiveColumns.where((c) => c.visible).toList();
          final unpinnedFirst = [...visibleColumns.where((c) => !c.pinned), ...visibleColumns.where((c) => c.pinned)];

          return CustomMultiChildLayout(
            delegate: HeaderLayoutDelegate(columns: state.effectiveColumns, horizontalOffset: horizontalOffset),
            children: [
              for (var column in unpinnedFirst)
                LayoutId(
                  id: column.id,
                  child: _HeaderCellWrapper<T>(column: column, sortState: state.sort),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCellWrapper<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final SortState sortState;

  const _HeaderCellWrapper({required this.column, required this.sortState});

  @override
  Widget build(BuildContext context) {
    final controller = context.dataGridController<T>()!;
    final theme = DataGridTheme.of(context);

    Widget cell;
    if (column.id == kSelectionColumnId) {
      cell = DataGridCheckboxHeaderCell<T>();
    } else {
      cell = DataGridHeaderCell(
        column: column,
        sortState: sortState,
        onSort: (direction) {
          controller.addEvent(SortEvent(columnId: column.id, direction: direction));
        },
        onResize: (delta) {
          final newWidth = (column.width + delta).clamp(
            theme.dimensions.columnMinWidth,
            theme.dimensions.columnMaxWidth,
          );
          controller.addEvent(ColumnResizeEvent(columnId: column.id, newWidth: newWidth));
        },
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
