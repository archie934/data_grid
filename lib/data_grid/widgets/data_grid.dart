import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/widgets/data_grid_header.dart';
import 'package:data_grid/data_grid/widgets/data_grid_body.dart';
import 'package:data_grid/data_grid/widgets/overlays/loading_overlay.dart';
import 'package:data_grid/data_grid/renderers/row_renderer.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';

class DataGrid<T extends DataGridRow> extends StatefulWidget {
  final DataGridController<T> controller;
  final GridScrollController? scrollController;
  final double headerHeight;
  final double rowHeight;

  /// Custom row renderer for advanced row customization.
  final RowRenderer<T>? rowRenderer;

  /// Custom cell renderer for advanced cell customization.
  final CellRenderer<T>? cellRenderer;

  /// Legacy cell builder function (deprecated, use cellRenderer instead).
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
    this.rowRenderer,
    this.cellRenderer,
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

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: widget.headerHeight,
                      child: DataGridHeader<T>(
                        state: state,
                        controller: widget.controller,
                        scrollController: _scrollController,
                      ),
                    ),
                    Expanded(
                      child: DataGridBody<T>(
                        state: state,
                        controller: widget.controller,
                        scrollController: _scrollController,
                        rowHeight: widget.rowHeight,
                        rowRenderer: widget.rowRenderer,
                        cellRenderer: widget.cellRenderer,
                        cellBuilder: widget.cellBuilder,
                      ),
                    ),
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
            );
          },
        );
      },
    );
  }
}
