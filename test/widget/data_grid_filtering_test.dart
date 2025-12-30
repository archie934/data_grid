import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid.dart';
import 'package:data_grid/models/enums/filter_operator.dart';

Future<void> waitForAsync(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

class TestRow extends DataGridRow {
  final String name;
  final int age;
  final String city;
  final double salary;

  TestRow({required double id, required this.name, required this.age, required this.city, required this.salary}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Filtering State Tests', () {
    late DataGridController<TestRow> controller;
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;

    setUp(() {
      columns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name),
        DataGridColumn<TestRow>(id: 2, title: 'Age', width: 100, valueAccessor: (row) => row.age),
        DataGridColumn<TestRow>(id: 3, title: 'City', width: 150, valueAccessor: (row) => row.city),
        DataGridColumn<TestRow>(id: 4, title: 'Salary', width: 120, valueAccessor: (row) => row.salary),
      ];

      rows = [
        TestRow(id: 1, name: 'Alice', age: 25, city: 'New York', salary: 50000),
        TestRow(id: 2, name: 'Bob', age: 30, city: 'Los Angeles', salary: 60000),
        TestRow(id: 3, name: 'Charlie', age: 35, city: 'New York', salary: 75000),
        TestRow(id: 4, name: 'David', age: 28, city: 'Chicago', salary: 55000),
        TestRow(id: 5, name: 'Eve', age: 32, city: 'Los Angeles', salary: 65000),
      ];

      controller = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        filterDebounce: Duration.zero,
        sortDebounce: Duration.zero,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('filter state updates when adding filter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.filter.hasFilters, false);

      controller.addEvent(FilterEvent(columnId: 3, operator: FilterOperator.equals, value: 'New York'));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters.containsKey(3), true);
      expect(controller.state.filter.columnFilters[3]?.operator, FilterOperator.equals);
      expect(controller.state.filter.columnFilters[3]?.value, 'New York');
    });

    testWidgets('clear single column filter removes from state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 3, operator: FilterOperator.equals, value: 'New York'));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters.containsKey(3), true);

      controller.addEvent(ClearFilterEvent(columnId: 3));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters.containsKey(3), false);
      expect(controller.state.filter.hasFilters, false);
    });

    testWidgets('clear all filters removes all from state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 3, operator: FilterOperator.equals, value: 'New York'));
      await waitForAsync(tester);
      controller.addEvent(FilterEvent(columnId: 2, operator: FilterOperator.greaterThan, value: 30));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters.length, greaterThan(0));

      controller.addEvent(ClearFilterEvent());
      await waitForAsync(tester);

      expect(controller.state.filter.hasFilters, false);
      expect(controller.state.filter.columnFilters.length, 0);
    });

    testWidgets('multiple filters can be added', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 3, operator: FilterOperator.equals, value: 'Los Angeles'));
      await waitForAsync(tester);
      controller.addEvent(FilterEvent(columnId: 2, operator: FilterOperator.greaterThan, value: 30));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters.containsKey(3), true);
      expect(controller.state.filter.columnFilters.containsKey(2), true);
    });

    testWidgets('filter operator types are stored correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 1, operator: FilterOperator.contains, value: 'a'));
      await waitForAsync(tester);

      final filter = controller.state.filter.columnFilters[1];
      expect(filter, isNotNull);
      expect(filter!.operator, FilterOperator.contains);
      expect(filter.value, 'a');
    });

    testWidgets('unfilterable columns do not accept filters', (tester) async {
      final unfilterableColumns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name, filterable: false),
      ];

      final unfilterableController = DataGridController<TestRow>(
        initialColumns: unfilterableColumns,
        initialRows: rows,
        filterDebounce: Duration.zero,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: unfilterableController)),
        ),
      );
      await tester.pumpAndSettle();

      unfilterableController.addEvent(FilterEvent(columnId: 1, operator: FilterOperator.contains, value: 'Alice'));
      await waitForAsync(tester);

      expect(unfilterableController.state.displayOrder.length, rows.length);

      unfilterableController.dispose();
    });

    testWidgets('filter can be updated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FilterEvent(columnId: 1, operator: FilterOperator.contains, value: 'a'));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters[1]?.value, 'a');

      controller.addEvent(FilterEvent(columnId: 1, operator: FilterOperator.contains, value: 'b'));
      await waitForAsync(tester);

      expect(controller.state.filter.columnFilters[1]?.value, 'b');
    });
  });
}
