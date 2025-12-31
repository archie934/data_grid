import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';

Future<void> waitForAsync(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

class TestRow extends DataGridRow {
  String name;
  int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Keyboard Navigation Tests', () {
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
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Value',
          width: 100,
          valueAccessor: (row) => row.value,
        ),
      ];

      rows = [
        TestRow(id: 1, name: 'Alice', value: 100),
        TestRow(id: 2, name: 'Bob', value: 200),
        TestRow(id: 3, name: 'Charlie', value: 300),
        TestRow(id: 4, name: 'David', value: 400),
        TestRow(id: 5, name: 'Eve', value: 500),
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

    testWidgets('arrow down navigates to next row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 2);
      expect(controller.state.selection.isRowSelected(2), true);
    });

    testWidgets('arrow up navigates to previous row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 3));
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 2);
      expect(controller.state.selection.isRowSelected(2), true);
    });

    testWidgets('arrow down from no selection selects first row', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, null);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 1);
      expect(controller.state.selection.isRowSelected(1), true);
    });

    testWidgets('arrow up at first row does nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 1);
    });

    testWidgets('arrow down at last row does nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 5));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 5);
    });

    testWidgets('escape clears selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
      expect(controller.state.selection.focusedRowId, null);
    });

    testWidgets('ctrl+A selects all visible rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.setSelectionMode(SelectionMode.multiple);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, greaterThan(0));
    });

    testWidgets('keyboard navigation works with SelectionMode.none disabled', (
      tester,
    ) async {
      controller.setSelectionMode(SelectionMode.none);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, null);
      expect(controller.state.selection.selectedRowIds.length, 0);
    });

    testWidgets('arrow left and right are handled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedRowId, 2);
    });

    testWidgets('keyboard events ignored during editing', (tester) async {
      final editableColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          cellValueSetter: (row, value) => row.name = value,
        ),
      ];

      final editableController = DataGridController<TestRow>(
        initialColumns: editableColumns,
        initialRows: rows,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(controller: editableController),
          ),
        ),
      );

      await tester.pumpAndSettle();

      editableController.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      editableController.startEditCell(2, 1);
      await tester.pumpAndSettle();

      expect(editableController.state.edit.isEditing, true);

      final focusedRowBefore = editableController.state.selection.focusedRowId;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(editableController.state.selection.focusedRowId, focusedRowBefore);

      editableController.dispose();
    });

    testWidgets('multiple arrow down presses navigate through rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 4);
    });

    testWidgets('multiple arrow up presses navigate through rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 5));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 4);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.state.selection.focusedRowId, 2);
    });

    testWidgets('keyboard navigation updates selection in single mode', (
      tester,
    ) async {
      controller.setSelectionMode(SelectionMode.single);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(SelectRowEvent(rowId: 2));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds, {2});

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds, {3});
      expect(controller.state.selection.isRowSelected(2), false);
    });

    testWidgets('keyboard navigation works with filtered data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(
        FilterEvent(
          columnId: 2,
          operator: FilterOperator.greaterThan,
          value: 200,
        ),
      );
      await waitForAsync(tester);

      expect(controller.state.displayOrder.length, 3);

      controller.addEvent(
        SelectRowEvent(rowId: controller.state.displayOrder[0]),
      );
      await waitForAsync(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await waitForAsync(tester);

      expect(
        controller.state.selection.focusedRowId,
        controller.state.displayOrder[1],
      );
    });

    testWidgets('keyboard navigation works with sorted data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.addEvent(
        SortEvent(columnId: 1, direction: SortDirection.descending),
      );
      await tester.pumpAndSettle();

      controller.addEvent(
        SelectRowEvent(rowId: controller.state.displayOrder[0]),
      );
      await tester.pumpAndSettle();

      final firstRowId = controller.state.selection.focusedRowId;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(
        controller.state.selection.focusedRowId,
        controller.state.displayOrder[1],
      );
      expect(controller.state.selection.focusedRowId, isNot(firstRowId));
    });

    testWidgets('DataGrid Focus widget is present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Focus), findsWidgets);
    });

    testWidgets('escape clears multiple selections', (tester) async {
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

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, 0);
    });
  });
}
