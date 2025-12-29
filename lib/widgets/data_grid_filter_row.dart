import 'package:data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter/material.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/events/grid_events.dart';
import 'package:data_grid/delegates/header_layout_delegate.dart';
import 'package:data_grid/renderers/filter_renderer.dart';
import 'package:data_grid/theme/data_grid_theme.dart';

class DataGridFilterRow<T extends DataGridRow> extends StatefulWidget {
  final FilterRenderer defaultFilterRenderer;

  const DataGridFilterRow({super.key, required this.defaultFilterRenderer});

  @override
  State<DataGridFilterRow<T>> createState() => _DataGridFilterRowState<T>();
}

class _DataGridFilterRowState<T extends DataGridRow> extends State<DataGridFilterRow<T>> {
  late bool hasFilterableColumns;
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
    hasFilterableColumns = columns.any((col) => col.filterable && col.visible);
    pinnedColumns = columns.where((col) => col.pinned && col.visible).toList();
    unpinnedColumns = columns.where((col) => !col.pinned && col.visible).toList();
    pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;

    if (!hasFilterableColumns) {
      return const SizedBox.shrink();
    }

    if (pinnedColumns.isEmpty) {
      return CustomMultiChildLayout(
        delegate: HeaderLayoutDelegate(columns: state.effectiveColumns),
        children: [
          for (var column in state.effectiveColumns)
            LayoutId(
              id: column.id,
              child: _FilterCell<T>(column: column, defaultFilterRenderer: widget.defaultFilterRenderer),
            ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned(
          left: pinnedWidth,
          right: 0,
          top: 0,
          bottom: 0,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: scrollController.horizontalController,
              builder: (context, child) {
                final offset = scrollController.horizontalController.hasClients
                    ? scrollController.horizontalController.offset
                    : 0.0;
                return Transform.translate(
                  offset: Offset(-offset, 0),
                  child: SizedBox(
                    width: unpinnedWidth,
                    child: CustomMultiChildLayout(
                      delegate: HeaderLayoutDelegate(columns: unpinnedColumns),
                      children: [
                        for (var column in unpinnedColumns)
                          LayoutId(
                            id: column.id,
                            child: _FilterCell<T>(column: column, defaultFilterRenderer: widget.defaultFilterRenderer),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
                  color: theme.colors.evenRowColor,
                  border: theme.borders.pinnedBorder,
                  boxShadow: theme.borders.pinnedShadow,
                ),
                child: CustomMultiChildLayout(
                  delegate: HeaderLayoutDelegate(columns: pinnedColumns),
                  children: [
                    for (var column in pinnedColumns)
                      LayoutId(
                        id: column.id,
                        child: _FilterCell<T>(column: column, defaultFilterRenderer: widget.defaultFilterRenderer),
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

class _FilterCell<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final FilterRenderer defaultFilterRenderer;

  const _FilterCell({required this.column, required this.defaultFilterRenderer});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
    final controller = context.dataGridController<T>()!;

    if (!column.filterable) {
      return Container(
        decoration: BoxDecoration(color: theme.colors.filterBackgroundColor, border: theme.borders.filterBorder),
      );
    }

    final currentFilter = state.filter.columnFilters[column.id];
    final renderer = column.filterRenderer ?? defaultFilterRenderer;

    return renderer.buildFilter(
      context,
      column,
      currentFilter,
      (operator, value) {
        controller.addEvent(FilterEvent(columnId: column.id, operator: operator, value: value));
      },
      () {
        controller.addEvent(ClearFilterEvent(columnId: column.id));
      },
    );
  }
}
