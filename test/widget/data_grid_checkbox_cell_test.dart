import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid/data_grid.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_checkbox_cell.dart';

class TestRow extends DataGridRow {
  final String name;

  TestRow({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('DataGridCheckboxCell', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: [DataGridColumn(id: 1, title: 'Name', width: 150)],
        initialRows: [
          TestRow(id: 1.0, name: 'Alice'),
          TestRow(id: 2.0, name: 'Bob'),
          TestRow(id: 3.0, name: 'Charlie'),
        ],
      );
      controller.setSelectionMode(SelectionMode.multiple);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCheckboxCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice'),
              rowId: 1.0,
              rowIndex: 0,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox is unchecked when row not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCheckboxCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice'),
              rowId: 1.0,
              rowIndex: 0,
              controller: controller,
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('checkbox is checked when row is selected', (tester) async {
      controller.addEvent(SelectRowEvent(rowId: 1.0, multiSelect: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCheckboxCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice'),
              rowId: 1.0,
              rowIndex: 0,
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('toggles selection on checkbox tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCheckboxCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice'),
              rowId: 1.0,
              rowIndex: 0,
              controller: controller,
            ),
          ),
        ),
      );

      expect(controller.state.selection.isRowSelected(1.0), false);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1.0), true);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1.0), false);
    });

    testWidgets('toggles selection on container tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCheckboxCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice'),
              rowId: 1.0,
              rowIndex: 0,
              controller: controller,
            ),
          ),
        ),
      );

      expect(controller.state.selection.isRowSelected(1.0), false);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1.0), true);
    });
  });

  group('DataGridCheckboxHeaderCell', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: [DataGridColumn(id: 1, title: 'Name', width: 150)],
        initialRows: [
          TestRow(id: 1.0, name: 'Alice'),
          TestRow(id: 2.0, name: 'Bob'),
          TestRow(id: 3.0, name: 'Charlie'),
        ],
      );
      controller.setSelectionMode(SelectionMode.multiple);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders header checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGridCheckboxHeaderCell<TestRow>(controller: controller)),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox is unchecked when no rows selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGridCheckboxHeaderCell<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('selects all visible rows on checkbox tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGridCheckboxHeaderCell<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isEmpty, true);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isNotEmpty, true);
    });

    testWidgets('clears selection when all rows selected', (tester) async {
      controller.addEvent(SelectAllRowsEvent());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGridCheckboxHeaderCell<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isNotEmpty, true);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isEmpty, true);
    });

    testWidgets('checkbox is tristate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGridCheckboxHeaderCell<TestRow>(controller: controller)),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.tristate, true);
    });
  });
}
