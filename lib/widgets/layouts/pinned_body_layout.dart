import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/widgets/data_grid_inherited.dart';
import 'package:data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:data_grid/renderers/row_renderer.dart';
import 'package:data_grid/renderers/render_context.dart';
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

class PinnedBodyLayout<T extends DataGridRow> extends StatelessWidget {
  final List<DataGridColumn<T>> pinnedColumns;
  final List<DataGridColumn<T>> unpinnedColumns;
  final double pinnedWidth;
  final double unpinnedWidth;
  final double rowHeight;
  final RowRenderer<T> rowRenderer;

  const PinnedBodyLayout({
    super.key,
    required this.pinnedColumns,
    required this.unpinnedColumns,
    required this.pinnedWidth,
    required this.unpinnedWidth,
    required this.rowHeight,
    required this.rowRenderer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
    final controller = context.dataGridController<T>()!;
    final scrollController = context.gridScrollController<T>()!;
    final scrollbarWidth = theme.dimensions.scrollbarWidth;

    if (state.displayOrder.isEmpty) {
      final unpinnedWidth = unpinnedColumns.fold<double>(0, (sum, col) => sum + col.width);

      return Stack(
        children: [
          Positioned(
            left: pinnedWidth,
            right: 0,
            top: 0,
            bottom: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController.horizontalController,
              child: SizedBox(width: unpinnedWidth, height: double.infinity),
            ),
          ),
          Positioned(
            left: pinnedWidth,
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

    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                if (scrollController.horizontalController.hasClients) {
                  final offset = scrollController.horizontalController.offset;
                  final max = scrollController.horizontalController.position.maxScrollExtent;
                  final newOffset = (offset + event.scrollDelta.dx).clamp(0.0, max);
                  scrollController.horizontalController.jumpTo(newOffset);
                }
              }
            },
            onPointerMove: (event) {
              if (event.localPosition.dx > pinnedWidth && event.delta.dx.abs() > event.delta.dy.abs()) {
                if (scrollController.horizontalController.hasClients) {
                  final offset = scrollController.horizontalController.offset;
                  final max = scrollController.horizontalController.position.maxScrollExtent;
                  final newOffset = (offset - event.delta.dx).clamp(0.0, max);
                  scrollController.horizontalController.jumpTo(newOffset);
                }
              }
            },
            child: AnimatedBuilder(
              animation: scrollController.horizontalController,
              builder: (context, child) {
                final horizontalOffset = scrollController.horizontalController.hasClients
                    ? scrollController.horizontalController.offset
                    : 0.0;

                return ScrollConfiguration(
                  behavior: const _DataGridScrollBehavior().copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: scrollController.verticalController,
                    itemCount: state.displayOrder.length,
                    itemExtent: rowHeight,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      final rowId = state.displayOrder[index];
                      final row = state.rowsById[rowId]!;

                      final renderContext = RowRenderContext<T>(
                        controller: controller,
                        scrollController: scrollController,
                        pinnedColumns: pinnedColumns,
                        unpinnedColumns: unpinnedColumns,
                        pinnedWidth: pinnedWidth,
                        unpinnedWidth: unpinnedWidth,
                        horizontalOffset: horizontalOffset,
                        rowHeight: rowHeight,
                        isSelected: controller.state.selection.isRowSelected(row.id),
                        isHovered: false,
                      );

                      return rowRenderer.buildRow(context, row, index, renderContext);
                    },
                  ),
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
          left: pinnedWidth,
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
}
