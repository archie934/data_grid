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
      final columnId = element.$2.id;
      var currentColumnSize = layoutChild(
        columnId,
        const BoxConstraints(
          maxWidth: 200,
        ),
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
