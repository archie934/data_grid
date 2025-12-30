import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class TestRow extends DataGridRow {
  String name;
  int age;
  String email;

  TestRow({required double id, required this.name, required this.age, required this.email}) {
    this.id = id;
  }
}

void main() {
  group('DataGrid Editing Tests', () {
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
          title: 'Age',
          width: 100,
          valueAccessor: (row) => row.age,
          cellValueSetter: (row, value) => row.age = value,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Email',
          width: 200,
          valueAccessor: (row) => row.email,
          cellValueSetter: (row, value) => row.email = value,
        ),
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

    testWidgets('start cell edit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, false);

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, true);
      expect(controller.state.edit.editingCellId, '1.0_1');
      expect(controller.state.edit.editingValue, 'Alice');
    });

    testWidgets('update edit value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      expect(controller.state.edit.editingValue, 'Alice');

      controller.updateCellEditValue('Alice Updated');
      await tester.pumpAndSettle();

      expect(controller.state.edit.editingValue, 'Alice Updated');
    });

    testWidgets('commit edit updates cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      controller.updateCellEditValue('Alice Modified');
      await tester.pumpAndSettle();

      controller.commitCellEdit();
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, false);
      expect(controller.state.rowsById[1]!.name, 'Alice Modified');
    });

    testWidgets('cancel edit reverts changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      final originalName = controller.state.rowsById[1]!.name;

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      controller.updateCellEditValue('Alice Modified');
      await tester.pumpAndSettle();

      controller.cancelCellEdit();
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, false);
      expect(controller.state.rowsById[1]!.name, originalName);
    });

    testWidgets('validation prevents invalid commits', (tester) async {
      final validatedColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          cellValueSetter: (row, value) => row.name = value,
          validator: (oldValue, newValue) => newValue != null && newValue.toString().isNotEmpty,
        ),
      ];

      final validatedController = DataGridController<TestRow>(initialColumns: validatedColumns, initialRows: rows);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: validatedController)),
        ),
      );

      await tester.pumpAndSettle();

      validatedController.startEditCell(1, 1);
      await tester.pumpAndSettle();

      validatedController.updateCellEditValue('');
      await tester.pumpAndSettle();

      validatedController.commitCellEdit();
      await tester.pumpAndSettle();

      expect(validatedController.state.edit.isEditing, false);
      expect(validatedController.state.rowsById[1]!.name, 'Alice');

      validatedController.dispose();
    });

    testWidgets('onCellCommit callback works', (tester) async {
      bool commitCalled = false;
      double? committedRowId;
      int? committedColumnId;
      dynamic oldVal;
      dynamic newVal;

      final callbackController = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        onCellCommit: (rowId, columnId, oldValue, newValue) async {
          commitCalled = true;
          committedRowId = rowId;
          committedColumnId = columnId;
          oldVal = oldValue;
          newVal = newValue;
          return true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: callbackController)),
        ),
      );

      await tester.pumpAndSettle();

      callbackController.startEditCell(1, 1);
      await tester.pumpAndSettle();

      callbackController.updateCellEditValue('Alice Updated');
      await tester.pumpAndSettle();

      callbackController.commitCellEdit();
      await tester.pumpAndSettle();

      expect(commitCalled, true);
      expect(committedRowId, 1);
      expect(committedColumnId, 1);
      expect(oldVal, 'Alice');
      expect(newVal, 'Alice Updated');

      callbackController.dispose();
    });

    testWidgets('onCellCommit can reject commit', (tester) async {
      final rejectController = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        onCellCommit: (rowId, columnId, oldValue, newValue) async {
          return false;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: rejectController)),
        ),
      );

      await tester.pumpAndSettle();

      rejectController.startEditCell(1, 1);
      await tester.pumpAndSettle();

      rejectController.updateCellEditValue('Alice Updated');
      await tester.pumpAndSettle();

      rejectController.commitCellEdit();
      await tester.pumpAndSettle();

      expect(rejectController.state.edit.isEditing, false);
      expect(rejectController.state.rowsById[1]!.name, 'Alice');

      rejectController.dispose();
    });

    testWidgets('canEditCell callback prevents editing', (tester) async {
      final restrictedController = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
        canEditCell: (rowId, columnId) => rowId != 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: restrictedController)),
        ),
      );

      await tester.pumpAndSettle();

      restrictedController.startEditCell(1, 1);
      await tester.pumpAndSettle();

      expect(restrictedController.state.edit.isEditing, true);

      restrictedController.cancelCellEdit();
      await tester.pumpAndSettle();

      restrictedController.startEditCell(2, 1);
      await tester.pumpAndSettle();

      expect(restrictedController.state.edit.isEditing, false);

      restrictedController.dispose();
    });

    testWidgets('non-editable columns cannot be edited', (tester) async {
      final nonEditableColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          cellValueSetter: (row, value) => row.name = value,
          editable: false,
        ),
      ];

      final nonEditableController = DataGridController<TestRow>(initialColumns: nonEditableColumns, initialRows: rows);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: nonEditableController)),
        ),
      );

      await tester.pumpAndSettle();

      nonEditableController.startEditCell(1, 1);
      await tester.pumpAndSettle();

      expect(nonEditableController.state.edit.isEditing, false);

      nonEditableController.dispose();
    });

    testWidgets('edit different cells sequentially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      expect(controller.state.edit.editingCellId, '1.0_1');

      controller.updateCellEditValue('Alice Updated');
      await tester.pumpAndSettle();

      controller.commitCellEdit();
      await tester.pumpAndSettle();

      controller.startEditCell(2, 2);
      await tester.pumpAndSettle();

      expect(controller.state.edit.editingCellId, '2.0_2');
      expect(controller.state.edit.editingValue, 30);
    });

    testWidgets('updateCell helper method works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice');

      controller.updateCell(1, 1, 'Alice Direct Update');
      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice Direct Update');
    });

    testWidgets('edit state tracks cell being edited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(2, 3);
      await tester.pumpAndSettle();

      expect(controller.state.edit.isCellEditing(2, 3), true);
      expect(controller.state.edit.isCellEditing(1, 1), false);
      expect(controller.state.edit.isCellEditing(2, 1), false);
    });

    testWidgets('edit numeric values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1, 2);
      await tester.pumpAndSettle();

      expect(controller.state.edit.editingValue, 25);

      controller.updateCellEditValue(26);
      await tester.pumpAndSettle();

      controller.commitCellEdit();
      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.age, 26);
    });

    testWidgets('starting edit on different cell commits previous edit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      controller.updateCellEditValue('Alice Modified');
      await tester.pumpAndSettle();

      controller.startEditCell(2, 1);
      await tester.pumpAndSettle();

      expect(controller.state.rowsById[1]!.name, 'Alice Modified');
      expect(controller.state.edit.editingCellId, '2.0_1');
    });
  });
}
