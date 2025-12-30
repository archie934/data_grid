import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid.dart';
import 'package:data_grid/models/enums/sort_direction.dart';
import 'package:data_grid/models/enums/filter_operator.dart';

class TestRow extends DataGridRow {
  String name;
  int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

/// Helper to wait for async stream operations to complete
Future<void> waitForAsync(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

void main() {
  group('DataGrid Data Operations Tests', () {
    late DataGridController<TestRow> controller;
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;

    setUp(() {
      columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          cellValueSetter: (row, value) => row.name = value,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Value',
          width: 100,
          valueAccessor: (row) => row.value,
          cellValueSetter: (row, value) => row.value = value,
        ),
      ];

      rows = [
        TestRow(id: 1, name: 'Alice', value: 100),
        TestRow(id: 2, name: 'Bob', value: 200),
        TestRow(id: 3, name: 'Charlie', value: 300),
      ];

      controller = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('setRows loads initial data', (tester) async {
      final emptyController = DataGridController<TestRow>(initialColumns: columns, initialRows: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: emptyController)),
        ),
      );

      await tester.pumpAndSettle();

      expect(emptyController.state.displayOrder.length, 0);

      emptyController.setRows(rows);
      await tester.pumpAndSettle();

      expect(emptyController.state.displayOrder.length, 3);
      expect(emptyController.state.rowsById.length, 3);
      expect(emptyController.state.rowsById[1]!.name, 'Alice');
      expect(emptyController.state.rowsById[2]!.name, 'Bob');
      expect(emptyController.state.rowsById[3]!.name, 'Charlie');

      emptyController.dispose();
    });

    testWidgets('insertRow adds single row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      final newRow = TestRow(id: 4, name: 'David', value: 400);
      controller.insertRow(newRow);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 4);
      expect(controller.state.rowsById[4]!.name, 'David');
      expect(controller.state.displayOrder.contains(4), true);
    });

    testWidgets('insertRow with position adds row at specific index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final newRow = TestRow(id: 4, name: 'David', value: 400);
      controller.insertRow(newRow, position: 1);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 4);
      expect(controller.state.displayOrder[1], 4);
    });

    testWidgets('insertRows adds multiple rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      final newRows = [
        TestRow(id: 4, name: 'David', value: 400),
        TestRow(id: 5, name: 'Eve', value: 500),
        TestRow(id: 6, name: 'Frank', value: 600),
      ];

      controller.insertRows(newRows);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 6);
      expect(controller.state.rowsById[4]!.name, 'David');
      expect(controller.state.rowsById[5]!.name, 'Eve');
      expect(controller.state.rowsById[6]!.name, 'Frank');
    });

    testWidgets('deleteRow removes single row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);
      expect(controller.state.rowsById.containsKey(2), true);

      controller.deleteRow(2);
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 2);
      expect(controller.state.rowsById.containsKey(2), false);
      expect(controller.state.displayOrder.contains(2), false);
    });

    testWidgets('deleteRows removes multiple rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      controller.deleteRows({1, 3});
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 1);
      expect(controller.state.rowsById.containsKey(1), false);
      expect(controller.state.rowsById.containsKey(3), false);
      expect(controller.state.rowsById.containsKey(2), true);
      expect(controller.state.rowsById[2]!.name, 'Bob');
    });

    testWidgets('updateRow replaces row data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice');
      expect(controller.state.rowsById[1]!.value, 100);

      final updatedRow = TestRow(id: 1, name: 'Alice Updated', value: 150);
      controller.updateRow(1, updatedRow);
      await waitForAsync(tester);

      expect(controller.state.rowsById[1]!.name, 'Alice Updated');
      expect(controller.state.rowsById[1]!.value, 150);
    });

    testWidgets('updateCell updates single cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice');

      controller.updateCell(1, 1, 'Alice Modified');
      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice Modified');
      expect(controller.state.rowsById[1]!.value, 100);
    });

    testWidgets('setRows replaces all existing data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      final newRows = [TestRow(id: 10, name: 'New1', value: 1000), TestRow(id: 11, name: 'New2', value: 1100)];

      controller.setRows(newRows);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 2);
      expect(controller.state.rowsById.containsKey(1), false);
      expect(controller.state.rowsById.containsKey(10), true);
      expect(controller.state.rowsById.containsKey(11), true);
    });

    testWidgets('data operations work with sorting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await waitForAsync(tester);

      expect(controller.state.visibleRows[0].name, 'Alice');

      final newRow = TestRow(id: 4, name: 'Aaron', value: 400);
      controller.insertRow(newRow);
      await waitForAsync(tester);

      expect(controller.state.visibleRows[0].name, 'Aaron');
    });

    testWidgets('data operations work with filtering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 2, operator: FilterOperator.greaterThan, value: 150));
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 2);

      final newRow = TestRow(id: 4, name: 'David', value: 400);
      controller.insertRow(newRow);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 3);
      expect(controller.state.visibleRows.any((r) => r.name == 'David'), true);
    });

    testWidgets('inserting duplicate id updates existing row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      final duplicateRow = TestRow(id: 1, name: 'Alice Duplicate', value: 999);
      controller.insertRow(duplicateRow);
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 3);
      expect(controller.state.rowsById[1]!.name, 'Alice Duplicate');
    });

    testWidgets('deleting non-existent row does nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      controller.deleteRow(999);
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);
    });

    testWidgets('updating non-existent row does nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final newRow = TestRow(id: 999, name: 'NonExistent', value: 999);
      controller.updateRow(999, newRow);
      await tester.pumpAndSettle();

      expect(controller.state.rowsById.containsKey(999), false);
    });

    testWidgets('bulk operations maintain data integrity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.deleteRow(2);
      await waitForAsync(tester);

      controller.insertRow(TestRow(id: 4, name: 'David', value: 400));
      await waitForAsync(tester);

      controller.updateCell(1, 1, 'Alice Updated');
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 3);
      expect(controller.state.rowsById.containsKey(2), false);
      expect(controller.state.rowsById.containsKey(4), true);
      expect(controller.state.rowsById[1]!.name, 'Alice Updated');
    });

    testWidgets('setColumns updates column configuration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.columns.length, 2);

      final newColumns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name Updated', width: 200, valueAccessor: (row) => row.name),
        DataGridColumn<TestRow>(id: 2, title: 'Value Updated', width: 150, valueAccessor: (row) => row.value),
        DataGridColumn<TestRow>(id: 3, title: 'New Column', width: 100, valueAccessor: (row) => 'New'),
      ];

      controller.setColumns(newColumns);
      await tester.pumpAndSettle();

      expect(controller.state.columns.length, 3);
      expect(controller.state.columns[0].title, 'Name Updated');
      expect(controller.state.columns[2].title, 'New Column');
    });

    testWidgets('data operations trigger UI updates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('David'), findsNothing);

      controller.insertRow(TestRow(id: 4, name: 'David', value: 400));
      await waitForAsync(tester);

      expect(find.text('David'), findsOneWidget);

      controller.deleteRow(1);
      await waitForAsync(tester);

      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('LoadDataEvent with append flag adds to existing data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.displayOrder.length, 3);

      final additionalRows = [TestRow(id: 4, name: 'David', value: 400), TestRow(id: 5, name: 'Eve', value: 500)];

      controller.addEvent(LoadDataEvent(rows: additionalRows, append: true));
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 5);
      expect(controller.state.rowsById.containsKey(1), true);
      expect(controller.state.rowsById.containsKey(4), true);
      expect(controller.state.rowsById.containsKey(5), true);
    });
  });
}
