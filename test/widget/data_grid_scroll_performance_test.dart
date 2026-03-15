import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

class _Row extends DataGridRow {
  final String label;
  _Row({required double id, required this.label}) {
    this.id = id;
  }
}

/// A column whose [valueAccessor] records every [DataGridCell.build] call into
/// [counts] using the key '${row.id}_$id'. Because [valueAccessor] is invoked
/// inside [DataGridCell.build], [counts] precisely tracks per-cell rebuilds.
DataGridColumn<_Row> _trackCol({
  required int id,
  required double width,
  required Map<String, int> counts,
}) => DataGridColumn<_Row>(
  id: id,
  title: 'C$id',
  width: width,
  valueAccessor: (row) {
    final key = '${row.id}_$id';
    counts[key] = (counts[key] ?? 0) + 1;
    return row.label;
  },
);

DataGridController<_Row> _makeController({
  required int rowCount,
  required List<DataGridColumn<_Row>> columns,
}) => DataGridController<_Row>(
  initialColumns: columns,
  initialRows: List.generate(
    rowCount,
    (i) => _Row(id: i.toDouble(), label: 'R$i'),
  ),
);

Widget _grid(
  DataGridController<_Row> controller, {
  double rowHeight = 40.0,
  double cacheExtent = 0,
}) => MaterialApp(
  home: Scaffold(
    body: DataGrid<_Row>(
      controller: controller,
      rowHeight: rowHeight,
      // cacheExtent: 0 → no pre-render buffer → only visible cells are built.
      // In debug mode DataGrid clamps cacheExtent to min(value, 500), so 0 stays 0.
      cacheExtent: cacheExtent,
    ),
  ),
);

/// Same as [_grid] but with an externally-supplied [GridScrollController] so
/// tests can drive scroll position via [jumpTo] for single-frame measurements.
Widget _gridWithScrollCtrl(
  DataGridController<_Row> controller,
  GridScrollController scrollCtrl, {
  double rowHeight = 40.0,
  double cacheExtent = 0,
}) => MaterialApp(
  home: Scaffold(
    body: DataGrid<_Row>(
      controller: controller,
      scrollController: scrollCtrl,
      rowHeight: rowHeight,
      cacheExtent: cacheExtent,
    ),
  ),
);

/// Returns the p-th percentile value (0–100) from a sorted list.
double _percentile(List<int> sorted, int p) {
  final idx = ((p / 100) * (sorted.length - 1)).round();
  return sorted[idx] / 1000.0;
}

/// Pretty-prints a benchmark summary line.
void _printBench(
  String label, {
  required int steps,
  required List<int> stepUsecs,
  required int visibleCells,
  required int newCellsLastStep,
}) {
  final sorted = List<int>.from(stepUsecs)..sort();
  final avg = stepUsecs.fold(0, (a, b) => a + b) / steps / 1000;
  final min = sorted.first / 1000;
  final max = sorted.last / 1000;
  final p95 = _percentile(sorted, 95);
  debugPrint(
    '[bench] $label\n'
    '  steps=$steps  visible_cells=$visibleCells  new_cells/step=$newCellsLastStep\n'
    '  avg=${avg.toStringAsFixed(2)}ms  '
    'min=${min.toStringAsFixed(2)}ms  '
    'max=${max.toStringAsFixed(2)}ms  '
    'p95=${p95.toStringAsFixed(2)}ms',
  );
}

/// Settles all async state (event processing + frame pump).
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Constants derived from defaults:
//   DataGridDimensions.headerHeight = 48
//   viewport 800×600 → body = 600-48 = 552 px
//   rowHeight = 40  → visible rows = floor(552/40)+1 = 14+1 = 15
// ---------------------------------------------------------------------------

