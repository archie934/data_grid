import 'package:flutter/widgets.dart';

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

  GridLayoutDelegate({
    required this.contentRects,
    required this.vOffset,
    this.hOffset,
    this.pinnedWidth = 0.0,
  }) : super(
         relayout: hOffset != null
             ? Listenable.merge([hOffset, vOffset])
             : vOffset,
       );

  @override
  void performLayout(Size size) {
    final hScroll = hOffset?.value ?? 0.0;
    final vScroll = vOffset.value;

    for (final entry in contentRects.entries) {
      final id = entry.key;
      if (!hasChild(id)) continue;

      final rect = entry.value;
      final x = rect.left - hScroll + pinnedWidth;
      final y = rect.top - vScroll;

      layoutChild(id, BoxConstraints.tight(rect.size));
      positionChild(id, Offset(x, y));
    }
  }

  @override
  bool shouldRelayout(GridLayoutDelegate oldDelegate) {
    return !identical(contentRects, oldDelegate.contentRects) ||
        !identical(hOffset, oldDelegate.hOffset) ||
        !identical(vOffset, oldDelegate.vOffset) ||
        pinnedWidth != oldDelegate.pinnedWidth;
  }
}
