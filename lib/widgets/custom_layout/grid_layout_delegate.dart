import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/delegates/row_height_delegate.dart';

/// Identifies a single cell in the grid by its row and column indices.
class CellLayoutId {
  final int row;
  final int column;

  const CellLayoutId(this.row, this.column);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellLayoutId && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'CellLayoutId($row, $column)';
}

/// Auto-row-height measurement hook for [GridLayoutDelegate].
///
/// For any cell whose row isn't yet [RowHeightDelegate.isMeasured], the
/// delegate lays it out with a loose height constraint (up to
/// [maxHeightClamp]) instead of the usual tight fit, and reports the
/// resolved size back via [onMeasured] — the same technique Flutter's own
/// `Table`/`IntrinsicHeight` use internally. Once a row is measured, its
/// cells fall back to the ordinary tight-constraint fast path, so this cost
/// is paid once per row rather than every frame.
class RowHeightMeasurement {
  RowHeightMeasurement({
    required this.delegate,
    required this.maxHeightClamp,
    required this.onMeasured,
  });

  final RowHeightDelegate delegate;
  final double maxHeightClamp;

  /// Called (possibly many times per frame, once per measured cell) with the
  /// row index and its cell's resolved height. Callers batch these and take
  /// the max per row before patching [delegate].
  final void Function(int row, double measuredHeight) onMeasured;
}

/// A [MultiChildLayoutDelegate] that positions grid cells in viewport space.
///
/// [contentRects] stores each cell's rect in **content space** (i.e. relative
/// to the top-left of the full scrollable content, before any scroll offset is
/// applied). [performLayout] reads the current scroll offsets directly from the
/// [ValueNotifier]s and converts to viewport coordinates, so repositioning on
/// scroll never requires a widget rebuild — only a [markNeedsLayout] call via
/// the [relayout] listenable.
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  /// Cell positions in content space (scroll-independent).
  final Map<CellLayoutId, Rect> contentRects;

  /// Horizontal scroll offset notifier. Pass `null` for the pinned quadrant.
  final ValueNotifier<double>? hOffset;

  /// Vertical scroll offset notifier.
  final ValueNotifier<double> vOffset;

  /// Width of the pinned-column area; added to unpinned cells' x positions.
  final double pinnedWidth;

  /// When non-null, enables auto-row-height measurement (see
  /// [RowHeightMeasurement]) instead of always laying out tight to [contentRects].
  final RowHeightMeasurement? measurement;

  GridLayoutDelegate({
    required this.contentRects,
    required this.vOffset,
    this.hOffset,
    this.pinnedWidth = 0.0,
    this.measurement,
  }) : super(
         relayout: hOffset != null
             ? Listenable.merge([hOffset, vOffset])
             : vOffset,
       );

  @override
  void performLayout(Size size) {
    final hScroll = hOffset?.value ?? 0.0;
    final vScroll = vOffset.value;
    final measurement = this.measurement;

    for (final entry in contentRects.entries) {
      final id = entry.key;
      if (!hasChild(id)) continue;

      final rect = entry.value;
      final x = rect.left - hScroll + pinnedWidth;
      final y = rect.top - vScroll;

      if (measurement != null && !measurement.delegate.isMeasured(id.row)) {
        final resolvedSize = layoutChild(
          id,
          BoxConstraints(
            minWidth: rect.width,
            maxWidth: rect.width,
            maxHeight: measurement.maxHeightClamp,
          ),
        );
        positionChild(id, Offset(x, y));
        measurement.onMeasured(id.row, resolvedSize.height);
      } else {
        layoutChild(id, BoxConstraints.tight(rect.size));
        positionChild(id, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRelayout(GridLayoutDelegate oldDelegate) {
    return !identical(contentRects, oldDelegate.contentRects) ||
        !identical(hOffset, oldDelegate.hOffset) ||
        !identical(vOffset, oldDelegate.vOffset) ||
        pinnedWidth != oldDelegate.pinnedWidth ||
        !identical(measurement, oldDelegate.measurement);
  }
}
