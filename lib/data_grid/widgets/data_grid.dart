import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/widgets/data_grid_header.dart';
import 'package:data_grid/data_grid/widgets/data_grid_body.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_row_pinned.dart';
import 'package:data_grid/data_grid/widgets/overlays/loading_overlay.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_horizontal.dart';

class DataGrid<T extends DataGridRow> extends StatefulWidget {
  final DataGridController<T> controller;
  final GridScrollController? scrollController;
  final double headerHeight;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  /// Whether to show the loading overlay (default: true)
  final bool showLoadingOverlay;

  /// Custom loading overlay builder. If null, uses default overlay.
  final Widget Function(BuildContext context, String? message)? loadingOverlayBuilder;

  /// Backdrop color for the loading overlay (default: black with 30% opacity)
  final Color? loadingBackdropColor;

  /// Color of the loading indicator (default: theme primary color)
  final Color? loadingIndicatorColor;

  const DataGrid({
    super.key,
    required this.controller,
    this.scrollController,
    this.headerHeight = 48.0,
    this.rowHeight = 48.0,
    this.cellBuilder,
    this.showLoadingOverlay = true,
    this.loadingOverlayBuilder,
    this.loadingBackdropColor,
    this.loadingIndicatorColor,
  });

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T extends DataGridRow> extends State<DataGrid<T>> {
  late GridScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? GridScrollController();

    _scrollController.scrollEvent$.listen((event) {
      widget.controller.addEvent(event);
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        widget.controller.addEvent(
          ViewportResizeEvent(width: constraints.maxWidth, height: constraints.maxHeight - widget.headerHeight),
        );

        return StreamBuilder<DataGridState<T>>(
          stream: widget.controller.state$,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final state = snapshot.data!;

            // Separate pinned and unpinned columns
            final pinnedColumns = state.columns.where((col) => col.pinned && col.visible).toList();
            final unpinnedColumns = state.columns.where((col) => !col.pinned && col.visible).toList();

            final pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
            final unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);

            // If no pinned columns, use simple layout
            // DataGridBody handles its own scrolling internally
            if (pinnedColumns.isEmpty) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Header - synced with body's horizontal scroll via AnimatedBuilder
                      SizedBox(
                        height: widget.headerHeight,
                        child: AnimatedBuilder(
                          animation: _scrollController.horizontalController,
                          builder: (context, child) {
                            final horizontalOffset = _scrollController.horizontalController.hasClients
                                ? _scrollController.horizontalController.offset
                                : 0.0;
                            return ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.centerLeft,
                                maxWidth: unpinnedWidth,
                                child: Transform.translate(
                                  offset: Offset(-horizontalOffset, 0),
                                  child: SizedBox(
                                    width: unpinnedWidth,
                                    child: DataGridHeader<T>(
                                      state: state.copyWith(columns: unpinnedColumns),
                                      controller: widget.controller,
                                      scrollController: _scrollController,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Body with integrated scrollbars
                      Expanded(
                        child: DataGridBody<T>(
                          state: state.copyWith(columns: unpinnedColumns),
                          controller: widget.controller,
                          scrollController: _scrollController,
                          rowHeight: widget.rowHeight,
                          cellBuilder: widget.cellBuilder,
                        ),
                      ),
                    ],
                  ),
                  // Loading overlay
                  if (state.isLoading && widget.showLoadingOverlay)
                    widget.loadingOverlayBuilder != null
                        ? widget.loadingOverlayBuilder!(context, state.loadingMessage)
                        : DataGridLoadingOverlay(
                            message: state.loadingMessage,
                            backdropColor: widget.loadingBackdropColor,
                            indicatorColor: widget.loadingIndicatorColor,
                          ),
                ],
              );
            }

            // Layout with pinned columns
            return Stack(
              children: [
                Column(
                  children: [
                    // Header row
                    SizedBox(
                      height: widget.headerHeight,
                      child: Stack(
                        children: [
                          // Unpinned header (scrollable)
                          Positioned(
                            left: pinnedWidth,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: SingleChildScrollView(
                              controller: _scrollController.horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: unpinnedWidth,
                                child: DataGridHeader<T>(
                                  state: state.copyWith(columns: unpinnedColumns),
                                  controller: widget.controller,
                                  scrollController: _scrollController,
                                ),
                              ),
                            ),
                          ),
                          // Pinned header (fixed)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: pinnedWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(2, 0),
                                  ),
                                ],
                              ),
                              child: DataGridHeader<T>(
                                state: state.copyWith(columns: pinnedColumns),
                                controller: widget.controller,
                                scrollController: _scrollController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Body with unified vertical scrolling and proper pinning
                    Expanded(
                      child: Stack(
                        children: [
                          // Main body content
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _scrollController.horizontalController,
                              builder: (context, child) {
                                final horizontalOffset = _scrollController.horizontalController.hasClients
                                    ? _scrollController.horizontalController.offset
                                    : 0.0;

                                return ListView.builder(
                                  controller: _scrollController.verticalController,
                                  itemCount: state.displayIndices.length,
                                  itemExtent: widget.rowHeight,
                                  addAutomaticKeepAlives: false,
                                  addRepaintBoundaries: true,
                                  itemBuilder: (context, index) {
                                    final rowIndex = state.displayIndices[index];
                                    final row = state.rows[rowIndex];

                                    return DataGridRowWithPinnedCells<T>(
                                      key: ValueKey(row.id),
                                      row: row,
                                      index: index,
                                      pinnedColumns: pinnedColumns,
                                      unpinnedColumns: unpinnedColumns,
                                      pinnedWidth: pinnedWidth,
                                      unpinnedWidth: unpinnedWidth,
                                      horizontalOffset: horizontalOffset,
                                      controller: widget.controller,
                                      rowHeight: widget.rowHeight,
                                      cellBuilder: widget.cellBuilder,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          // Vertical scrollbar
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 12,
                            child: CustomVerticalScrollbar(controller: _scrollController.verticalController, width: 12),
                          ),
                          // Horizontal scrollbar
                          Positioned(
                            left: pinnedWidth,
                            right: 12,
                            bottom: 0,
                            child: CustomHorizontalScrollbar(
                              controller: _scrollController.horizontalController,
                              height: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Loading overlay
                if (state.isLoading && widget.showLoadingOverlay)
                  widget.loadingOverlayBuilder != null
                      ? widget.loadingOverlayBuilder!(context, state.loadingMessage)
                      : DataGridLoadingOverlay(
                          message: state.loadingMessage,
                          backdropColor: widget.loadingBackdropColor,
                          indicatorColor: widget.loadingIndicatorColor,
                        ),
              ],
            );
          },
        );
      },
    );
  }
}
