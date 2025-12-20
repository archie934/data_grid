import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/widgets/data_grid_header.dart';
import 'package:data_grid/data_grid/widgets/data_grid_body.dart';

class DataGrid<T extends DataGridRow> extends StatefulWidget {
  final DataGridController<T> controller;
  final GridScrollController? scrollController;
  final double headerHeight;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGrid({
    super.key,
    required this.controller,
    this.scrollController,
    this.headerHeight = 48.0,
    this.rowHeight = 48.0,
    this.cellBuilder,
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

            return SingleChildScrollView(
              controller: _scrollController.horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: state.columns.fold<double>(0.0, (sum, col) => sum + col.width),
                child: Column(
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
                        cellBuilder: widget.cellBuilder,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
