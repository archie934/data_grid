import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

/// Guards the cost of a **discontinuous** scroll frame — one whose row window
/// shares nothing with the previous frame's.
///
/// Dragging the vertical scrollbar thumb is the case that matters: over 100k
/// rows a ~500px track maps ~2px of thumb travel to ~390 rows, so every drag
/// frame lands on a completely fresh window. Two things used to make that
/// frame far more expensive than it needed to be:
///
///  1. The cache-extent buffer was built on every jump frame even though none
///     of it survives to the next one — at the default extent that's 31 rows
///     built to show 13.
///  2. Cells were keyed by absolute row index, so on a jump *no* key matched
///     and the whole viewport was destroyed and re-inflated every frame — new
///     `State` objects, `RenderObject`s and gesture recognizers per cell,
///     rather than updating the elements already there.
///
/// Measured on the 20-frame jump below (100k rows × 6 columns): builds went
/// 3720 → 1560 and element inflations 3720 → 0.
int _builds = 0;
int _inflations = 0;

/// Stands in for a real `cellWidget` (the example's `ActionsCellWidget`): it
/// reads [CellScope], so it legitimately rebuilds when its row changes — what
/// it must *not* do is get re-inflated.
class _ProbeCell extends StatefulWidget {
  const _ProbeCell();

  @override
  State<_ProbeCell> createState() => _ProbeCellState();
}

class _ProbeCellState extends State<_ProbeCell> {
  @override
  void initState() {
    super.initState();
    _inflations++;
  }

  @override
  Widget build(BuildContext context) {
    _builds++;
    final scope = CellScope.of<_Row>(context);
    return Text('${scope.value}', overflow: TextOverflow.ellipsis);
  }
}

class _Row extends DataGridRow {
  final String label;

  _Row({required double id, required this.label}) {
    this.id = id;
  }
}

void main() {
  const rowCount = 100000;
  const columnCount = 6;
  const rowHeight = 48.0;
  const viewportHeight = 552.0; // 600 - header, no filter row, no pagination

  // The window a jump frame is allowed to build: the viewport only, no buffer.
  const visibleRows = viewportHeight ~/ rowHeight + 1; // 12 (integer div) + 1
  const maxCellsPerJumpFrame = (visibleRows + 1) * columnCount;

  DataGridController<_Row> makeController() => DataGridController<_Row>(
    initialColumns: [
      for (int c = 1; c <= columnCount; c++)
        DataGridColumn<_Row>(
          id: c,
          title: 'C$c',
          width: 120,
          filterable: false,
          cellWidget: const _ProbeCell(),
          valueAccessor: (row) => row.label,
        ),
    ],
    initialRows: List.generate(
      rowCount,
      (i) => _Row(id: i.toDouble(), label: 'R$i'),
    ),
    sortDebounce: Duration.zero,
    filterDebounce: Duration.zero,
  );

  Widget grid(DataGridController<_Row> c) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 600,
        child: DataGrid<_Row>(
          controller: c,
          showPagination: false,
          rowHeight: rowHeight,
          cacheExtent: 400,
        ),
      ),
    ),
  );

  Future<TestPointer> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = makeController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(grid(controller));
    await tester.pumpAndSettle();

    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      pointer.hover(tester.getCenter(find.byType(DataGrid<_Row>))),
    );
    await tester.pump();
    return pointer;
  }

  testWidgets(
    'a jump frame builds only the viewport, and reuses its cell elements',
    (tester) async {
      final pointer = await mount(tester);

      // ~390 rows per frame: the distance 2px of scrollbar thumb covers here.
      const jump = Offset(0, 18750);
      const frames = 20;

      // One jump first, so the slot-keyed elements exist; the assertions below
      // are about the *steady state* of a drag, not its first frame.
      await tester.sendEventToBinding(pointer.scroll(jump));
      await tester.pump(const Duration(milliseconds: 16));

      _builds = 0;
      _inflations = 0;
      for (int i = 0; i < frames; i++) {
        await tester.sendEventToBinding(pointer.scroll(jump));
        await tester.pump(const Duration(milliseconds: 16));
      }

      // ignore: avoid_print
      print(
        '[perf] $frames jump frames (~390 rows each): '
        'builds=$_builds inflations=$_inflations',
      );

      // Every jump frame necessarily rebuilds the viewport — the rows really
      // are all different. What it must not do is build the off-screen buffer
      // too (that was 186 cells/frame instead of 78).
      expect(
        _builds,
        lessThanOrEqualTo(frames * maxCellsPerJumpFrame),
        reason:
            'a jump frame must skip the cache-extent buffer: nothing in it '
            'survives to the next frame',
      );

      // The regression this really guards: elements must be *updated*, not
      // destroyed and re-inflated. Before the slot-keying fix this equalled
      // `_builds` exactly.
      expect(
        _inflations,
        isZero,
        reason:
            'jump frames must reuse the previous frame\'s cell elements '
            'instead of inflating a fresh viewport every frame',
      );
    },
  );

  testWidgets('continuous scrolling still builds only newly-revealed cells', (
    tester,
  ) async {
    final pointer = await mount(tester);

    // A one-row step reveals exactly one row of cells; everything else in the
    // window must carry over as the identical widget instance.
    _builds = 0;
    _inflations = 0;
    const steps = 10;
    for (int i = 0; i < steps; i++) {
      await tester.sendEventToBinding(
        pointer.scroll(const Offset(0, rowHeight)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }

    // ignore: avoid_print
    print(
      '[perf] $steps × 1-row continuous steps: '
      'builds=$_builds inflations=$_inflations',
    );

    expect(
      _builds,
      lessThanOrEqualTo(steps * columnCount),
      reason:
          'a one-row scroll must build one row of cells, not the window — the '
          'jump path must not leak into continuous scrolling',
    );
  });
}
