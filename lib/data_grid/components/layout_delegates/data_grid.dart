import 'package:data_grid/models/slot_type.dart';
import 'package:flutter/material.dart';

class DataGridLayoutDelegate extends MultiChildLayoutDelegate {
  DataGridLayoutDelegate();

  @override
  void performLayout(Size size) {
    if (hasChild(SlotType.COLUMNS)) {
      //Paint columns
      layoutChild(SlotType.COLUMNS,
          BoxConstraints.expand(width: size.width, height: size.height));
    }
    if (hasChild(SlotType.ROWS)) {
      //Paint rows
      layoutChild(SlotType.ROWS,
          BoxConstraints.expand(width: size.width, height: size.height));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
