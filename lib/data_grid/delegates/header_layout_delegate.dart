import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/column.dart';

class HeaderLayoutDelegate extends MultiChildLayoutDelegate {
  final List<DataGridColumn> columns;

  HeaderLayoutDelegate(this.columns);

  @override
  void performLayout(Size size) {
    double offsetX = 0;

    for (var column in columns) {
      if (hasChild(column.id)) {
        final childSize = layoutChild(
          column.id,
          BoxConstraints(
            minWidth: column.width,
            maxWidth: column.width,
            minHeight: size.height,
            maxHeight: size.height,
          ),
        );

        positionChild(column.id, Offset(offsetX, 0));
        offsetX += childSize.width;
      }
    }
  }

  @override
  bool shouldRelayout(HeaderLayoutDelegate oldDelegate) {
    if (columns.length != oldDelegate.columns.length) return true;

    for (var i = 0; i < columns.length; i++) {
      if (columns[i].width != oldDelegate.columns[i].width || columns[i].id != oldDelegate.columns[i].id) {
        return true;
      }
    }

    return false;
  }
}
