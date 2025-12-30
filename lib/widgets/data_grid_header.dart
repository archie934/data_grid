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

class _HeaderRow<T extends DataGridRow> extends StatefulWidget {
  const _HeaderRow();

  @override
  State<_HeaderRow<T>> createState() => _HeaderRowState<T>();
}

class _HeaderRowState<T extends DataGridRow> extends State<_HeaderRow<T>> {
  late List<DataGridColumn<T>> pinnedColumns;
  late List<DataGridColumn<T>> unpinnedColumns;
  late double pinnedWidth;
  late double unpinnedWidth;
  List<DataGridColumn<T>> effectiveColumns = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.dataGridState<T>()!;
    _updateColumns(state.effectiveColumns);
  }

  bool _columnsEqual(List<DataGridColumn<T>> a, List<DataGridColumn<T>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].pinned != b[i].pinned ||
          a[i].visible != b[i].visible ||
          a[i].width != b[i].width) {
        return false;
      }
    }
    return true;
  }

  void _updateColumns(List<DataGridColumn<T>> columns) {
    if (_columnsEqual(effectiveColumns, columns)) return;
    effectiveColumns = columns;
    pinnedColumns = columns.where((col) => col.pinned && col.visible).toList();
    unpinnedColumns = columns.where((col) => !col.pinned && col.visible).toList();
    pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;

    if (pinnedColumns.isEmpty) {
      return AnimatedBuilder(
        animation: scrollController.horizontalController,
        builder: (context, child) {
          final horizontalOffset = scrollController.horizontalController.hasClients
              ? scrollController.horizontalController.offset
              : 0.0;

          return CustomMultiChildLayout(
            delegate: HeaderLayoutDelegate(columns: state.effectiveColumns, horizontalOffset: horizontalOffset),
            children: [
              for (var column in state.effectiveColumns)
                LayoutId(
                  id: column.id,
                  child: _HeaderCellWrapper<T>(column: column, sortState: state.sort),
                ),
            ],
          );
        },
      );
    }

    return Stack(
      children: [
        Positioned(
          left: pinnedWidth,
          right: 0,
          top: 0,
          bottom: 0,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: scrollController.horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: unpinnedWidth,
                child: CustomMultiChildLayout(
                  delegate: HeaderLayoutDelegate(columns: unpinnedColumns),
                  children: [
                    for (var column in unpinnedColumns)
                      LayoutId(
                        id: column.id,
                        child: _HeaderCellWrapper<T>(column: column, sortState: state.sort),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: pinnedWidth,
          child: Builder(
            builder: (context) {
              final theme = DataGridTheme.of(context);
              return Container(
                decoration: BoxDecoration(
                  color: theme.colors.headerColor,
                  border: theme.borders.pinnedBorder,
                  boxShadow: theme.borders.pinnedShadow,
                ),
                child: CustomMultiChildLayout(
                  delegate: HeaderLayoutDelegate(columns: pinnedColumns),
                  children: [
                    for (var column in pinnedColumns)
                      LayoutId(
                        id: column.id,
                        child: _HeaderCellWrapper<T>(column: column, sortState: state.sort),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

    if (column.id == kSelectionColumnId) {
      return DataGridCheckboxHeaderCell<T>();
    }

    return DataGridHeaderCell(
      column: column,
      sortState: sortState,
      onSort: (direction) {
        controller.addEvent(SortEvent(columnId: column.id, direction: direction));
      },
      onResize: (delta) {
        final theme = DataGridTheme.of(context);
        final newWidth = (column.width + delta).clamp(theme.dimensions.columnMinWidth, theme.dimensions.columnMaxWidth);
        controller.addEvent(ColumnResizeEvent(columnId: column.id, newWidth: newWidth));
      },
    );
  }
}
