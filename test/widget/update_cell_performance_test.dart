import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class PerfTestRow extends DataGridRow {
  String name;

  PerfTestRow({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('UpdateCellEvent O(1) state', () {
    test('updateCell preserves rowsById reference', () async {
      final rows = List.generate(
        50000,
        (i) => PerfTestRow(id: i.toDouble(), name: 'Row $i'),
      );

      final controller = DataGridController<PerfTestRow>(
        initialColumns: [
          DataGridColumn<PerfTestRow>(
            id: 1,
            title: 'Name',
            width: 100,
            cellValueSetter: (row, value) => row.name = value as String,
          ),
        ],
        initialRows: rows,
      );
      addTearDown(controller.dispose);

      final stateBefore = controller.state;
      final rowBefore = controller.state.rowsById[42]!;
      controller.updateCell(42, 1, 'Updated');
      await Future<void>.delayed(Duration.zero);
      expect(identical(controller.state, stateBefore), isTrue);
      expect(identical(controller.state.rowsById[42], rowBefore), isTrue);
      expect(controller.state.rowsById[42]!.name, 'Updated');
    });

    test('updateRow replaces rowsById reference', () async {
      final controller = DataGridController<PerfTestRow>(
        initialColumns: [
          DataGridColumn<PerfTestRow>(
            id: 1,
            title: 'Name',
            width: 100,
            cellValueSetter: (row, value) => row.name = value as String,
          ),
        ],
        initialRows: [
          PerfTestRow(id: 1, name: 'Alice'),
          PerfTestRow(id: 2, name: 'Bob'),
        ],
      );
      addTearDown(controller.dispose);

      final stateBefore = controller.state;
      controller.updateRow(1, PerfTestRow(id: 1, name: 'Alice Updated'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(identical(controller.state, stateBefore), isFalse);
    });
  });
}
