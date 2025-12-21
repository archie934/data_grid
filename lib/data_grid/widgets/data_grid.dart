import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/widgets/data_grid_header.dart';
import 'package:data_grid/data_grid/widgets/data_grid_body.dart';
import 'package:data_grid/data_grid/widgets/custom_scrollbar.dart';
import 'package:data_grid/data_grid/delegates/body_layout_delegate.dart';

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

// Row widget with pinned and unpinned cells
class _DataGridRowWithPinnedCells<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int index;
  final List<DataGridColumn> pinnedColumns;
  final List<DataGridColumn> unpinnedColumns;
  final double pinnedWidth;
  final double unpinnedWidth;
  final double horizontalOffset;
  final DataGridController<T> controller;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _DataGridRowWithPinnedCells({
    super.key,
    required this.row,
    required this.index,
    required this.pinnedColumns,
    required this.unpinnedColumns,
    required this.pinnedWidth,
    required this.unpinnedWidth,
    required this.horizontalOffset,
    required this.controller,
    required this.rowHeight,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SelectionState>(
      stream: controller.selection$,
      initialData: controller.state.selection,
      builder: (context, snapshot) {
        final isSelected = snapshot.data?.isRowSelected(row.id) ?? false;

        return GestureDetector(
          onTap: () {
            controller.addEvent(SelectRowEvent(rowId: row.id, multiSelect: false));
          },
          child: Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Stack(
              children: [
                // Unpinned cells (responds to horizontal scroll)
                Positioned(
                  left: pinnedWidth,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(-horizontalOffset, 0),
                      child: SizedBox(
                        width: unpinnedWidth,
                        height: rowHeight,
                        child: CustomMultiChildLayout(
                          delegate: BodyLayoutDelegate(unpinnedColumns),
                          children: [
                            for (var column in unpinnedColumns) LayoutId(id: column.id, child: _buildCell(column)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Pinned cells (fixed position)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: pinnedWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: CustomMultiChildLayout(
                      delegate: BodyLayoutDelegate(pinnedColumns),
                      children: [for (var column in pinnedColumns) LayoutId(id: column.id, child: _buildCell(column))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(DataGridColumn column) {
    if (cellBuilder != null) {
      return cellBuilder!(row, column.id);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text('Row ${row.id}, Col ${column.id}', overflow: TextOverflow.ellipsis),
    );
  }
}

/// Widget that tracks scroll controller changes and rebuilds the scrollbar
class _ScrollbarTracker extends StatefulWidget {
  final Axis axis;
  final ScrollController controller;
  final Widget child;

  const _ScrollbarTracker({
    required this.axis,
    required this.controller,
    required this.child,
  });

  @override
  State<_ScrollbarTracker> createState() => _ScrollbarTrackerState();
}

class _ScrollbarTrackerState extends State<_ScrollbarTracker> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_ScrollbarTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
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
                        : _LoadingOverlay(
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

                                return _DataGridRowWithPinnedCells<T>(
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
                        child: _ScrollbarTracker(
                          axis: Axis.vertical,
                          controller: _scrollController.verticalController,
                          child: CustomVerticalScrollbar(
                            controller: _scrollController.verticalController,
                            width: 12,
                          ),
                        ),
                      ),
                      // Horizontal scrollbar
                      Positioned(
                        left: pinnedWidth,
                        right: 12,
                        bottom: 0,
                        child: _ScrollbarTracker(
                          axis: Axis.horizontal,
                          controller: _scrollController.horizontalController,
                          child: CustomHorizontalScrollbar(
                            controller: _scrollController.horizontalController,
                            height: 12,
                          ),
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
                  : _LoadingOverlay(
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

/// Default loading overlay widget displayed during heavy operations
class _LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backdropColor;
  final Color? indicatorColor;

  const _LoadingOverlay({
    this.message,
    this.backdropColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: backdropColor ?? Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: indicatorColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Processing...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
