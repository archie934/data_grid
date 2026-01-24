import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/widgets/data_grid_header.dart';
import 'package:flutter_data_grid/widgets/data_grid_body.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/data_grid_pagination.dart';
import 'package:flutter_data_grid/widgets/overlays/loading_overlay.dart';
import 'package:flutter_data_grid/renderers/cell_renderer.dart';
import 'package:flutter_data_grid/renderers/filter_renderer.dart';
import 'package:flutter_data_grid/renderers/default_filter_renderer.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/theme/data_grid_theme_data.dart';

/// A high-performance, virtualized data grid widget for displaying tabular data.
///
/// The [DataGrid] supports sorting, filtering, cell editing, row selection,
/// column pinning, and keyboard navigation. It uses virtualization to render
/// only visible rows for smooth scrolling with large datasets.
///
/// Example:
/// ```dart
/// DataGrid<MyRow>(
///   controller: controller,
///   headerHeight: 48.0,
///   rowHeight: 48.0,
/// )
/// ```
class DataGrid<T extends DataGridRow> extends StatefulWidget {
  /// The controller that manages the grid's state and data.
  final DataGridController<T> controller;

  /// Optional scroll controller for external scroll synchronization.
  final GridScrollController? scrollController;

  /// Height of the header row. Defaults to theme value if not specified.
  final double? headerHeight;

  /// Height of each data row. Defaults to theme value if not specified.
  final double? rowHeight;

  /// Custom cell renderer for advanced cell customization.
  final CellRenderer<T>? cellRenderer;

  /// Custom filter renderer for advanced filter widget customization.
  final FilterRenderer? filterRenderer;

  /// Whether to show the loading overlay (default: true)
  final bool showLoadingOverlay;

  /// Custom loading overlay builder. If null, uses default overlay.
  final Widget Function(BuildContext context, String? message)? loadingOverlayBuilder;

  /// Backdrop color for the loading overlay (default: black with 30% opacity)
  final Color? loadingBackdropColor;

  /// Color of the loading indicator (default: theme primary color)
  final Color? loadingIndicatorColor;

  /// Optional theme data to customize the appearance of the data grid.
  /// If not provided, uses the default theme.
  final DataGridThemeData? theme;

  /// Whether to show pagination controls (default: true)
  final bool showPagination;

  /// Custom pagination widget builder. If null, uses default pagination widget.
  final Widget Function(BuildContext context, DataGridState<T> state)? paginationBuilder;

  /// Cache extent for the scroll view. Controls how many pixels of content
  /// are rendered beyond the visible viewport.
  final double? cacheExtent;

  /// Creates a [DataGrid] widget.
  const DataGrid({
    super.key,
    required this.controller,
    this.scrollController,
    this.headerHeight,
    this.rowHeight,
    this.cellRenderer,
    this.filterRenderer,
    this.showLoadingOverlay = true,
    this.loadingOverlayBuilder,
    this.loadingBackdropColor,
    this.loadingIndicatorColor,
    this.theme,
    this.showPagination = true,
    this.paginationBuilder,
    this.cacheExtent,
  });

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T extends DataGridRow> extends State<DataGrid<T>> {
  late GridScrollController _scrollController;
  late FilterRenderer _filterRenderer;
  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? GridScrollController();
    _filterRenderer = widget.filterRenderer ?? const DefaultFilterRenderer();
    // Scroll events removed - viewport handles scroll internally via ViewportOffset
    // The previous subscription caused redundant state updates and full widget rebuilds
  }

  void _notifyViewportResize(double width, double height) {
    final newSize = Size(width, height);
    if (_lastViewportSize != newSize) {
      _lastViewportSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.addEvent(ViewportResizeEvent(width: width, height: height));
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (widget.controller.state.edit.isEditing) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.controller.addEvent(NavigateUpEvent());
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.controller.addEvent(NavigateDownEvent());
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.controller.addEvent(NavigateLeftEvent());
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.controller.addEvent(NavigateRightEvent());
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.addEvent(ClearSelectionEvent());
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyA &&
        (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed)) {
      widget.controller.addEvent(SelectAllVisibleEvent());
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.theme ?? DataGridThemeData.defaultTheme();
    final effectiveHeaderHeight = widget.headerHeight ?? themeData.dimensions.headerHeight;
    final effectiveRowHeight = widget.rowHeight ?? themeData.dimensions.rowHeight;

    return DataGridTheme(
      data: themeData,
      child: StreamBuilder<DataGridState<T>>(
        stream: widget.controller.state$,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!;
          final rowCount = state.displayOrder.length;
          final columnCount = state.effectiveColumns.length;

          return DataGridInherited<T>(
            controller: widget.controller,
            scrollController: _scrollController,
            state: state,
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) => _handleKeyEvent(event),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final paginationHeight = (widget.showPagination && state.pagination.enabled) ? 56.0 : 0.0;
                  final hasFilterableColumns = state.columns.any((col) => col.filterable && col.visible);
                  final filterRowHeight = hasFilterableColumns ? themeData.dimensions.filterRowHeight : 0.0;
                  final availableHeight =
                      constraints.maxHeight - effectiveHeaderHeight - filterRowHeight - paginationHeight;

                  final Widget bodyWidget;
                  final double bodyHeight;

                  if (state.pagination.enabled && state.displayOrder.isNotEmpty) {
                    final requiredHeight = state.pagination.pageSize * effectiveRowHeight;
                    if (requiredHeight <= availableHeight) {
                      bodyHeight = requiredHeight;
                      bodyWidget = SizedBox(
                        height: bodyHeight,
                        child: DataGridBody<T>(rowHeight: effectiveRowHeight, cacheExtent: widget.cacheExtent),
                      );
                    } else {
                      bodyHeight = availableHeight;
                      bodyWidget = Expanded(
                        child: DataGridBody<T>(rowHeight: effectiveRowHeight, cacheExtent: widget.cacheExtent),
                      );
                    }
                  } else {
                    bodyHeight = availableHeight;
                    bodyWidget = Expanded(
                      child: DataGridBody<T>(rowHeight: effectiveRowHeight, cacheExtent: widget.cacheExtent),
                    );
                  }

                  _notifyViewportResize(constraints.maxWidth, bodyHeight);

                  return Semantics(
                    label: 'Data grid with $rowCount rows and $columnCount columns',
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            DataGridHeader<T>(
                              defaultFilterRenderer: _filterRenderer,
                              headerHeight: effectiveHeaderHeight,
                            ),
                            bodyWidget,
                            if (widget.showPagination && state.pagination.enabled)
                              widget.paginationBuilder != null
                                  ? widget.paginationBuilder!(context, state)
                                  : DataGridPagination<T>(),
                          ],
                        ),
                        if (state.isLoading && widget.showLoadingOverlay)
                          widget.loadingOverlayBuilder != null
                              ? widget.loadingOverlayBuilder!(context, state.loadingMessage)
                              : DataGridLoadingOverlay(
                                  message: state.loadingMessage,
                                  backdropColor: widget.loadingBackdropColor,
                                  indicatorColor: widget.loadingIndicatorColor,
                                ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
