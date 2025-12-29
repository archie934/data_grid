import 'package:flutter/material.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/data/row.dart';

class HeaderLayoutDelegate<T extends DataGridRow> extends MultiChildLayoutDelegate {
  final List<DataGridColumn<T>> columns;

  HeaderLayoutDelegate({required this.columns});

  @override
  void performLayout(Size size) {
    double offsetX = 0;

    for (var column in columns) {
      if (!column.visible) continue;

      if (hasChild(column.id)) {
        layoutChild(column.id, BoxConstraints.tightFor(width: column.width, height: size.height));

        // Position columns sequentially - parent handles scrolling
        positionChild(column.id, Offset(offsetX, 0));
        offsetX += column.width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant HeaderLayoutDelegate<T> oldDelegate) {
    if (columns.length != oldDelegate.columns.length) return true;

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
