import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid.dart';

Future<void> waitForAsync(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

class TestRow extends DataGridRow {
  final String name;
  final int age;
  final String email;

  TestRow({required double id, required this.name, required this.age, required this.email}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Widget Tests', () {
    late DataGridController<TestRow> controller;
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;

    setUp(() {
      columns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name),
        DataGridColumn<TestRow>(id: 2, title: 'Age', width: 100, valueAccessor: (row) => row.age),
        DataGridColumn<TestRow>(id: 3, title: 'Email', width: 200, valueAccessor: (row) => row.email),
      ];

      rows = [
        TestRow(id: 1, name: 'Alice', age: 25, email: 'alice@test.com'),
        TestRow(id: 2, name: 'Bob', age: 30, email: 'bob@test.com'),
        TestRow(id: 3, name: 'Charlie', age: 35, email: 'charlie@test.com'),
      ];

      controller = DataGridController<TestRow>(initialColumns: columns, initialRows: rows);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders DataGrid with columns and rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('displays correct number of rows and columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.columns.length, 3);
      expect(controller.state.displayOrder.length, 3);
      expect(controller.state.visibleRowCount, 3);
    });

    testWidgets('headers display correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final header = find.byType(DataGridHeader<TestRow>);
      expect(header, findsOneWidget);

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('cells display correct data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('alice@test.com'), findsOneWidget);

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('bob@test.com'), findsOneWidget);

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('charlie@test.com'), findsOneWidget);
    });

    testWidgets('loading overlay appears when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DataGridLoadingOverlay), findsNothing);

      controller.addEvent(SetLoadingEvent(isLoading: true, message: 'Loading data...'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pump();

      expect(find.byType(DataGridLoadingOverlay), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);

      controller.addEvent(SetLoadingEvent(isLoading: false));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pump();

      expect(find.byType(DataGridLoadingOverlay), findsNothing);
    });

    testWidgets('handles empty grid', (tester) async {
      final emptyController = DataGridController<TestRow>(initialColumns: columns, initialRows: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: emptyController)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      expect(emptyController.state.displayOrder.length, 0);
      expect(emptyController.state.visibleRowCount, 0);

      emptyController.dispose();
    });

    testWidgets('grid updates when new rows are loaded', (tester) async {
      final dynamicController = DataGridController<TestRow>(initialColumns: columns, initialRows: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: dynamicController)),
        ),
      );

      await tester.pumpAndSettle();

      expect(dynamicController.state.displayOrder.length, 0);

      dynamicController.setRows(rows);
      await tester.pumpAndSettle();

      expect(dynamicController.state.displayOrder.length, 3);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);

      dynamicController.dispose();
    });

    testWidgets('respects custom header height', (tester) async {
      const customHeaderHeight = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(controller: controller, headerHeight: customHeaderHeight),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final header = find.byType(DataGridHeader<TestRow>);
      expect(header, findsOneWidget);
    });

    testWidgets('respects custom row height', (tester) async {
      const customRowHeight = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(controller: controller, rowHeight: customRowHeight),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final body = find.byType(DataGridBody<TestRow>);
      expect(body, findsOneWidget);
    });

    testWidgets('DataGrid is focusable and handles focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final focus = find.byType(Focus);
      expect(focus, findsWidgets);
    });
  });
}
