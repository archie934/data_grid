import 'package:flutter/material.dart';

import '../../models/column.dart';

class RowsLayoutDelegate extends MultiChildLayoutDelegate {
  final List<DataGridColumn> columns;

  RowsLayoutDelegate({super.relayout, required this.columns});

  @override
  void performLayout(Size size) {
    var dx = 0.0;

    /// Layout columns
    for (var element in columns.indexed) {
      final columnModel = element.$2;
      final columnId = columnModel.id;
      layoutChild(
        columnId,
        BoxConstraints(
          maxWidth: columnModel.width,
        ),
      );

      positionChild(
        columnId,
        Offset(dx, 0),
      );
      dx = dx + columnModel.width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
