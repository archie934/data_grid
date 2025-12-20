import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/data_grid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late DataGridController<SomeRow> controller;

  @override
  void initState() {
    super.initState();

    final columns = List.generate(20, (index) => DataGridColumn(id: index, title: 'Column $index', width: 150));

    final rows = List.generate(100000, (index) => SomeRow(id: index.toDouble()));

    controller = DataGridController<SomeRow>(
      initialColumns: columns,
      initialRows: rows,
      rowHeight: 48.0,
      cellValueAccessor: (row, column) {
        return 'Row ${row.id.toInt()}, Col ${column.id}';
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Grid Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Data Grid'),
        ),
        body: DataGrid<SomeRow>(
          controller: controller,
          rowHeight: 48.0,
          headerHeight: 48.0,
          cellBuilder: (row, columnId) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text('Row ${row.id.toInt()}, Col $columnId'),
            );
          },
        ),
      ),
    );
  }
}
