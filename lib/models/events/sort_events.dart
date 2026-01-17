import 'dart:math' as math;
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';

class SortEvent extends DataGridEvent {
  final int columnId;
  final SortDirection? direction;

  SortEvent({required this.columnId, this.direction});

  @override
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 1000;

  @override
  String? loadingMessage() => 'Sorting data...';

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    context.sortDelegate.handleSort(this, context.state, (result) {
      final totalItems = result.displayOrder.length;
      var newPagination = context.state.pagination;
      if (context.state.pagination.enabled) {
        newPagination = newPagination.copyWith(currentPage: 1);
      }

      List<double> finalDisplayOrder;
      if (context.state.pagination.enabled &&
          !context.state.pagination.serverSide) {
        final startIndex = newPagination.startIndex(totalItems);
        final endIndex = newPagination.endIndex(totalItems);
        finalDisplayOrder = result.displayOrder.sublist(
          math.min(startIndex, result.displayOrder.length),
          math.min(endIndex, result.displayOrder.length),
        );
      } else {
        finalDisplayOrder = result.displayOrder;
      }

      final newState = context.state.copyWith(
        sort: result.sortState,
        pagination: newPagination,
        displayOrder: finalDisplayOrder,
        totalItems: totalItems,
      );
      context.dispatchEvent(SortCompleteEvent(newState: newState));
    });
    return null;
  }
}

class SortCompleteEvent<T extends DataGridRow> extends DataGridEvent {
  final DataGridState<T> newState;

  SortCompleteEvent({required this.newState});

  @override
  DataGridState<R>? apply<R extends DataGridRow>(EventContext<R> context) {
    return (newState as DataGridState<R>).copyWith(isLoading: false);
  }
}
