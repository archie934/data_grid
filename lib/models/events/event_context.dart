import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/grid_events.dart';
import 'package:data_grid/delegates/viewport_delegate.dart';
import 'package:data_grid/delegates/sort_delegate.dart';
import 'package:data_grid/delegates/filter_delegate.dart';
import 'package:data_grid/utils/data_indexer.dart';

/// Context provided to events for applying state transformations.
///
/// Contains only complex/stateful components:
/// - ViewportDelegate: Pluggable viewport calculations
/// - SortDelegate: Pluggable sorting with debouncing and async operations
/// - FilterDelegate: Pluggable filtering with debouncing and async operations
/// - DataIndexer: Data filtering and sorting operations
class EventContext<T extends DataGridRow> {
  final DataGridState<T> state;
  final ViewportDelegate<T> viewportDelegate;
  final SortDelegate<T> sortDelegate;
  final FilterDelegate<T> filterDelegate;
  final DataIndexer<T> dataIndexer;
  final void Function(DataGridEvent) dispatchEvent;
  final bool Function(double rowId, int columnId)? canEditCell;
  final bool Function(double rowId)? canSelectRow;
  final Future<bool> Function(double rowId, int columnId, dynamic oldValue, dynamic newValue)? onCellCommit;

  const EventContext({
    required this.state,
    required this.viewportDelegate,
    required this.sortDelegate,
    required this.filterDelegate,
    required this.dataIndexer,
    required this.dispatchEvent,
    this.canEditCell,
    this.canSelectRow,
    this.onCellCommit,
  });
}
