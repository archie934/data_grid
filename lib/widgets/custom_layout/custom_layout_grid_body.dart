import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/events/cell_selection_events.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/custom_layout/external_scroll_position.dart';
import 'package:flutter_data_grid/widgets/custom_layout/full_width_row_band_layer.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_pinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_unpinned_quadrant.dart';
import 'package:flutter_data_grid/widgets/overlays/group_header_band.dart';
import 'package:flutter_data_grid/widgets/scroll/vertical_scrollbar.dart';
import 'package:flutter_data_grid/widgets/scroll/horizontal_scrollbar.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';

part 'grid_body_scroll_mixin.dart';
part 'grid_body_drag_select_mixin.dart';

class CustomLayoutGridBody<T extends DataGridRow> extends StatefulWidget {
  final double rowHeight;
  final double cacheExtent;

  const CustomLayoutGridBody({
    super.key,
    required this.rowHeight,
    required this.cacheExtent,
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
        _GridBodyDragSelectMixin<T>
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

  // -- Column partition ------------------------------------------------------
  // Split once per column-list change rather than per build: the quadrants
  // clear their cell caches when these lists change *identity*, so rebuilding
  // them every frame would keep those caches permanently cold.
  List<DataGridColumn<T>>? _partitionedColumnsRef;
  List<int> _pinnedIndices = const [];
  List<int> _unpinnedIndices = const [];
  double _pinnedWidth = 0;
  double _unpinnedWidth = 0;

  void _syncColumnPartition(List<DataGridColumn<T>> columns) {
    if (identical(_partitionedColumnsRef, columns)) return;
    _partitionedColumnsRef = columns;

    final pinned = <int>[];
    final unpinned = <int>[];
    double pinnedWidth = 0;
    double unpinnedWidth = 0;

    for (int i = 0; i < columns.length; i++) {
      if (!columns[i].visible) continue;
      if (columns[i].pinned) {
        pinned.add(i);
        pinnedWidth += columns[i].width;
      } else {
        unpinned.add(i);
        unpinnedWidth += columns[i].width;
      }
    }

    _pinnedIndices = pinned;
    _unpinnedIndices = unpinned;
    _pinnedWidth = pinnedWidth;
    _unpinnedWidth = unpinnedWidth;
  }

  // -- Band builder ----------------------------------------------------------

  /// Full-width band for a group-header slot, or `null` for ordinary data rows.
  ///
  /// Deliberately a named method so `FullWidthRowBandLayer` sees a stable
  /// callback identity across builds and can keep its band cache.
  Widget? _buildGroupBand(GridDisplayRow<T> entry, int rowIndex) {
    if (entry is GridGroupHeaderRow<T>) {
      return GroupHeaderBand<T>(
        key: ValueKey('group_${entry.groupKey}'),
        header: entry,
      );
    }
    return null;
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

    // Latched by DataGrid: reading state.rowsById here would hand the
    // quadrants a fresh EqualUnmodifiableMapView every build and clear their
    // cell caches. See DataGridStateScope.rowsById.
    final rowsById = context.dataGridRowsById<T>();
    if (rowsById == null) return const SizedBox.expand();

    final scrollbarWidth = theme.dimensions.scrollbarWidth;
    final scrollController = _cachedScrollController;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;

        _syncColumnPartition(columns);
        final pinnedIndices = _pinnedIndices;
        final unpinnedIndices = _unpinnedIndices;
        final pinnedWidth = _pinnedWidth;
        final unpinnedWidth = _unpinnedWidth;

        final rowCount = rows.length;
        final rowHeight = widget.rowHeight;
        final totalHeight = rowCount * rowHeight;
        final scrollableViewportWidth = viewportWidth - pinnedWidth;

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
                  rowsById: rowsById,
                  rowCount: rowCount,
                  rowHeight: rowHeight,
                  cacheExtent: widget.cacheExtent,
                  hOffset: _hOffset,
                  vOffset: _vOffset,
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
                    rowsById: rowsById,
                    rowCount: rowCount,
                    rowHeight: rowHeight,
                    cacheExtent: widget.cacheExtent,
                    backgroundColor: theme.colors.evenRowColor,
                    vOffset: _vOffset,
                  ),
                ),
              if (state.group.hasGroups)
                Positioned.fill(
                  child: FullWidthRowBandLayer<T>(
                    rows: rows,
                    viewportWidth: viewportWidth,
                    viewportHeight: viewportHeight,
                    rowHeight: rowHeight,
                    cacheExtent: widget.cacheExtent,
                    vOffset: _vOffset,
                    // Method tear-off, not an inline closure: FullWidthRowBandLayer
                    // clears its band cache when bandBuilder's identity changes,
                    // and a closure literal is a new object on every build.
                    bandBuilder: _buildGroupBand,
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
