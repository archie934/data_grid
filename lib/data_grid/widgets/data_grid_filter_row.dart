import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/header_layout_delegate.dart';
import 'package:data_grid/data_grid/renderers/filter_renderer.dart';

class DataGridFilterRow<T extends DataGridRow> extends StatefulWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final FilterRenderer defaultFilterRenderer;

  const DataGridFilterRow({
    super.key,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.defaultFilterRenderer,
  });

  @override
  State<DataGridFilterRow<T>> createState() => _DataGridFilterRowState<T>();
}

class _DataGridFilterRowState<T extends DataGridRow> extends State<DataGridFilterRow<T>> {
  late bool hasFilterableColumns;
  late List<DataGridColumn> pinnedColumns;
  late List<DataGridColumn> unpinnedColumns;

  @override
  void initState() {
    super.initState();
    _updateColumns();
  }

  @override
  void didUpdateWidget(DataGridFilterRow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.effectiveColumns != widget.state.effectiveColumns) {
      _updateColumns();
    }
  }

  void _updateColumns() {
    hasFilterableColumns = widget.state.effectiveColumns.any((col) => col.filterable && col.visible);
    pinnedColumns = widget.state.effectiveColumns.where((col) => col.pinned && col.visible).toList();
    unpinnedColumns = widget.state.effectiveColumns.where((col) => !col.pinned && col.visible).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasFilterableColumns) {
      return const SizedBox.shrink();
    }

    if (pinnedColumns.isEmpty) {
      return CustomMultiChildLayout(
        delegate: HeaderLayoutDelegate(columns: widget.state.effectiveColumns),
        children: [
          for (var column in widget.state.effectiveColumns)
            LayoutId(
              id: column.id,
              child: _FilterCell<T>(
                column: column,
                state: widget.state,
                controller: widget.controller,
                defaultFilterRenderer: widget.defaultFilterRenderer,
              ),
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
          child: ClipRect(
            child: AnimatedBuilder(
              animation: widget.scrollController.horizontalController,
              builder: (context, child) {
                final offset = widget.scrollController.horizontalController.hasClients
                    ? widget.scrollController.horizontalController.offset
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
                            child: _FilterCell<T>(
                              column: column,
                              state: widget.state,
                              controller: widget.controller,
                              defaultFilterRenderer: widget.defaultFilterRenderer,
                            ),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(2, 0)),
              ],
            ),
            child: CustomMultiChildLayout(
              delegate: HeaderLayoutDelegate(columns: pinnedColumns),
              children: [
                for (var column in pinnedColumns)
                  LayoutId(
                    id: column.id,
                    child: _FilterCell<T>(
                      column: column,
                      state: widget.state,
                      controller: widget.controller,
                      defaultFilterRenderer: widget.defaultFilterRenderer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterCell<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final FilterRenderer defaultFilterRenderer;

  const _FilterCell({
    required this.column,
    required this.state,
    required this.controller,
    required this.defaultFilterRenderer,
  });

  @override
  Widget build(BuildContext context) {
    if (!column.filterable) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            right: BorderSide(color: Colors.grey[400]!),
            bottom: BorderSide(color: Colors.grey[400]!),
          ),
        ),
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