void main() {
  group('DataGrid scroll performance', () {
    // -----------------------------------------------------------------------
    // 1. Initial render
    // -----------------------------------------------------------------------

    testWidgets(
      'initial render: builds only viewport-visible cells from a 200×6 grid',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final counts = <String, int>{};
        const colCount = 60;
        const totalRows = 200;

        final controller = _makeController(
          rowCount: totalRows,
          columns: List.generate(
            colCount,
            (i) => _trackCol(id: i + 1, width: 120, counts: counts),
          ),
        );
        addTearDown(controller.dispose);

        final sw = Stopwatch()..start();
        await tester.pumpWidget(_grid(controller));
        await tester.pumpAndSettle();
        sw.stop();

        final totalBuilt = counts.values.fold(0, (a, b) => a + b);

        // Viewport body ≈ 552 px tall / 40 px per row ≈ 14 visible rows.
        // Only the visible columns fit the 800 px viewport, so far fewer than
        // totalRows × colCount cells are built. The StreamBuilder fires twice
        // (initial state + post-frame ViewportResizeEvent), so each cell may
        // build up to 2×. Upper bound = 20 rows × colCount (generous 2× visible).
        expect(
          totalBuilt,
          greaterThan(0),
          reason: 'Some cells must be visible and built',
        );
        expect(
          totalBuilt,
          lessThanOrEqualTo(20 * colCount),
          reason:
              'Only viewport-visible cells should build. '
              'Got $totalBuilt / ${totalRows * colCount} possible cells.',
        );

        // Each visible cell may build at most a small fixed number of times
        // (not proportional to the total dataset size).
        for (final entry in counts.entries) {
          expect(
            entry.value,
            lessThanOrEqualTo(3),
            reason:
                'Cell ${entry.key} built ${entry.value}× at initial render (expected ≤ 3)',
          );
        }

        debugPrint(
          '[perf] initial 200×$colCount: $totalBuilt cells built '
          'in ${sw.elapsedMilliseconds} ms  '
          '(${totalRows * colCount - totalBuilt} cells skipped by virtualization)',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 2. Vertical scroll — zero stale rebuilds
    // -----------------------------------------------------------------------

    testWidgets('vertical scroll: cells visible before scroll do not rebuild', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final counts = <String, int>{};
      const colCount = 40;
      const scrollRows = 5;
      const rowHeight = 40.0;

      final controller = _makeController(
        rowCount: 100,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: 180, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
      await tester.pumpAndSettle();

      // Snapshot which cells exist after initial render.
      final before = Map<String, int>.from(counts);

      // Scroll down by 5 rows.
      final sw = Stopwatch()..start();
      await tester.drag(
        find.byType(DataGrid<_Row>),
        const Offset(0, -scrollRows * rowHeight),
      );
      await tester.pumpAndSettle();
      sw.stop();

      int staleRebuilds = 0;
      int newCellBuilds = 0;

      for (final entry in counts.entries) {
        final delta = entry.value - (before[entry.key] ?? 0);
        if (delta <= 0) continue;
        if (before.containsKey(entry.key)) {
          staleRebuilds += delta;
        } else {
          newCellBuilds += delta;
        }
      }

      // Core assertion: no already-visible cell should rebuild during a pure scroll.
      expect(
        staleRebuilds,
        0,
        reason:
            'Already-visible cells must not rebuild on a pure vertical scroll. '
            'Got $staleRebuilds unexpected rebuilds.',
      );

      // Sanity: new cells entering from the bottom are built.
      expect(
        newCellBuilds,
        greaterThan(0),
        reason: 'New rows must enter the viewport',
      );
      expect(
        newCellBuilds,
        lessThanOrEqualTo(scrollRows * colCount),
        reason:
            'At most $scrollRows new rows × $colCount cols = '
            '${scrollRows * colCount} new cell builds. Got $newCellBuilds.',
      );

      debugPrint(
        '[perf] vertical scroll $scrollRows rows: '
        'stale=$staleRebuilds, new=$newCellBuilds, ${sw.elapsedMilliseconds} ms',
      );
    });

    // -----------------------------------------------------------------------
    // 3. Horizontal scroll — zero stale rebuilds
    // -----------------------------------------------------------------------

    testWidgets('horizontal scroll: cells visible before scroll do not rebuild', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final counts = <String, int>{};
      // 8 cols × 150 px = 1200 px total. Viewport 600 px → ~4 visible cols.
      const colCount = 80;
      const colWidth = 150.0;
      const scrollCols = 2;
      const rowHeight = 40.0;

      final controller = _makeController(
        rowCount: 20,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
      await tester.pumpAndSettle();

      final before = Map<String, int>.from(counts);

      final sw = Stopwatch()..start();
      await tester.drag(
        find.byType(DataGrid<_Row>),
        const Offset(-scrollCols * colWidth, 0),
      );
      await tester.pumpAndSettle();
      sw.stop();

      int staleRebuilds = 0;
      int newCellBuilds = 0;

      for (final entry in counts.entries) {
        final delta = entry.value - (before[entry.key] ?? 0);
        if (delta <= 0) continue;
        if (before.containsKey(entry.key)) {
          staleRebuilds += delta;
        } else {
          newCellBuilds += delta;
        }
      }

      expect(
        staleRebuilds,
        0,
        reason:
            'Already-visible cells must not rebuild on a pure horizontal scroll. '
            'Got $staleRebuilds unexpected rebuilds.',
      );

      expect(
        newCellBuilds,
        greaterThan(0),
        reason: 'New columns must enter the viewport',
      );

      // viewport 400 px - header 48 px = 352 px body / 40 px = ~9 visible rows
      const maxVisibleRows = 12; // generous bound
      expect(
        newCellBuilds,
        lessThanOrEqualTo(scrollCols * maxVisibleRows),
        reason:
            'At most $scrollCols new cols × $maxVisibleRows visible rows = '
            '${scrollCols * maxVisibleRows} new builds. Got $newCellBuilds.',
      );

      debugPrint(
        '[perf] horizontal scroll $scrollCols cols: '
        'stale=$staleRebuilds, new=$newCellBuilds, ${sw.elapsedMilliseconds} ms',
      );
    });

    // -----------------------------------------------------------------------
    // 4. Continuous vertical scroll — per-step build count stays bounded
    // -----------------------------------------------------------------------

    testWidgets(
      'continuous vertical scroll: per-step rebuild count is bounded by row width',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final counts = <String, int>{};
        const colCount = 5;
        const rowHeight = 40.0;
        const scrollSteps = 20;

        final controller = _makeController(
          rowCount: 200,
          columns: List.generate(
            colCount,
            (i) => _trackCol(id: i + 1, width: 150, counts: counts),
          ),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
        await tester.pumpAndSettle();
        counts.clear(); // only measure scroll-phase builds

        final stepBuilds = <int>[];
        final sw = Stopwatch()..start();

        for (int step = 0; step < scrollSteps; step++) {
          final beforeTotal = counts.values.fold(0, (a, b) => a + b);
          await tester.drag(
            find.byType(DataGrid<_Row>),
            const Offset(0, -rowHeight), // 1 row down
          );
          await tester.pump();
          final afterTotal = counts.values.fold(0, (a, b) => a + b);
          stepBuilds.add(afterTotal - beforeTotal);
        }

        await tester.pumpAndSettle();
        sw.stop();

        final totalBuilds = counts.values.fold(0, (a, b) => a + b);
        final maxPerStep = stepBuilds.reduce((a, b) => a > b ? a : b);
        final avgPerStep = (totalBuilds / scrollSteps).roundToDouble();

        // Each 1-row scroll reveals at most 1 new row → at most colCount new builds.
        // Allow 2× headroom for edge rows that straddle the viewport boundary.
        expect(
          maxPerStep,
          lessThanOrEqualTo(colCount * 2),
          reason:
              'Scrolling 1 row should build at most $colCount cells '
              '(1 new row × $colCount cols). Max observed: $maxPerStep.',
        );

        // Total must be O(steps × cols), not O(totalRows × cols).
        expect(
          totalBuilds,
          lessThanOrEqualTo(scrollSteps * colCount * 2),
          reason:
              '$scrollSteps scroll steps should total ≤ ${scrollSteps * colCount * 2} builds. '
              'Got $totalBuilds.',
        );

        debugPrint(
          '[perf] $scrollSteps × 1-row scroll, $colCount cols: '
          'total=$totalBuilds  max/step=$maxPerStep  avg/step=$avgPerStep  '
          '${sw.elapsedMilliseconds} ms total  '
          '(${(sw.elapsedMilliseconds / scrollSteps).toStringAsFixed(1)} ms/step)',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 5. Combined vertical + horizontal scroll — no cross-axis stale rebuilds
    // -----------------------------------------------------------------------

    testWidgets(
      'vertical then horizontal scroll: no stale rebuilds in either axis',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final counts = <String, int>{};
        const colCount = 70;
        const rowHeight = 40.0;
        // Wide columns so horizontal scroll is needed (7 × 180 = 1260 px > 800 px).
        const colWidth = 180.0;
        const scrollDownRows = 4;
        const scrollRightCols = 2;

        final controller = _makeController(
          rowCount: 60,
          columns: List.generate(
            colCount,
            (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
          ),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
        await tester.pumpAndSettle();

        // --- Phase 1: scroll down ---
        final afterInit = Map<String, int>.from(counts);

        await tester.drag(
          find.byType(DataGrid<_Row>),
          Offset(0, -scrollDownRows * rowHeight),
        );
        await tester.pumpAndSettle();

        int vertStale = 0;
        int vertNew = 0;
        for (final entry in counts.entries) {
          final delta = entry.value - (afterInit[entry.key] ?? 0);
          if (delta <= 0) continue;
          afterInit.containsKey(entry.key) ? vertStale++ : vertNew++;
        }

        expect(
          vertStale,
          0,
          reason: 'No stale rebuilds during vertical scroll. Got $vertStale.',
        );
        expect(
          vertNew,
          greaterThan(0),
          reason: 'New rows must enter on vertical scroll',
        );

        // --- Phase 2: scroll right ---
        final afterVert = Map<String, int>.from(counts);

        await tester.drag(
          find.byType(DataGrid<_Row>),
          Offset(-scrollRightCols * colWidth, 0),
        );
        await tester.pumpAndSettle();

        int horizStale = 0;
        int horizNew = 0;
        for (final entry in counts.entries) {
          final delta = entry.value - (afterVert[entry.key] ?? 0);
          if (delta <= 0) continue;
          afterVert.containsKey(entry.key) ? horizStale++ : horizNew++;
        }

        expect(
          horizStale,
          0,
          reason:
              'No stale rebuilds during horizontal scroll. Got $horizStale.',
        );
        expect(
          horizNew,
          greaterThan(0),
          reason: 'New columns must enter on horizontal scroll',
        );

        debugPrint(
          '[perf] combined scroll ↓$scrollDownRows rows →$scrollRightCols cols: '
          'vert stale=$vertStale new=$vertNew | horiz stale=$horizStale new=$horizNew',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 6. Selection in large grid — documents rebuild scope
    // -----------------------------------------------------------------------

    testWidgets('selection: tracks how many cells rebuild across a 100×4 grid', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final counts = <String, int>{};
      const colCount = 40;
      const rowHeight = 40.0;

      final controller = _makeController(
        rowCount: 100,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: 180, counts: counts),
        ),
      );
      addTearDown(controller.dispose);
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
      await tester.pumpAndSettle();

      final visibleCellCount = counts.length;
      expect(visibleCellCount, greaterThan(0));

      // --- Select row 3 ---
      counts.clear();

      controller.addEvent(SelectRowEvent(rowId: 3));
      await _settle(tester);

      final selectBuilds = counts.values.fold(0, (a, b) => a + b);

      // Lower bound: at least the visible cells of the selected row must rebuild.
      expect(
        selectBuilds,
        greaterThan(0),
        reason: 'At least the selected row cells must rebuild',
      );
      // Upper bound: InheritedModel notifies all visible cells subscribed to
      // the selection aspect. The StreamBuilder top-down rebuild adds another
      // cycle, so builds may be up to 2× visibleCellCount. Allow 3× as a
      // generous bound to document that it is bounded per visible cell.
      expect(
        selectBuilds,
        lessThanOrEqualTo(visibleCellCount * 3),
        reason:
            'Selection should rebuild at most ~2× visible cells ($visibleCellCount). '
            'Got $selectBuilds.',
      );

      // --- Switch selection row 3 → row 7 ---
      counts.clear();

      controller.addEvent(SelectRowEvent(rowId: 7));
      await _settle(tester);

      final switchBuilds = counts.values.fold(0, (a, b) => a + b);

      expect(
        switchBuilds,
        greaterThan(0),
        reason: 'At least the newly-selected row cells must rebuild',
      );
      expect(
        switchBuilds,
        lessThanOrEqualTo(visibleCellCount * 3),
        reason:
            'Switch-selection should rebuild at most ~2× visible cells ($visibleCellCount). '
            'Got $switchBuilds.',
      );

      debugPrint(
        '[perf] selection in 100×$colCount grid '
        '($visibleCellCount visible cells): '
        'select=$selectBuilds, switch=$switchBuilds',
      );
    });

    // -----------------------------------------------------------------------
    // 7. Scroll after selection — scroll does not compound selection rebuilds
    // -----------------------------------------------------------------------

    testWidgets(
      'scroll after selection: no already-visible cells rebuild during subsequent scroll',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final counts = <String, int>{};
        const colCount = 30;
        const rowHeight = 40.0;
        const scrollRows = 4;

        final controller = _makeController(
          rowCount: 80,
          columns: List.generate(
            colCount,
            (i) => _trackCol(id: i + 1, width: 240, counts: counts),
          ),
        );
        addTearDown(controller.dispose);
        controller.setSelectionMode(SelectionMode.multiple);

        await tester.pumpWidget(_grid(controller, rowHeight: rowHeight));
        await tester.pumpAndSettle();

        // Select a row, then settle.
        controller.addEvent(SelectRowEvent(rowId: 2));
        await _settle(tester);

        // Now snapshot and measure the scroll-only phase.
        final afterSelect = Map<String, int>.from(counts);

        await tester.drag(
          find.byType(DataGrid<_Row>),
          Offset(0, -scrollRows * rowHeight),
        );
        await tester.pumpAndSettle();

        int staleRebuilds = 0;
        int newBuilds = 0;

        for (final entry in counts.entries) {
          final delta = entry.value - (afterSelect[entry.key] ?? 0);
          if (delta <= 0) continue;
          afterSelect.containsKey(entry.key) ? staleRebuilds++ : newBuilds++;
        }

        expect(
          staleRebuilds,
          0,
          reason:
              'Cells visible after selection must not rebuild during a subsequent scroll. '
              'Got $staleRebuilds stale rebuilds.',
        );
        expect(
          newBuilds,
          greaterThan(0),
          reason: 'New rows must enter on scroll',
        );

        debugPrint(
          '[perf] scroll after selection ↓$scrollRows rows: '
          'stale=$staleRebuilds, new=$newBuilds',
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // layoutChildSequence benchmarks — FHD viewport, 1 000 rows, 40-60 columns.
  //
  // Each step uses jumpTo + single pump() so exactly ONE layout pass runs per
  // measurement, isolating layoutChildSequence cost from gesture / settle overhead.
  //
  // Viewport geometry (FHD 1920×1080, rowHeight=40, headerHeight=48):
  //   body height  = 1080 - 48 = 1032 px
  //   visible rows = ceil(1032/40)+1 = 27
  //   visible cols (colWidth=100) = ceil(1920/100) = 19
  //   visible cells ≈ 27 × 19 = 513
  // ---------------------------------------------------------------------------

  group('layoutChildSequence benchmarks (FHD, 1 000 rows)', () {
    // -------------------------------------------------------------------------
    // B1. Vertical scroll — 100 steps of exactly 1 row each
    // -------------------------------------------------------------------------

    testWidgets('B1: 1000×40 cols — 100 vertical steps (1 row each)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const rowCount = 1000;
      const colCount = 40;
      const colWidth = 100.0;
      const rowHeight = 40.0;
      const steps = 100;

      final counts = <String, int>{};
      final scrollCtrl = GridScrollController();
      addTearDown(scrollCtrl.dispose);

      final controller = _makeController(
        rowCount: rowCount,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _gridWithScrollCtrl(controller, scrollCtrl, rowHeight: rowHeight),
      );
      await tester.pumpAndSettle();

      final visibleCells = counts.length;
      counts.clear();

      final stepUsecs = <int>[];
      int newCellsLastStep = 0;

      for (int step = 0; step < steps; step++) {
        counts.clear();
        final sw = Stopwatch()..start();
        scrollCtrl.verticalController.jumpTo((step + 1) * rowHeight);
        await tester.pump();
        sw.stop();
        stepUsecs.add(sw.elapsedMicroseconds);
        if (step == steps - 1) {
          newCellsLastStep = counts.values.fold(0, (a, b) => a + b);
        }
      }

      _printBench(
        'B1: 1000×$colCount vert scroll (1 row/step)',
        steps: steps,
        stepUsecs: stepUsecs,
        visibleCells: visibleCells,
        newCellsLastStep: newCellsLastStep,
      );
      // Benchmarks are observational — no hard assertion.
      // Check DevTools or the printed numbers for frame budget compliance.
    });

    // -------------------------------------------------------------------------
    // B2. Horizontal scroll — 50 steps of exactly 1 column each
    // -------------------------------------------------------------------------

    testWidgets('B2: 1000×60 cols — 50 horizontal steps (1 col each)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const rowCount = 1000;
      const colCount = 60;
      const colWidth =
          120.0; // 60 × 120 = 7200px total, scroll 7200-1920=5280px
      const rowHeight = 40.0;
      const steps = 50;

      final counts = <String, int>{};
      final scrollCtrl = GridScrollController();
      addTearDown(scrollCtrl.dispose);

      final controller = _makeController(
        rowCount: rowCount,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _gridWithScrollCtrl(controller, scrollCtrl, rowHeight: rowHeight),
      );
      await tester.pumpAndSettle();

      final visibleCells = counts.length;
      counts.clear();

      final stepUsecs = <int>[];
      int newCellsLastStep = 0;

      for (int step = 0; step < steps; step++) {
        counts.clear();
        final sw = Stopwatch()..start();
        scrollCtrl.horizontalController.jumpTo((step + 1) * colWidth);
        await tester.pump();
        sw.stop();
        stepUsecs.add(sw.elapsedMicroseconds);
        if (step == steps - 1) {
          newCellsLastStep = counts.values.fold(0, (a, b) => a + b);
        }
      }

      _printBench(
        'B2: 1000×$colCount horiz scroll (1 col/step)',
        steps: steps,
        stepUsecs: stepUsecs,
        visibleCells: visibleCells,
        newCellsLastStep: newCellsLastStep,
      );
    });

    // -------------------------------------------------------------------------
    // B3. Combined vertical + horizontal — 200 steps alternating axes
    // -------------------------------------------------------------------------

    testWidgets('B3: 1000×50 cols — 200 mixed-axis steps', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const rowCount = 1000;
      const colCount = 50;
      const colWidth = 120.0;
      const rowHeight = 40.0;
      const steps = 200;

      final counts = <String, int>{};
      final scrollCtrl = GridScrollController();
      addTearDown(scrollCtrl.dispose);

      final controller = _makeController(
        rowCount: rowCount,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _gridWithScrollCtrl(controller, scrollCtrl, rowHeight: rowHeight),
      );
      await tester.pumpAndSettle();

      final visibleCells = counts.length;
      counts.clear();

      final vertUsecs = <int>[];
      final horizUsecs = <int>[];

      for (int step = 0; step < steps; step++) {
        counts.clear();
        final sw = Stopwatch()..start();
        if (step.isEven) {
          scrollCtrl.verticalController.jumpTo((step ~/ 2 + 1) * rowHeight);
        } else {
          scrollCtrl.horizontalController.jumpTo((step ~/ 2 + 1) * colWidth);
        }
        await tester.pump();
        sw.stop();
        (step.isEven ? vertUsecs : horizUsecs).add(sw.elapsedMicroseconds);
      }

      _printBench(
        'B3: 1000×$colCount vert (${vertUsecs.length} steps)',
        steps: vertUsecs.length,
        stepUsecs: vertUsecs,
        visibleCells: visibleCells,
        newCellsLastStep: 0,
      );
      _printBench(
        'B3: 1000×$colCount horiz (${horizUsecs.length} steps)',
        steps: horizUsecs.length,
        stepUsecs: horizUsecs,
        visibleCells: visibleCells,
        newCellsLastStep: 0,
      );
    });

    // -------------------------------------------------------------------------
    // B4. High column count (80 cols) — tests horizontal layout cost
    // -------------------------------------------------------------------------

    testWidgets('B4: 1000×80 cols — 100 vertical steps (stress test)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const rowCount = 1000;
      const colCount = 80;
      const colWidth = 80.0; // 80 × 80 = 6400px total
      const rowHeight = 36.0; // slightly smaller → more visible rows
      const steps = 100;

      // body = 1080-48 = 1032, rows = ceil(1032/36)+1 = 30
      // cols visible = ceil(1920/80) = 24
      // visible cells ≈ 30 × 24 = 720

      final counts = <String, int>{};
      final scrollCtrl = GridScrollController();
      addTearDown(scrollCtrl.dispose);

      final controller = _makeController(
        rowCount: rowCount,
        columns: List.generate(
          colCount,
          (i) => _trackCol(id: i + 1, width: colWidth, counts: counts),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _gridWithScrollCtrl(controller, scrollCtrl, rowHeight: rowHeight),
      );
      await tester.pumpAndSettle();

      final visibleCells = counts.length;
      counts.clear();

      final stepUsecs = <int>[];
      int newCellsLastStep = 0;

      for (int step = 0; step < steps; step++) {
        counts.clear();
        final sw = Stopwatch()..start();
        scrollCtrl.verticalController.jumpTo((step + 1) * rowHeight);
        await tester.pump();
        sw.stop();
        stepUsecs.add(sw.elapsedMicroseconds);
        if (step == steps - 1) {
          newCellsLastStep = counts.values.fold(0, (a, b) => a + b);
        }
      }

      _printBench(
        'B4: 1000×$colCount vert scroll (stress)',
        steps: steps,
        stepUsecs: stepUsecs,
        visibleCells: visibleCells,
        newCellsLastStep: newCellsLastStep,
      );
    });
  });
}
