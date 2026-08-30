import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class _Row extends DataGridRow {
  final String label;
  final double contentHeight;

  _Row({required double id, required this.label, required this.contentHeight}) {
    this.id = id;
  }
}

/// Reports [contentHeight] as its natural height — used to give specific
/// rows deterministic, different intrinsic heights.
class _FixedHeightCell extends StatelessWidget {
  const _FixedHeightCell();

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<_Row>(context);
    return SizedBox(width: double.infinity, height: scope.row.contentHeight);
  }
}

DataGridController<_Row> _makeController({
  required List<_Row> rows,
  required double estimatedHeight,
  required double maxHeight,
}) {
  final columns = [
    DataGridColumn<_Row>(id: 1, title: 'Label', width: 100, valueAccessor: (r) => r.label),
    DataGridColumn<_Row>(
      id: 2,
      title: 'Content',
      width: 100,
      cellWidget: const _FixedHeightCell(),
    ),
  ];
  return DataGridController<_Row>(
    initialColumns: columns,
    initialRows: rows,
    sortDebounce: Duration.zero,
    filterDebounce: Duration.zero,
  );
}

void main() {
  group('autoRowHeight', () {
    testWidgets(
      'a short row is not sized to match a taller sibling row '
      '(regression: default/Center cell widgets reporting maxHeight '
      'as their measured height regardless of content)',
      (tester) async {
        final rows = [
          _Row(id: 0, label: 'tall', contentHeight: 200),
          _Row(id: 1, label: 'short', contentHeight: 20),
          _Row(id: 2, label: 'short2', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                // Large enough to keep all three rows built/measured at once.
                cacheExtent: 1000,
                autoRowHeight: const AutoRowHeight(
                  estimatedHeight: 48,
                  minHeight: 10,
                  maxHeight: 300,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // One extra pump lets the post-frame measurement-correction callback
        // (which applies the just-measured heights via setState) land.
        await tester.pump();
        await tester.pumpAndSettle();

        Size cellSize(double rowId, int columnId) {
          final finder = find.byKey(ValueKey('cell_${rowId}_$columnId'));
          expect(finder, findsOneWidget, reason: 'cell $rowId/$columnId should be built');
          return tester.getSize(finder);
        }

        final tallRowHeight = cellSize(0, 2).height;
        final shortRowHeight = cellSize(1, 2).height;
        final shortRow2Height = cellSize(2, 2).height;

        expect(
          tallRowHeight,
          closeTo(200, 1.0),
          reason: 'the tall row should grow to fit its 200px content',
        );
        // The short rows' "Content" cell only needs 20px, but the "Label"
        // column's default text cell in that same row has its own (larger,
        // theme-dependent) natural height, and row height = max across a
        // row's cells — so assert well below the tall row / maxHeight clamp
        // rather than pinning to the exact default-cell height.
        expect(
          shortRowHeight,
          lessThan(tallRowHeight / 2),
          reason:
              'the short rows must size to their own content, not to the '
              'tall sibling row (200px) or the maxHeight clamp (300px)',
        );
        expect(
          shortRow2Height,
          closeTo(shortRowHeight, 0.5),
          reason: 'two rows with identical content should measure identically',
        );

        // Every cell in a row shares that row's height (standard grid
        // semantics: row height = max intrinsic height across its cells).
        expect(cellSize(1, 1).height, closeTo(shortRowHeight, 0.5));
      },
    );

    testWidgets(
      'default (fixed-height) mode is unaffected: rows stay at the fixed '
      'row height regardless of cellWidget content',
      (tester) async {
        final rows = [
          _Row(id: 0, label: 'tall', contentHeight: 200),
          _Row(id: 1, label: 'short', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                rowHeight: 48,
                // autoRowHeight intentionally omitted (default: null).
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final tallRowSize = tester.getSize(find.byKey(const ValueKey('cell_0.0_2')));
        final shortRowSize = tester.getSize(find.byKey(const ValueKey('cell_1.0_2')));

        expect(tallRowSize.height, closeTo(48, 0.5));
        expect(shortRowSize.height, closeTo(48, 0.5));
      },
    );
  });
}
