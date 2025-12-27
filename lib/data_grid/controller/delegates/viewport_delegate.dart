import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';

/// Abstract delegate for handling viewport calculations.
///
/// Implement this to create custom viewport behavior with different
/// calculation strategies, caching, or optimization techniques.
abstract class ViewportDelegate<T extends DataGridRow> {
  const ViewportDelegate();

  /// Handle scroll event and calculate updated viewport state.
  ViewportState handleScroll(ScrollEvent event, DataGridState<T> currentState);

  /// Handle viewport resize event and calculate updated viewport state.
  ViewportState handleResize(ViewportResizeEvent event, DataGridState<T> currentState);

  /// Dispose any resources (caches, subscriptions, etc.)
  void dispose() {}
}
