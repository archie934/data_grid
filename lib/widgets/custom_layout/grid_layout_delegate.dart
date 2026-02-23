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

/// A [MultiChildLayoutDelegate] that positions grid cells at pre-computed
/// offsets. Each child is identified by a [CellLayoutId] and sized/placed
/// according to the corresponding entry in [cellRects].
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  final Map<CellLayoutId, Rect> cellRects;

  GridLayoutDelegate({required this.cellRects});

  @override
  void performLayout(Size size) {
    for (final entry in cellRects.entries) {
      final id = entry.key;
      final rect = entry.value;
      if (hasChild(id)) {
        layoutChild(id, BoxConstraints.tight(rect.size));
        positionChild(id, rect.topLeft);
      }
    }
  }

  @override
  bool shouldRelayout(GridLayoutDelegate oldDelegate) {
    return !identical(cellRects, oldDelegate.cellRects);
  }
}
