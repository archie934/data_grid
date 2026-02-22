import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/data_grid_scroll_view.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:flutter_data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport_delegate.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class _DataGridScrollBehavior extends MaterialScrollBehavior {
  const _DataGridScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.trackpad};
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
    if ((velocity.abs() < toleranceFor(position).velocity) || (velocity > 0.0 && position.pixels >= position.maxScrollExtent) || (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      friction: 0.015,
    );
  }
}

class DataGridBody<T extends DataGridRow> extends StatefulWidget {
  final double rowHeight;
  final double cacheExtent;

  const DataGridBody({super.key, required this.rowHeight, required this.cacheExtent});

  @override
  State<DataGridBody<T>> createState() => _DataGridBodyState<T>();
}

class _DataGridBodyState<T extends DataGridRow> extends State<DataGridBody<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({
      DataGridAspect.data,
      DataGridAspect.columns,
    })!;
    final columns = context.dataGridEffectiveColumns<T>()!;
    final scrollController = context.gridScrollController<T>()!;
    final scrollbarWidth = theme.dimensions.scrollbarWidth;
    final pinnedWidth = columns.where((col) => col.pinned && col.visible).fold<double>(0.0, (sum, col) => sum + col.width);

    if (state.displayOrder.isEmpty) {
      return const SizedBox.expand();
    }

    final delegate = DataGridChildDelegate<T>(
      columns: columns,
      rowCount: state.displayOrder.length,
      displayOrder: state.displayOrder,
      rowsById: state.rowsById,
    );

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: const _DataGridScrollBehavior().copyWith(scrollbars: false),
              child: DataGridScrollView<T>(
                columns: columns,
                rowCount: state.displayOrder.length,
                rowHeight: widget.rowHeight,
                cacheExtent: widget.cacheExtent,
                pinnedMaskColor: theme.colors.evenRowColor,
                delegate: delegate,
                verticalDetails: ScrollableDetails.vertical(controller: scrollController.verticalController),
                horizontalDetails: ScrollableDetails.horizontal(controller: scrollController.horizontalController, physics: const _SmoothScrollPhysics()),
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
                try {
                  if (!scrollController.verticalController.hasClients) {
                    return const SizedBox();
                  }
                  final positions = scrollController.verticalController.positions;
                  if (positions.length != 1) {
                    return const SizedBox();
                  }
                  final position = positions.first;
                  if (!position.hasContentDimensions || !position.hasPixels || !position.hasViewportDimension) {
                    return const SizedBox();
                  }
                  final hasVerticalScroll = position.maxScrollExtent > 0;
                  return hasVerticalScroll ? CustomVerticalScrollbar(controller: scrollController.verticalController) : const SizedBox();
                } catch (_) {
                  return const SizedBox();
                }
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
                try {
                  if (!scrollController.horizontalController.hasClients) {
                    return const SizedBox();
                  }
                  final positions = scrollController.horizontalController.positions;
                  if (positions.length != 1) {
                    return const SizedBox();
                  }
                  final position = positions.first;
                  if (!position.hasContentDimensions || !position.hasPixels || !position.hasViewportDimension) {
                    return const SizedBox();
                  }
                  final hasHorizontalScroll = position.maxScrollExtent > 0;
                  return hasHorizontalScroll ? CustomHorizontalScrollbar(controller: scrollController.horizontalController) : const SizedBox();
                } catch (_) {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
