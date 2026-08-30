import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/auto_height.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/events/cell_selection_events.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/custom_layout/external_scroll_position.dart';
import 'package:flutter_data_grid/widgets/custom_layout/full_width_row_band_layer.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_pinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_unpinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/row_metrics.dart';
import 'package:flutter_data_grid/widgets/overlays/group_header_band.dart';
import 'package:flutter_data_grid/widgets/scroll/vertical_scrollbar.dart';
import 'package:flutter_data_grid/widgets/scroll/horizontal_scrollbar.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';

part 'grid_body_scroll_mixin.dart';
part 'grid_body_drag_select_mixin.dart';
part 'grid_body_row_height_mixin.dart';

class CustomLayoutGridBody<T extends DataGridRow> extends StatefulWidget {
  final RowMetrics rowMetrics;
  final double cacheExtent;

  /// Non-null enables auto row-height measurement; must be non-null iff
  /// [rowMetrics] is an [AutoRowMetrics].
  final AutoRowHeight? autoRowHeight;

  const CustomLayoutGridBody({
    super.key,
    required this.rowMetrics,
    required this.cacheExtent,
    this.autoRowHeight,
  });

  @override
  State<CustomLayoutGridBody<T>> createState() =>
      _CustomLayoutGridBodyState<T>();
}

class _CustomLayoutGridBodyState<T extends DataGridRow>
    extends State<CustomLayoutGridBody<T>>
    with
        TickerProviderStateMixin,
        _GridBodyScrollMixin<T>,
        _GridBodyDragSelectMixin<T>,
        _GridBodyRowHeightMixin<T>
    implements ScrollContext {
  @override
  TickerProvider get vsync => this;

  @override
  void initState() {
    super.initState();
    _scrollInitState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollDidChangeDependencies();
  }

  @override
  void dispose() {
    _scrollDispose();
    super.dispose();
  }

  // -- Pointer dispatchers ---------------------------------------------------

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons == kSecondaryMouseButton) {
      _dragSelectPointerDown(event);
      return;
    }
    _scrollPointerDown(event);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isDragSelecting) {
      _dragSelectPointerMove(event);
      return;
    }
    _scrollPointerMove(event);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isDragSelecting) {
      _dragSelectPointerUp(event);
      return;
    }
    _scrollPointerUp(event);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isDragSelecting) {
      _dragSelectPointerCancel(event);
      return;
    }
    _scrollPointerCancel(event);
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({
      DataGridAspect.data,
      DataGridAspect.columns,
      DataGridAspect.group,
    });
    if (state == null) return const SizedBox.expand();

    final columns = context.dataGridEffectiveColumns<T>();
    if (columns == null) return const SizedBox.expand();

    final rows = context.dataGridDisplayRows<T>();
    if (rows == null || rows.isEmpty) return const SizedBox.expand();

    final scrollbarWidth = theme.dimensions.scrollbarWidth;
    final scrollController = _cachedScrollController;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;

        final pinnedIndices = <int>[];
        final unpinnedIndices = <int>[];
        double pinnedWidth = 0;
        double unpinnedWidth = 0;

        for (int i = 0; i < columns.length; i++) {
          if (!columns[i].visible) continue;
          if (columns[i].pinned) {
            pinnedIndices.add(i);
            pinnedWidth += columns[i].width;
          } else {
            unpinnedIndices.add(i);
            unpinnedWidth += columns[i].width;
          }
        }

        final rowCount = rows.length;
        final rowMetrics = widget.rowMetrics;
        final totalHeight = rowMetrics.offsetOf(rowCount);
        final scrollableViewportWidth = viewportWidth - pinnedWidth;
        final rowHeightMeasurement = _buildRowHeightMeasurement(rowMetrics);

        _syncScrollDimensions(
          scrollableViewportWidth: scrollableViewportWidth,
          viewportHeight: viewportHeight,
          unpinnedWidth: unpinnedWidth,
          totalHeight: totalHeight,
        );

        _updateLayoutCache(columns, rows, pinnedWidth);

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: _onPointerSignal,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          onPointerPanZoomStart: _onPointerPanZoomStart,
          onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
          onPointerPanZoomEnd: _onPointerPanZoomEnd,
          child: Stack(
            children: [
              Positioned.fill(
                child: GridUnpinnedQuadrant<T>(
                  columns: columns,
                  unpinnedIndices: unpinnedIndices,
                  pinnedWidth: pinnedWidth,
                  viewportWidth: viewportWidth,
                  viewportHeight: viewportHeight,
                  rows: rows,
                  rowsById: state.rowsById,
                  rowCount: rowCount,
                  rowMetrics: rowMetrics,
                  cacheExtent: widget.cacheExtent,
                  hOffset: _hOffset,
                  vOffset: _vOffset,
                  measurement: rowHeightMeasurement,
                ),
              ),
              if (pinnedWidth > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: pinnedWidth,
                  child: GridPinnedQuadrant<T>(
                    columns: columns,
                    pinnedIndices: pinnedIndices,
                    viewportHeight: viewportHeight,
                    rows: rows,
                    rowsById: state.rowsById,
                    rowCount: rowCount,
                    rowMetrics: rowMetrics,
                    cacheExtent: widget.cacheExtent,
                    backgroundColor: theme.colors.evenRowColor,
                    vOffset: _vOffset,
                    measurement: rowHeightMeasurement,
                  ),
                ),
              if (state.group.hasGroups)
                Positioned.fill(
                  child: FullWidthRowBandLayer<T>(
                    rows: rows,
                    viewportWidth: viewportWidth,
                    viewportHeight: viewportHeight,
                    rowMetrics: rowMetrics,
                    cacheExtent: widget.cacheExtent,
                    vOffset: _vOffset,
                    bandBuilder: (entry, rowIndex) {
                      if (entry is GridGroupHeaderRow<T>) {
                        return GroupHeaderBand<T>(
                          key: ValueKey('group_${entry.groupKey}'),
                          header: entry,
                        );
                      }
                      return null;
                    },
                  ),
                ),
              if (scrollController != null && _maxVScroll > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: _maxHScroll > 0 ? scrollbarWidth : 0,
                  child: VerticalDataGridScrollbar(
                    controller: scrollController.verticalController,
                  ),
                ),
              if (scrollController != null && _maxHScroll > 0)
                Positioned(
                  left: pinnedWidth,
                  right: _maxVScroll > 0 ? scrollbarWidth : 0,
                  bottom: 0,
                  child: HorizontalDataGridScrollbar(
                    controller: scrollController.horizontalController,
                  ),
                ),
              if (_isDragSelecting &&
                  _dragSelectStart != null &&
                  _dragSelectCurrent != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DragSelectionPainter(
                        start: _dragSelectStart!,
                        end: _dragSelectCurrent!,
                        color: theme.colors.dragSelectOverlayColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
