import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/widgets/data_grid_scroll_view.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_cell.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:flutter_data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

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

/// Custom scroll physics with more momentum for smoother horizontal scrolling
class _SmoothScrollPhysics extends ClampingScrollPhysics {
  const _SmoothScrollPhysics({super.parent});

  @override
  _SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity.abs() < toleranceFor(position).velocity) ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    // Lower friction = slower deceleration = more momentum feel
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      friction: 0.015, // Lower friction for more momentum (default is ~0.135)
    );
  }
}

class DataGridBody<T extends DataGridRow> extends StatelessWidget {
  final double rowHeight;
  final double? cacheExtent;

  const DataGridBody({super.key, required this.rowHeight, this.cacheExtent});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>()!;
    final scrollController = context.gridScrollController<T>()!;
    final scrollbarWidth = theme.dimensions.scrollbarWidth;
    final pinnedWidth = state.effectiveColumns
        .where((col) => col.pinned && col.visible)
        .fold<double>(0.0, (sum, col) => sum + col.width);

    // Handle empty state - just show empty area, no scrolling needed
    if (state.displayOrder.isEmpty) {
      return const SizedBox.expand();
    }
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: const _DataGridScrollBehavior().copyWith(scrollbars: false),
              child: DataGridScrollView(
                columns: state.effectiveColumns,
                rowCount: state.displayOrder.length,
                rowHeight: rowHeight,
                cacheExtent: cacheExtent,
                pinnedMaskColor: theme.colors.evenRowColor,
                verticalDetails: ScrollableDetails.vertical(controller: scrollController.verticalController),
                horizontalDetails: ScrollableDetails.horizontal(
                  controller: scrollController.horizontalController,
                  physics: const _SmoothScrollPhysics(),
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
          // Vertical scrollbar
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
          // Horizontal scrollbar (positioned after pinned columns)
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
      ),
    );
  }
}
