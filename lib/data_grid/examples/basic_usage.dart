import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/data_grid.dart';

class ExampleRow extends DataGridRow {
  final String name;
  final int age;
  final String email;

  ExampleRow({required double id, required this.name, required this.age, required this.email}) {
    this.id = id;
  }
}

class BasicDataGridExample extends StatefulWidget {
  const BasicDataGridExample({super.key});

  @override
  State<BasicDataGridExample> createState() => _BasicDataGridExampleState();
}

class _BasicDataGridExampleState extends State<BasicDataGridExample> {
  late DataGridController<ExampleRow> controller;

  @override
  void initState() {
    super.initState();

    final columns = [
      DataGridColumn(id: 0, title: 'Name', width: 200),
      DataGridColumn(id: 1, title: 'Age', width: 100),
      DataGridColumn(id: 2, title: 'Email', width: 250),
    ];

    final rows = List.generate(
      100000,
      (i) => ExampleRow(id: i.toDouble(), name: 'User $i', age: 20 + (i % 50), email: 'user$i@example.com'),
    );

    controller = DataGridController<ExampleRow>(
      initialColumns: columns,
      initialRows: rows,
      rowHeight: 48.0,
      cellValueAccessor: (row, column) {
        switch (column.id) {
          case 0:
            return row.name;
          case 1:
            return row.age;
          case 2:
            return row.email;
          default:
            return null;
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Grid Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              controller.addEvent(SortEvent(columnId: 0, direction: SortDirection.ascending));
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              controller.addEvent(FilterEvent(columnId: 0, operator: FilterOperator.contains, value: 'User 1'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.addEvent(ClearFilterEvent());
            },
          ),
        ],
      ),
      body: DataGrid<ExampleRow>(
        controller: controller,
        rowHeight: 48.0,
        headerHeight: 48.0,
        cellBuilder: (row, columnId) {
          switch (columnId) {
            case 0:
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text(row.name),
              );
            case 1:
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text('${row.age}'),
              );
            case 2:
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text(row.email),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
