import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class TestRow extends DataGridRow {
  String name;
  int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cell selection and copy', () {
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
          cellValueSetter: (row, value) => row.name = value?.toString() ?? '',
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Value',
          width: 100,
          valueAccessor: (row) => row.value,
          cellValueSetter: (row, value) =>
              row.value = int.tryParse(value?.toString() ?? '') ?? row.value,
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
      );
    });

    tearDown(() {
      controller.dispose();
    });

    // ── FocusCellEvent ────────────────────────────────────────────────────────

    test('FocusCellEvent sets a single focused cell', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['1.0_1']);
      expect(controller.state.selection.activeCellId, '1.0_1');
    });

    test('FocusCellEvent replaces previous focused cell', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(FocusCellEvent(rowId: 2, columnId: 2));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['2.0_2']);
    });

    // ── ShiftSelectCellEvent ──────────────────────────────────────────────────

    test('ShiftSelectCellEvent appends a cell to the path', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(ShiftSelectCellEvent(rowId: 2, columnId: 1));
      await Future.delayed(Duration.zero);

      expect(
        controller.state.selection.focusedCells,
        ['1.0_1', '2.0_1'],
      );
      expect(controller.state.selection.activeCellId, '2.0_1');
    });

    test('ShiftSelectCellEvent on empty path acts like FocusCellEvent',
        () async {
      controller.addEvent(ShiftSelectCellEvent(rowId: 2, columnId: 1));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['2.0_1']);
    });

    test('ShiftSelectCellEvent is no-op when cell is already active', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(ShiftSelectCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);

      // Should still be just the one cell — no duplicate appended
      expect(controller.state.selection.focusedCells, ['1.0_1']);
    });

    // ── ToggleCellInSelectionEvent ────────────────────────────────────────────

    test('ToggleCellInSelectionEvent adds a cell when absent', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(
        ToggleCellInSelectionEvent(rowId: 2, columnId: 1),
      );
      await Future.delayed(Duration.zero);

      expect(
        controller.state.selection.focusedCells,
        containsAll(['1.0_1', '2.0_1']),
      );
    });

    test('ToggleCellInSelectionEvent removes a cell when present', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(
        ToggleCellInSelectionEvent(rowId: 2, columnId: 1),
      );
      await Future.delayed(Duration.zero);
      controller.addEvent(
        ToggleCellInSelectionEvent(rowId: 1, columnId: 1),
      );
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['2.0_1']);
    });

    // ── ClearCellSelectionEvent ───────────────────────────────────────────────

    test('ClearCellSelectionEvent empties the focused-cells path', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(ShiftSelectCellEvent(rowId: 2, columnId: 1));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells.length, 2);

      controller.addEvent(ClearCellSelectionEvent());
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, isEmpty);
      expect(controller.state.selection.activeCellId, isNull);
    });

    // ── NavigateCellEvent ─────────────────────────────────────────────────────

    test('NavigateCellEvent moves active cell down', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(NavigateCellEvent(CellNavDirection.down));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['2.0_1']);
    });

    test('NavigateCellEvent moves active cell right', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(NavigateCellEvent(CellNavDirection.right));
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['1.0_2']);
    });

    test('NavigateCellEvent does not move past last column', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 2));
      await Future.delayed(Duration.zero);
      controller.addEvent(NavigateCellEvent(CellNavDirection.right));
      await Future.delayed(Duration.zero);

      // Still at column 2 — no column 3
      expect(controller.state.selection.activeCellId, '1.0_2');
    });

    test('NavigateCellEvent with extend=true appends cell to path', () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(
        NavigateCellEvent(CellNavDirection.down, extend: true),
      );
      await Future.delayed(Duration.zero);

      expect(
        controller.state.selection.focusedCells,
        ['1.0_1', '2.0_1'],
      );
    });

    test('NavigateCellEvent with extend=true shrinks path when going back',
        () async {
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await Future.delayed(Duration.zero);
      controller.addEvent(
        NavigateCellEvent(CellNavDirection.down, extend: true),
      );
      await Future.delayed(Duration.zero);
      // Now path is [1.0_1, 2.0_1]. Going back up should shrink.
      controller.addEvent(
        NavigateCellEvent(CellNavDirection.up, extend: true),
      );
      await Future.delayed(Duration.zero);

      expect(controller.state.selection.focusedCells, ['1.0_1']);
    });

    // ── CopyCellsEvent (single cell) ──────────────────────────────────────────

    testWidgets('CopyCellsEvent copies single cell value to clipboard',
        (tester) async {
      // Set up clipboard mock
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      expect(clipboardData['text'], 'Alice');
    });

    testWidgets('CopyCellsEvent copies single numeric cell value to clipboard',
        (tester) async {
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 2, columnId: 2));
      await tester.pumpAndSettle();

      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      expect(clipboardData['text'], '200');
    });

    // ── CopyCellsEvent (multi-cell) ───────────────────────────────────────────

    testWidgets('CopyCellsEvent copies multiple cells as CSV', (tester) async {
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Focus row 1 col 1, shift-select row 2 col 1
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();
      controller.addEvent(ShiftSelectCellEvent(rowId: 2, columnId: 1));
      await tester.pumpAndSettle();

      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      // Two cells in the same column → two lines, no comma
      expect(clipboardData['text'], 'Alice\nBob');
    });

    testWidgets('CopyCellsEvent copies a row of two cells as comma-separated',
        (tester) async {
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Select both columns of row 1
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();
      controller.addEvent(
        ToggleCellInSelectionEvent(rowId: 1, columnId: 2),
      );
      await tester.pumpAndSettle();

      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      expect(clipboardData['text'], 'Alice,100');
    });

    // ── Stale-copy regression: copy after edit ────────────────────────────────

    testWidgets(
        'CopyCellsEvent after commit uses the new value, not the stale one',
        (tester) async {
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Focus then start editing cell (1, 1)
      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      controller.startEditCell(1, 1);
      await tester.pumpAndSettle();

      controller.updateCellEditValue('Alice Edited');
      await tester.pumpAndSettle();

      // Commit and immediately copy
      controller.commitCellEdit();
      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      // Must be the new value, not 'Alice'
      expect(clipboardData['text'], 'Alice Edited');
    });

    testWidgets(
        'CopyCellsEvent with no focused cells is a no-op (does not crash)',
        (tester) async {
      String? lastClipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            lastClipboard =
                (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // No focused cells
      controller.addEvent(CopyCellsEvent());
      await tester.pumpAndSettle();

      expect(lastClipboard, isNull);
    });

    // ── Enter key triggers edit on focused cell ───────────────────────────────

    testWidgets('Enter on focused editable cell starts editing', (tester) async {
      final editableColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          cellValueSetter: (row, value) =>
              row.name = value?.toString() ?? '',
          editable: true,
        ),
      ];

      final editController = DataGridController<TestRow>(
        initialColumns: editableColumns,
        initialRows: rows,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: editController)),
        ),
      );
      await tester.pumpAndSettle();

      // Focus a cell first
      editController.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      expect(editController.state.selection.activeCellId, '1.0_1');
      expect(editController.state.edit.isEditing, false);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(editController.state.edit.isEditing, true);
      expect(editController.state.edit.editingCellId, '1.0_1');

      editController.dispose();
    });

    testWidgets('Enter on focused non-editable cell does not start editing',
        (tester) async {
      final nonEditableColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Name',
          width: 150,
          valueAccessor: (row) => row.name,
          editable: false,
        ),
      ];

      final nonEditController = DataGridController<TestRow>(
        initialColumns: nonEditableColumns,
        initialRows: rows,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(controller: nonEditController),
          ),
        ),
      );
      await tester.pumpAndSettle();

      nonEditController.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(nonEditController.state.edit.isEditing, false);

      nonEditController.dispose();
    });

    testWidgets('Enter without active cell does nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.state.selection.activeCellId, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, false);
    });

    // ── Ctrl+C keyboard shortcut ──────────────────────────────────────────────

    testWidgets('Ctrl+C with focused cell copies to clipboard', (tester) async {
      final clipboardData = <String, dynamic>{};
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData.addAll(
              Map<String, dynamic>.from(call.arguments as Map),
            );
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 3, columnId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(clipboardData['text'], 'Charlie');
    });

    testWidgets('Ctrl+C with no focused cells does not copy', (tester) async {
      String? lastClipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            lastClipboard =
                (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(lastClipboard, isNull);
    });

    // ── Arrow navigation with cell focus ─────────────────────────────────────

    testWidgets('Arrow keys navigate cell focus when cell is active',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.state.selection.activeCellId, '2.0_1');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(controller.state.selection.activeCellId, '2.0_2');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(controller.state.selection.activeCellId, '1.0_2');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(controller.state.selection.activeCellId, '1.0_1');
    });

    testWidgets('Shift+Arrow extends cell selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedCells.length, 2);
      expect(controller.state.selection.focusedCells, ['1.0_1', '2.0_1']);
      expect(controller.state.selection.activeCellId, '2.0_1');
    });

    testWidgets('Shift+Arrow contracts selection when moving back',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      // Extend down twice
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedCells.length, 3);

      // Shift+up to contract
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedCells.length, 2);
      expect(controller.state.selection.activeCellId, '2.0_1');
    });

    // ── Escape clears cell selection ─────────────────────────────────────────

    testWidgets('Escape clears cell selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(FocusCellEvent(rowId: 1, columnId: 1));
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedCells, isNotEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.state.selection.focusedCells, isEmpty);
      expect(controller.state.selection.activeCellId, isNull);
    });
  });
}
