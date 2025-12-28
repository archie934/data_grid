import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/header_layout_delegate.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_header_cell.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:data_grid/data_grid/widgets/data_grid_filter_row.dart';
import 'package:data_grid/data_grid/renderers/filter_renderer.dart';
import 'package:data_grid/data_grid/theme/data_grid_theme.dart';

class DataGridHeader<T extends DataGridRow> extends StatelessWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final FilterRenderer defaultFilterRenderer;
  final double headerHeight;

  const DataGridHeader({
    super.key,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.defaultFilterRenderer,
    required this.headerHeight,
  });

  bool get hasFilterableColumns => state.columns.any((col) => col.filterable && col.visible);

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: headerHeight,
          child: _HeaderRow<T>(state: state, controller: controller, scrollController: scrollController),
        ),
        if (hasFilterableColumns)
          SizedBox(
            height: theme.dimensions.filterRowHeight,
            child: DataGridFilterRow<T>(
              state: state,
              controller: controller,
              scrollController: scrollController,
              defaultFilterRenderer: defaultFilterRenderer,
            ),
          ),
      ],
    );
  }
}

class _HeaderRow<T extends DataGridRow> extends StatefulWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;

  const _HeaderRow({required this.state, required this.controller, required this.scrollController});

  @override
  State<_HeaderRow<T>> createState() => _HeaderRowState<T>();
}

class _HeaderRowState<T extends DataGridRow> extends State<_HeaderRow<T>> {
  late List<DataGridColumn> pinnedColumns;
  late List<DataGridColumn> unpinnedColumns;

  @override
  void initState() {
    super.initState();
    _updateColumns();
  }

  @override
  void didUpdateWidget(_HeaderRow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_columnsEqual(oldWidget.state.effectiveColumns, widget.state.effectiveColumns)) {
      _updateColumns();
    }
  }

  bool _columnsEqual(List<DataGridColumn> a, List<DataGridColumn> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].pinned != b[i].pinned || a[i].visible != b[i].visible || a[i].width != b[i].width) {
        return false;
      }
    }
    return true;
  }

  void _updateColumns() {
    pinnedColumns = widget.state.effectiveColumns.where((col) => col.pinned && col.visible).toList();
    unpinnedColumns = widget.state.effectiveColumns.where((col) => !col.pinned && col.visible).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (pinnedColumns.isEmpty) {
      return CustomMultiChildLayout(
        delegate: HeaderLayoutDelegate(columns: widget.state.effectiveColumns),
        children: [
          for (var column in widget.state.effectiveColumns)
            LayoutId(
              id: column.id,
              child: _HeaderCellWrapper<T>(column: column, controller: widget.controller, sortState: widget.state.sort),
            ),
        ],
      );
    }

    final pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    final unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);

    return Stack(
      children: [
        Positioned(
          left: pinnedWidth,
          right: 0,
          top: 0,
          bottom: 0,
          child: SingleChildScrollView(
            controller: widget.scrollController.horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: unpinnedWidth,
              child: CustomMultiChildLayout(
                delegate: HeaderLayoutDelegate(columns: unpinnedColumns),
                children: [
                  for (var column in unpinnedColumns)
                    LayoutId(
                      id: column.id,
                      child: _HeaderCellWrapper<T>(
                        column: column,
                        controller: widget.controller,
                        sortState: widget.state.sort,
                      ),
                    ),
                ],
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
                        child: _HeaderCellWrapper<T>(
                          column: column,
                          controller: widget.controller,
                          sortState: widget.state.sort,
                        ),
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
  final DataGridController<T> controller;
  final SortState sortState;

  const _HeaderCellWrapper({required this.column, required this.controller, required this.sortState});

  @override
  Widget build(BuildContext context) {
    if (column.id == kSelectionColumnId) {
      return DataGridCheckboxHeaderCell<T>(controller: controller);
    }

    return DataGridHeaderCell(
      column: column,
      sortState: sortState,
      onSort: (direction) {
        controller.addEvent(SortEvent(columnId: column.id, direction: direction, multiSort: false));
      },
      onResize: (delta) {
        final theme = DataGridTheme.of(context);
        final newWidth = (column.width + delta).clamp(theme.dimensions.columnMinWidth, theme.dimensions.columnMaxWidth);
        controller.addEvent(ColumnResizeEvent(columnId: column.id, newWidth: newWidth));
      },
    );
  }
}
