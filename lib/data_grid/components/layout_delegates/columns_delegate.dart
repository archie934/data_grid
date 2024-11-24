import 'package:data_grid/data_grid/models/column.dart';
import 'package:flutter/material.dart';

//TODO: Implement this https://github.com/estevez-dev/ha_client/blob/master/lib/plugins/dynamic_multi_column_layout.dart

class ColumnsLayoutDelegate extends MultiChildLayoutDelegate {
  final List<DataGridColumn> columns;

  ColumnsLayoutDelegate(this.columns);

  @override
  void performLayout(Size size) {
    var dx = 0.0;

    ///Layout columns
    for (var element in columns.indexed) {
      final columnModel = element.$2;

      final columnId = columnModel.id;
      layoutChild(
        columnId,
        BoxConstraints(maxWidth: columnModel.width),
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
