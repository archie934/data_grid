import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid.dart';
import 'package:data_grid/models/enums/sort_direction.dart';

class TestRow extends DataGridRow {
  final String name;
  final int age;
  final double salary;

  TestRow({required double id, required this.name, required this.age, required this.salary}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Sorting State Tests', () {
    late DataGridController<TestRow> controller;
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;

    setUp(() {
      columns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name),
        DataGridColumn<TestRow>(id: 2, title: 'Age', width: 100, valueAccessor: (row) => row.age),
        DataGridColumn<TestRow>(id: 3, title: 'Salary', width: 120, valueAccessor: (row) => row.salary),
      ];

      rows = [
        TestRow(id: 1, name: 'Charlie', age: 35, salary: 75000),
        TestRow(id: 2, name: 'Alice', age: 25, salary: 50000),
        TestRow(id: 3, name: 'Bob', age: 30, salary: 60000),
        TestRow(id: 4, name: 'David', age: 28, salary: 55000),
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

    testWidgets('sort state updates when adding sort', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.sort.hasSort, false);

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      expect(controller.state.sort.hasSort, true);
      expect(controller.state.sort.sortColumns.length, 1);
      expect(controller.state.sort.sortColumns[0].columnId, 1);
      expect(controller.state.sort.sortColumns[0].direction, SortDirection.ascending);
    });

    testWidgets('sort direction changes on subsequent sort events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns[0].direction, SortDirection.ascending);

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.descending));
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns[0].direction, SortDirection.descending);
    });

    testWidgets('clear sort removes sort state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      expect(controller.state.sort.hasSort, true);

      controller.addEvent(SortEvent(columnId: 1, direction: null));
      await tester.pumpAndSettle();

      expect(controller.state.sort.hasSort, false);
      expect(controller.state.sort.sortColumns.length, 0);
    });

    testWidgets('multi-column sorting adds multiple sort columns', (tester) async {
      final multiController = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        sortDebounce: Duration.zero,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: multiController)),
        ),
      );

      await tester.pumpAndSettle();

      multiController.addEvent(SortEvent(columnId: 2, direction: SortDirection.ascending, multiSort: false));
      await tester.pumpAndSettle();

      multiController.addEvent(SortEvent(columnId: 3, direction: SortDirection.ascending, multiSort: true));
      await tester.pumpAndSettle();

      expect(multiController.state.sort.sortColumns.length, 2);
      expect(multiController.state.sort.sortColumns[0].columnId, 2);
      expect(multiController.state.sort.sortColumns[1].columnId, 3);

      multiController.dispose();
    });

    testWidgets('sort column shows correct priority in multi-sort', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 2, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending, multiSort: true));
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns.length, 2);
      expect(controller.state.sort.sortColumns[0].priority, 0);
      expect(controller.state.sort.sortColumns[1].priority, 1);
    });

    testWidgets('unsortable columns do not sort', (tester) async {
      final unsortableColumns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name, sortable: false),
      ];

      final unsortableController = DataGridController<TestRow>(
        initialColumns: unsortableColumns,
        initialRows: rows,
        sortDebounce: Duration.zero,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: unsortableController)),
        ),
      );

      await tester.pumpAndSettle();

      unsortableController.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      expect(unsortableController.state.sort.hasSort, false);

      unsortableController.dispose();
    });

    testWidgets('header shows sort icon when sorted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsNothing);

      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending));
      await tester.pumpAndSettle();

      expect(controller.state.sort.hasSort, true);
    });

    testWidgets('tapping header updates sort state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final nameHeader = find.ancestor(of: find.text('Name'), matching: find.byType(DataGridHeaderCell));

      await tester.tap(nameHeader);
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns.length, greaterThan(0));
    });

    testWidgets('removing sort column updates state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SortEvent(columnId: 2, direction: SortDirection.ascending));
      controller.addEvent(SortEvent(columnId: 1, direction: SortDirection.ascending, multiSort: true));
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns.length, 2);

      controller.addEvent(SortEvent(columnId: 2, direction: null));
      await tester.pumpAndSettle();

      expect(controller.state.sort.sortColumns.any((s) => s.columnId == 2), false);
    });
  });
}
