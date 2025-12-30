import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

class TestRow extends DataGridRow {
  final String name;
  final int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Selection Tests', () {
    late DataGridController<TestRow> controller;
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;

    setUp(() {
      columns = [
        DataGridColumn<TestRow>(id: 1, title: 'Name', width: 150, valueAccessor: (row) => row.name),
        DataGridColumn<TestRow>(id: 2, title: 'Value', width: 100, valueAccessor: (row) => row.value),
      ];

      rows = [
        TestRow(id: 1, name: 'Alice', value: 100),
        TestRow(id: 2, name: 'Bob', value: 200),
        TestRow(id: 3, name: 'Charlie', value: 300),
        TestRow(id: 4, name: 'David', value: 400),
        TestRow(id: 5, name: 'Eve', value: 500),
      ];

      controller = DataGridController<TestRow>(initialColumns: columns, initialRows: rows);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('SelectionMode.none prevents selection', (tester) async {
      controller.setSelectionMode(SelectionMode.none);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.none);
      expect(controller.state.isSelectionEnabled, false);

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
    });

    testWidgets('SelectionMode.single allows one row selection', (tester) async {
      controller.setSelectionMode(SelectionMode.single);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.single);

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 1);
      expect(controller.state.selection.isRowSelected(1), true);

      controller.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 1);
      expect(controller.state.selection.isRowSelected(1), false);
      expect(controller.state.selection.isRowSelected(2), true);
    });

    testWidgets('SelectionMode.multiple allows multi-row selection', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.multiple);

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 1);

      controller.addEvent(SelectRowEvent(rowId: 2, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 2);
      expect(controller.state.selection.isRowSelected(1), true);
      expect(controller.state.selection.isRowSelected(2), true);

      controller.addEvent(SelectRowEvent(rowId: 3, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 3);
    });

    testWidgets('selection column appears in multiple mode', (tester) async {
      controller.setSelectionMode(SelectionMode.single);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.effectiveColumns.length, 2);

      controller.setSelectionMode(SelectionMode.multiple);
      await tester.pumpAndSettle();

      expect(controller.state.effectiveColumns.length, 3);
      expect(controller.state.effectiveColumns[0].id, -1);
    });

    testWidgets('clear selection removes all selections', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 3, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 3);

      controller.addEvent(ClearSelectionEvent());
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
      expect(controller.state.selection.focusedRowId, null);
    });

    testWidgets('select all visible rows', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectAllRowsEvent(rowIds: {1, 2, 3, 4, 5}));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 5);
      expect(controller.state.selection.isRowSelected(1), true);
      expect(controller.state.selection.isRowSelected(2), true);
      expect(controller.state.selection.isRowSelected(3), true);
      expect(controller.state.selection.isRowSelected(4), true);
      expect(controller.state.selection.isRowSelected(5), true);
    });

    testWidgets('toggle selection in single mode', (tester) async {
      controller.setSelectionMode(SelectionMode.single);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1), true);

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
    });

    testWidgets('toggle selection in multi mode', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1), true);

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1), false);
      expect(controller.state.selection.selectedRowIds.length, 0);
    });

    testWidgets('focused row updates on selection', (tester) async {
      controller.setSelectionMode(SelectionMode.single);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 1);

      controller.addEvent(SelectRowEvent(rowId: 3));
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 3);
    });

    testWidgets('select rows range', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowsRangeEvent(startRowId: 2, endRowId: 4));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 3);
      expect(controller.state.selection.isRowSelected(2), true);
      expect(controller.state.selection.isRowSelected(3), true);
      expect(controller.state.selection.isRowSelected(4), true);
      expect(controller.state.selection.isRowSelected(1), false);
      expect(controller.state.selection.isRowSelected(5), false);
    });

    testWidgets('enableMultiSelect helper method works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.single);

      controller.enableMultiSelect(true);
      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.multiple);

      controller.enableMultiSelect(false);
      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.single);
    });

    testWidgets('disableSelection helper method works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.single);

      controller.disableSelection();
      await tester.pumpAndSettle();

      expect(controller.state.selection.mode, SelectionMode.none);
    });

    testWidgets('changing selection mode clears existing selections', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 2);

      controller.setSelectionMode(SelectionMode.single);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
    });

    testWidgets('canSelectRow callback prevents selection', (tester) async {
      final restrictedController = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        canSelectRow: (rowId) => rowId != 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: restrictedController)),
        ),
      );

      await tester.pumpAndSettle();

      restrictedController.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(restrictedController.state.selection.isRowSelected(1), true);

      restrictedController.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      expect(restrictedController.state.selection.isRowSelected(2), false);

      restrictedController.dispose();
    });

    testWidgets('selection persists through data updates', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 2);

      controller.updateRow(1, TestRow(id: 1, name: 'Alice Updated', value: 150));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 2);
      expect(controller.state.selection.isRowSelected(1), true);
    });

    testWidgets('deleting selected row removes it from selection', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 2);

      controller.deleteRow(1);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 1);
      expect(controller.state.selection.isRowSelected(1), false);
      expect(controller.state.selection.isRowSelected(2), true);
    });
  });
}
