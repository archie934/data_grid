import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/widgets/data_grid_scroll_view.dart';
import 'package:data_grid/widgets/cells/data_grid_cell.dart';
import 'package:data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:data_grid/widgets/data_grid_inherited.dart';
import 'package:data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:data_grid/widgets/layouts/pinned_body_layout.dart';
import 'package:data_grid/renderers/row_renderer.dart';
import 'package:data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/renderers/default_row_renderer.dart';
import 'package:data_grid/theme/data_grid_theme.dart';

class _DataGridScrollBehavior extends MaterialScrollBehavior {
  const _DataGridScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

class DataGridBody<T extends DataGridRow> extends StatefulWidget {
  final double rowHeight;
  final RowRenderer<T>? rowRenderer;
  final CellRenderer<T>? cellRenderer;

  const DataGridBody({super.key, required this.rowHeight, this.rowRenderer, this.cellRenderer});

  @override
  State<DataGridBody<T>> createState() => _DataGridBodyState<T>();
}

class _DataGridBodyState<T extends DataGridRow> extends State<DataGridBody<T>> {
  late List<DataGridColumn<T>> pinnedColumns;
  late List<DataGridColumn<T>> unpinnedColumns;
  late double pinnedWidth;
  late double unpinnedWidth;
  late RowRenderer<T> effectiveRowRenderer;
  List<DataGridColumn<T>> effectiveColumns = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.dataGridState<T>()!;
    _updateColumns(state.effectiveColumns);
    _updateRowRenderer();
  }

  @override
  void didUpdateWidget(DataGridBody<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowRenderer != widget.rowRenderer || oldWidget.cellRenderer != widget.cellRenderer) {
      _updateRowRenderer();
    }
  }

  bool _columnsEqual(List<DataGridColumn<T>> a, List<DataGridColumn<T>> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      final colA = a[i];
      final colB = b[i];

      if (colA.id != colB.id ||
          colA.pinned != colB.pinned ||
          colA.visible != colB.visible ||
          colA.width != colB.width) {
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

  void _updateRowRenderer() {
    effectiveRowRenderer = widget.rowRenderer ?? DefaultRowRenderer<T>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;
    final scrollbarWidth = theme.dimensions.scrollbarWidth;

    if (pinnedColumns.isEmpty) {
      if (state.displayOrder.isEmpty) {
        final totalWidth = state.effectiveColumns.fold<double>(0, (sum, col) => sum + col.width);

        return Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: scrollController.horizontalController,
                child: SizedBox(width: totalWidth, height: double.infinity),
              ),
            ),
            Positioned(
              left: 0,
              right: scrollbarWidth,
              bottom: 0,
              child: ListenableBuilder(
                listenable: scrollController.horizontalController,
                builder: (context, child) {
                  if (!scrollController.horizontalController.hasClients) {
                    return const SizedBox();
                  }
                  final position = scrollController.horizontalController.position;
                  if (!position.hasContentDimensions || !position.hasPixels || !position.hasViewportDimension) {
                    return const SizedBox();
                  }
                  final hasHorizontalScroll = position.maxScrollExtent > 0;
                  return hasHorizontalScroll
                      ? CustomHorizontalScrollbar(controller: scrollController.horizontalController)
                      : const SizedBox();
                },
              ),
            ),
          ],
        );
      }

      return GestureDetector(
        onPanUpdate: (details) {
          // Enable horizontal scroll with mouse/finger drag
          if (scrollController.horizontalController.hasClients && details.delta.dx.abs() > details.delta.dy.abs()) {
            final offset = scrollController.horizontalController.offset;
            final max = scrollController.horizontalController.position.maxScrollExtent;
            final newOffset = (offset - details.delta.dx).clamp(0.0, max);
            scrollController.horizontalController.jumpTo(newOffset);
          }
        },
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent && scrollController.horizontalController.hasClients) {
              // Handle Shift+Scroll (Windows) or direct horizontal scroll (trackpad)
              final dx = event.scrollDelta.dx;
              if (dx != 0) {
                final offset = scrollController.horizontalController.offset;
                final max = scrollController.horizontalController.position.maxScrollExtent;
                final newOffset = (offset + dx).clamp(0.0, max);
                scrollController.horizontalController.jumpTo(newOffset);
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              return false;
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: const _DataGridScrollBehavior().copyWith(scrollbars: false),
                    child: DataGridScrollView(
                      columns: state.effectiveColumns,
                      rowCount: state.displayOrder.length,
                      rowHeight: widget.rowHeight,
                      verticalDetails: ScrollableDetails.vertical(controller: scrollController.verticalController),
                      horizontalDetails: ScrollableDetails.horizontal(
                        controller: scrollController.horizontalController,
                      ),
                      cellBuilder: (context, rowIndex, columnIndex) {
                        final rowId = state.displayOrder[rowIndex];
                        final row = state.rowsById[rowId]!;
                        final column = state.effectiveColumns[columnIndex];

                        if (column.id == kSelectionColumnId) {
                          return DataGridCheckboxCell<T>(
                            key: ValueKey('cell_${row.id}_${column.id}'),
                            row: row,
                            rowId: row.id,
                            rowIndex: rowIndex,
                          );
                        }

                        return DataGridCell<T>(
                          key: ValueKey('cell_${row.id}_${column.id}'),
                          row: row,
                          rowId: row.id,
                          column: column,
                          rowIndex: rowIndex,
                          isPinned: column.pinned,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: scrollbarWidth,
                  child: ListenableBuilder(
                    listenable: scrollController.verticalController,
                    builder: (context, child) {
                      if (!scrollController.verticalController.hasClients) {
                        return const SizedBox();
                      }
                      final position = scrollController.verticalController.position;
                      if (!position.hasContentDimensions || !position.hasPixels || !position.hasViewportDimension) {
                        return const SizedBox();
                      }
                      final hasVerticalScroll = position.maxScrollExtent > 0;
                      return hasVerticalScroll
                          ? CustomVerticalScrollbar(controller: scrollController.verticalController)
                          : const SizedBox();
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: scrollbarWidth,
                  bottom: 0,
                  child: ListenableBuilder(
                    listenable: scrollController.horizontalController,
                    builder: (context, child) {
                      if (!scrollController.horizontalController.hasClients) {
                        return const SizedBox();
                      }
                      final position = scrollController.horizontalController.position;
                      if (!position.hasContentDimensions || !position.hasPixels || !position.hasViewportDimension) {
                        return const SizedBox();
                      }
                      final hasHorizontalScroll = position.maxScrollExtent > 0;
                      return hasHorizontalScroll
                          ? CustomHorizontalScrollbar(controller: scrollController.horizontalController)
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PinnedBodyLayout<T>(
      pinnedColumns: pinnedColumns,
      unpinnedColumns: unpinnedColumns,
      pinnedWidth: pinnedWidth,
      unpinnedWidth: unpinnedWidth,
      rowHeight: widget.rowHeight,
      rowRenderer: effectiveRowRenderer,
    );
  }
}
