import 'package:data_grid/data_grid/models/column.dart';
import 'package:flutter/material.dart';

const columnWidth = 200.0;

class ColumnsLayoutDelegate extends MultiChildLayoutDelegate {
  final List<DataGridColumn> columns;

  ColumnsLayoutDelegate(this.columns);

  @override
  void performLayout(Size size) {
    var dx = 0.0;

    ///Layout columns
    for (var element in columns.indexed) {
      final columnId = element.$2.id;
      var currentColumnSize = layoutChild(
        columnId,
        const BoxConstraints(maxWidth: columnWidth),
      );

      dx = dx + currentColumnSize.width;
      positionChild(
        columnId,
        Offset(dx, 0),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
