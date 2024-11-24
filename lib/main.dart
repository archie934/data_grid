import 'dart:math';

import 'package:data_grid/data_grid/components/layout_delegates/columns_delegate.dart';
import 'package:data_grid/data_grid/components/layout_delegates/data_grid.dart';
import 'package:data_grid/data_grid/components/layout_delegates/rows_delegate.dart';
import 'package:data_grid/models/slot_type.dart';
import 'package:flutter/material.dart';

import 'package:data_grid/data_grid/models/column.dart';
import 'package:data_grid/data_grid/models/row.dart';

void main() {
  runApp(const MainApp());
}

final mockColumns = List.generate(
  10,
  (index) => DataGridColumn(id: index, title: 'title$index', width: 200),
);

final mockRows = List.generate(
  4,
  (index) => SomeRow(
    id: index.toDouble(),
  ),
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: CustomMultiChildLayout(
                delegate: DataGridLayoutDelegate(),
                children: [
                  LayoutId(
                      id: SlotType.COLUMNS,
                      child: CustomMultiChildLayout(
                        delegate: ColumnsLayoutDelegate(mockColumns),
                        children: [
                          for (var column in mockColumns)
                            LayoutId(
                              id: column.id,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(column.title),
                              ),
                            ),
                        ],
                      )),
                  LayoutId(
                      id: SlotType.ROWS,
                      child: CustomMultiChildLayout(
                        delegate: RowsLayoutDelegate(columns: mockColumns),
                        children: [
                          for (var mockColumn in mockColumns)
                            LayoutId(
                              id: mockColumn.id,
                              child: Container(
                                color: Color.fromRGBO(
                                    Random().nextInt(255),
                                    Random().nextInt(255),
                                    Random().nextInt(255),
                                    1),
                                height: 60,
                              ),
                            )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
