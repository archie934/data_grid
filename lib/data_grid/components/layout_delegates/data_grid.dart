import 'package:data_grid/models/slot_type.dart';
import 'package:flutter/material.dart';

class DataGridLayoutDelegate extends MultiChildLayoutDelegate {
  DataGridLayoutDelegate();

  @override
  void performLayout(Size size) {
    Size columnSize = Size.zero;

    if (hasChild(SlotType.COLUMNS)) {
      //Paint columns
      columnSize = layoutChild(
        SlotType.COLUMNS,
        BoxConstraints.tight(Size(size.width, 100)),
      );
      positionChild(SlotType.COLUMNS, Offset.zero);
    }
    if (hasChild(SlotType.ROWS)) {
      //Paint rows
      layoutChild(
        SlotType.ROWS,
        BoxConstraints.expand(width: size.width, height: size.height),
      );
      positionChild(SlotType.ROWS, Offset(0, columnSize.height));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
