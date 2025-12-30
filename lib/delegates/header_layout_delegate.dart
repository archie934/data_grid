import 'package:flutter/material.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/data/row.dart';

/// Layout delegate for header and filter rows.
/// Handles pinned columns at fixed positions and unpinned columns with scroll offset.
class HeaderLayoutDelegate<T extends DataGridRow> extends MultiChildLayoutDelegate {
  final List<DataGridColumn<T>> columns;
  final double horizontalOffset;

  HeaderLayoutDelegate({required this.columns, this.horizontalOffset = 0.0});

  @override
  void performLayout(Size size) {
    // Separate columns into pinned and unpinned
    final pinnedColumns = columns.where((c) => c.pinned && c.visible).toList();
    final unpinnedColumns = columns.where((c) => !c.pinned && c.visible).toList();
    final pinnedWidth = pinnedColumns.fold<double>(0, (sum, c) => sum + c.width);

    // PHASE 1: Layout pinned columns at fixed positions (no scroll offset)
    double offsetX = 0;
    for (var column in pinnedColumns) {
      if (hasChild(column.id)) {
        layoutChild(column.id, BoxConstraints.tightFor(width: column.width, height: size.height));
        positionChild(column.id, Offset(offsetX, 0));
        offsetX += column.width;
      }
    }

    // PHASE 2: Layout unpinned columns with scroll offset
    offsetX = pinnedWidth - horizontalOffset;
    for (var column in unpinnedColumns) {
      if (hasChild(column.id)) {
        layoutChild(column.id, BoxConstraints.tightFor(width: column.width, height: size.height));
        positionChild(column.id, Offset(offsetX, 0));
        offsetX += column.width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant HeaderLayoutDelegate<T> oldDelegate) {
    if (columns.length != oldDelegate.columns.length) return true;
    if (horizontalOffset != oldDelegate.horizontalOffset) return true;

    for (var i = 0; i < columns.length; i++) {
      final oldCol = oldDelegate.columns[i];
      final newCol = columns[i];

      if (oldCol.id != newCol.id ||
          oldCol.width != newCol.width ||
          oldCol.visible != newCol.visible ||
          oldCol.pinned != newCol.pinned) {
        return true;
      }
    }

    return false;
  }
}
