import 'package:flutter/material.dart';
import 'package:data_grid/controllers/data_grid_controller.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';

class ExampleRow extends DataGridRow {
  final String name;
  final int age;
  final String email;

  ExampleRow({required double id, required this.name, required this.age, required this.email}) {
    this.id = id;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Data Grid Selection & Edit Example', home: const DataGridExample());
  }
}

class DataGridExample extends StatefulWidget {
  const DataGridExample({super.key});

  @override
  State<DataGridExample> createState() => _DataGridExampleState();
}

class _DataGridExampleState extends State<DataGridExample> {
  late DataGridController<ExampleRow> controller;

  @override
  void initState() {
    super.initState();

    controller = DataGridController<ExampleRow>(
      initialColumns: [
        DataGridColumn<ExampleRow>(id: 0, title: 'Name', width: 200, editable: true, valueAccessor: (row) => row.name),
        DataGridColumn<ExampleRow>(
          id: 1,
          title: 'Age',
          width: 100,
          editable: true,
          valueAccessor: (row) => row.age,
          cellEditorBuilder: (context, value, onChanged) {
            return TextField(
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                final intValue = int.tryParse(text);
                if (intValue != null) {
                  onChanged(intValue);
                }
              },
            );
          },
        ),
        DataGridColumn<ExampleRow>(
          id: 2,
          title: 'Email',
          width: 250,
          editable: true,
          valueAccessor: (row) => row.email,
        ),
      ],
      initialRows: [
        ExampleRow(id: 1, name: 'John Doe', age: 30, email: 'john@example.com'),
        ExampleRow(id: 2, name: 'Jane Smith', age: 25, email: 'jane@example.com'),
        ExampleRow(id: 3, name: 'Bob Johnson', age: 35, email: 'bob@example.com'),
      ],
      canEditCell: (rowId, columnId) {
        return true;
      },
      canSelectRow: (rowId) {
        return true;
      },
      onCellCommit: (rowId, columnId, oldValue, newValue) async {
        print('Cell commit: Row $rowId, Column $columnId, Old: $oldValue, New: $newValue');

        if (columnId == 1 && newValue is int && newValue < 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Age cannot be negative')));
          return false;
        }

        return true;
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
        title: const Text('Data Grid Selection & Edit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_box),
            onPressed: () {
              controller.enableMultiSelect(true);
            },
            tooltip: 'Enable Multi-Select',
          ),
          IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () {
              controller.enableMultiSelect(false);
            },
            tooltip: 'Enable Single-Select',
          ),
        ],
      ),
      body: StreamBuilder<SelectionMode>(
        stream: controller.selection$.map((s) => s.mode),
        builder: (context, snapshot) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selection Mode: ${snapshot.data ?? SelectionMode.single}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Double-click any cell to edit. Press Enter to commit, Escape to cancel.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Expanded(child: Container()),
            ],
          );
        },
      ),
    );
  }
}
