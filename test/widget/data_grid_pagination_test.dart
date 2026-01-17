import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/events/filter_events.dart';
import 'package:flutter_data_grid/models/events/sort_events.dart';

class TestRow extends DataGridRow {
  String name;
  int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

Future<void> waitForAsync(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

Future<void> waitForStateUpdate() async {
  await Future.delayed(const Duration(milliseconds: 50));
}

void main() {
  group('DataGrid Pagination Tests', () {
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
          filterable: true,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Value',
          width: 100,
          valueAccessor: (row) => row.value.toString(),
          filterable: true,
        ),
      ];

      rows = List.generate(
        100,
        (index) => TestRow(
          id: index.toDouble(),
          name: 'Item $index',
          value: index * 10,
        ),
      );

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

    test('pagination is disabled by default', () {
      expect(controller.state.pagination.enabled, false);
      expect(controller.state.displayOrder.length, 100);
    });

    test('enable pagination slices displayOrder correctly', () async {
      controller.enablePagination(true);
      await waitForStateUpdate();

      expect(controller.state.pagination.enabled, true);
      expect(controller.state.pagination.pageSize, 50);
      expect(controller.state.pagination.currentPage, 1);
      expect(controller.state.displayOrder.length, 50);
      expect(controller.state.totalItems, 100);
    });

    test('setPageSize updates page size and reslices data', () async {
      controller.enablePagination(true);
      await waitForStateUpdate();

      controller.setPageSize(25);
      await waitForStateUpdate();

      expect(controller.state.pagination.pageSize, 25);
      expect(controller.state.displayOrder.length, 25);
      expect(controller.state.totalItems, 100);
    });

    test('nextPage navigates to next page', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 1);
      expect(controller.state.displayOrder.first, 0.0);

      controller.nextPage();
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 2);
      expect(controller.state.displayOrder.first, 10.0);
    });

    test('previousPage navigates to previous page', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      controller.setPage(3);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 3);

      controller.previousPage();
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 2);
      expect(controller.state.displayOrder.first, 10.0);
    });

    test('firstPage navigates to first page', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      controller.setPage(5);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 5);

      controller.firstPage();
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 1);
      expect(controller.state.displayOrder.first, 0.0);
    });

    test('lastPage navigates to last page', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      controller.lastPage();
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 10);
      expect(controller.state.displayOrder.length, 10);
      expect(controller.state.displayOrder.last, 99.0);
    });

    test('setPage navigates to specific page', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      controller.setPage(5);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 5);
      expect(controller.state.displayOrder.first, 40.0);
      expect(controller.state.displayOrder.last, 49.0);
    });

    test('setPage clamps to valid page range', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      controller.setPage(0);
      await waitForStateUpdate();
      expect(controller.state.pagination.currentPage, 1);

      controller.setPage(100);
      await waitForStateUpdate();
      expect(controller.state.pagination.currentPage, 10);
    });

    test('hasNextPage returns correct value', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      expect(controller.state.hasNextPage, true);

      controller.setPage(10);
      await waitForStateUpdate();
      expect(controller.state.hasNextPage, false);
    });

    test('hasPreviousPage returns correct value', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      expect(controller.state.hasPreviousPage, false);

      controller.setPage(2);
      await waitForStateUpdate();
      expect(controller.state.hasPreviousPage, true);
    });

    test('currentPageStart and currentPageEnd calculate correctly', () async {
      controller.enablePagination(true);
      controller.setPageSize(25);
      await waitForStateUpdate();

      expect(controller.state.currentPageStart, 1);
      expect(controller.state.currentPageEnd, 25);

      controller.setPage(2);
      await waitForStateUpdate();
      expect(controller.state.currentPageStart, 26);
      expect(controller.state.currentPageEnd, 50);
    });

    test('disable pagination shows all rows', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      expect(controller.state.displayOrder.length, 10);

      controller.enablePagination(false);
      await waitForStateUpdate();

      expect(controller.state.pagination.enabled, false);
      expect(controller.state.displayOrder.length, 100);
    });

    test('pagination resets to page 1 when filter is applied', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      controller.setPage(5);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 5);

      controller.addEvent(
        FilterEvent(
          columnId: 1,
          operator: FilterOperator.contains,
          value: 'Item 1',
        ),
      );
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 1);
    });

    test('pagination resets to page 1 when sort is applied', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      controller.setPage(5);
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 5);

      controller.addEvent(
        SortEvent(columnId: 1, direction: SortDirection.ascending),
      );
      await waitForStateUpdate();
      await waitForStateUpdate();

      expect(controller.state.pagination.currentPage, 1);
    });

    test('pagination works with filtered data', () async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForStateUpdate();

      controller.addEvent(
        FilterEvent(
          columnId: 1,
          operator: FilterOperator.contains,
          value: 'Item 1',
        ),
      );
      await waitForStateUpdate();

      final filteredCount = controller.state.totalItems;
      expect(filteredCount, greaterThan(0));
      expect(controller.state.displayOrder.length, math.min(10, filteredCount));
      expect(controller.state.pagination.currentPage, 1);
    });

    test('pagination totalPages calculates correctly', () {
      final pagination = controller.state.pagination;
      expect(pagination.totalPages(100), 2);
      expect(pagination.totalPages(50), 1);
      expect(pagination.totalPages(51), 2);
      expect(pagination.totalPages(0), 1);
    });

    test('pagination startIndex and endIndex calculate correctly', () async {
      controller.enablePagination(true);
      controller.setPageSize(25);
      controller.setPage(3);
      await waitForStateUpdate();

      final pagination = controller.state.pagination;
      expect(pagination.startIndex(100), 50);
      expect(pagination.endIndex(100), 75);
      expect(pagination.endIndex(60), 60);
    });

    testWidgets('pagination widget renders when enabled', (tester) async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForAsync(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 800,
              child: DataGrid<TestRow>(
                controller: controller,
                showPagination: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Showing 1-10 of 100'), findsOneWidget);
      expect(find.text('Page 1 of 10'), findsOneWidget);
      expect(find.byIcon(Icons.first_page), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.last_page), findsOneWidget);
    });

    testWidgets('pagination widget hides when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              showPagination: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Showing'), findsNothing);
      expect(find.text('Page'), findsNothing);
    });

    testWidgets('pagination navigation buttons work', (tester) async {
      controller.enablePagination(true);
      controller.setPageSize(10);
      await waitForAsync(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 800,
              child: DataGrid<TestRow>(
                controller: controller,
                showPagination: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final nextButton = find.byIcon(Icons.chevron_right);
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await waitForAsync(tester);

      expect(controller.state.pagination.currentPage, 2);
      expect(find.text('Page 2 of 10'), findsOneWidget);
    });

    testWidgets('pagination page size dropdown works', (tester) async {
      controller.enablePagination(true);
      await waitForAsync(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 800,
              child: DataGrid<TestRow>(
                controller: controller,
                showPagination: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButton<int>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown, warnIfMissed: false);
      await tester.pumpAndSettle();

      final item25 = find.text('25 per page');
      expect(item25, findsWidgets);

      if (item25.evaluate().isNotEmpty) {
        await tester.tap(item25.first);
        await waitForAsync(tester);

        expect(controller.state.pagination.pageSize, 25);
        expect(controller.state.displayOrder.length, 25);
      }
    });

    test('server-side pagination mode can be set', () async {
      controller.enablePagination(true);
      await waitForStateUpdate();

      controller.setServerSidePagination(true);
      await waitForStateUpdate();

      expect(controller.state.pagination.serverSide, true);
    });
  });
}
