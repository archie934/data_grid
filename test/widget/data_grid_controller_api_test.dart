import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class ApiTestRow extends DataGridRow {
  String name;
  double price;

  ApiTestRow({required double id, required this.name, required this.price}) {
    this.id = id;
  }
}

DataGridController<ApiTestRow> _createController() {
  final controller = DataGridController<ApiTestRow>(
    sortDebounce: Duration.zero,
    filterDebounce: Duration.zero,
    initialColumns: [
      DataGridColumn<ApiTestRow>(
        id: 1,
        title: 'Name',
        width: 100,
        valueAccessor: (row) => row.name,
      ),
      DataGridColumn<ApiTestRow>(
        id: 2,
        title: 'Price',
        width: 80,
        valueAccessor: (row) => row.price,
      ),
    ],
    initialRows: [
      ApiTestRow(id: 1, name: 'Banana', price: 30),
      ApiTestRow(id: 2, name: 'Apple', price: 10),
      ApiTestRow(id: 3, name: 'Cherry', price: 20),
    ],
  );
  addTearDown(controller.dispose);
  return controller;
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  group('DataGridController headless API', () {
    test('sortColumn sorts and clears', () async {
      final controller = _createController();

      controller.sortColumn(1, SortDirection.ascending);
      await _settle();
      expect(controller.state.displayOrder, [2.0, 1.0, 3.0]);

      controller.sortColumn(2, SortDirection.descending);
      await _settle();
      expect(controller.state.displayOrder, [1.0, 3.0, 2.0]);

      controller.sortColumn(2, null);
      await _settle();
      expect(controller.state.sort.hasSort, isFalse);
    });

    test('filterColumn and clearFilter', () async {
      final controller = _createController();

      controller.filterColumn(2, FilterOperator.greaterThan, 15);
      await _settle();
      expect(controller.state.displayOrder.toSet(), {1.0, 3.0});

      controller.clearFilter(columnId: 2);
      await _settle();
      expect(controller.state.displayOrder.toSet(), {1.0, 2.0, 3.0});
    });

    test('row selection wrappers', () async {
      final controller = _createController();
      controller.setSelectionMode(SelectionMode.multiple);
      await _settle();

      controller.selectRow(1, multiSelect: true);
      controller.selectRow(3, multiSelect: true);
      await _settle();
      expect(controller.state.selection.selectedRowIds, {1.0, 3.0});

      controller.clearSelection();
      await _settle();
      expect(controller.state.selection.selectedRowIds, isEmpty);

      controller.selectRowsRange(1, 2);
      await _settle();
      expect(controller.state.selection.selectedRowIds, {1.0, 2.0});

      controller.selectAllRows();
      await _settle();
      expect(controller.state.selection.selectedRowIds, {1.0, 2.0, 3.0});

      controller.clearSelection();
      controller.selectAllRows(rowIds: {2});
      await _settle();
      expect(controller.state.selection.selectedRowIds, {2.0});
    });

    test('cell selection wrappers', () async {
      final controller = _createController();

      controller.focusCell(1, 1);
      await _settle();
      expect(controller.state.selection.focusedCells, ['1.0_1']);

      controller.shiftSelectCell(1, 2);
      await _settle();
      expect(controller.state.selection.focusedCells, ['1.0_1', '1.0_2']);

      controller.toggleCellInSelection(1, 1);
      await _settle();
      expect(controller.state.selection.focusedCells, ['1.0_2']);

      controller.navigateCell(CellNavDirection.down);
      await _settle();
      expect(controller.state.selection.focusedCells, ['2.0_2']);

      controller.navigateCell(CellNavDirection.left, extend: true);
      await _settle();
      expect(controller.state.selection.focusedCells, ['2.0_2', '2.0_1']);

      controller.clearCellSelection();
      await _settle();
      expect(controller.state.selection.focusedCells, isEmpty);
    });

    test('resizeColumn and reorderColumn', () async {
      final controller = _createController();

      controller.resizeColumn(2, 150);
      await _settle();
      expect(controller.state.columns.firstWhere((c) => c.id == 2).width, 150);

      controller.reorderColumn(0, 1);
      await _settle();
      expect(controller.state.columns.map((c) => c.id), [2, 1]);
    });
  });
}
