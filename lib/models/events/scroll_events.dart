import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

class ScrollEvent extends DataGridEvent {
  final double offsetX;
  final double offsetY;

  ScrollEvent({required this.offsetX, required this.offsetY});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedViewport = context.viewportDelegate.handleScroll(this, context.state);
    return context.state.copyWith(viewport: updatedViewport);
  }
}

class ViewportResizeEvent extends DataGridEvent {
  final double width;
  final double height;

  ViewportResizeEvent({required this.width, required this.height});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedViewport = context.viewportDelegate.handleResize(this, context.state);
    return context.state.copyWith(viewport: updatedViewport);
  }
}
