# AGENTS.md

Agent-facing notes for working in this repo. For consumer-facing API docs, usage examples, full event reference, theming, troubleshooting, and roadmap, see [README.md](README.md) — this file intentionally doesn't duplicate that.

## What this is

`flutter_data_grid` — a virtualized, reactive Flutter **package** (not an app) published to pub.dev, providing a high-performance data grid widget with sorting, filtering, cell editing, selection, pinning, and pagination. There's no monorepo tooling (no Melos): it's a single package with an `example/` subproject that depends on it via `path: ../`.

## Structure

`lib/data_grid.dart` is the single public export barrel — anything meant to be consumer-facing must be exported there. `lib/` is organized by concern:

- `controllers/` — `DataGridController` (main state controller, RxDart-based), `grid_scroll_controller.dart`
- `models/data/` — `column.dart`, `row.dart`
- `models/state/` — `grid_state.dart` (Freezed — requires codegen after edits)
- `models/enums/`, `models/events/` — one file per event category (data/sort/filter/selection/edit/keyboard/pagination)
- `delegates/` — pluggable `sort_delegate.dart`, `filter_delegate.dart`
- `interceptors/` — `data_grid_interceptor.dart` base + logging/validation interceptors
- `theme/` — `data_grid_theme.dart`, `data_grid_theme_data.dart`
- `utils/` — `data_indexer.dart`, `isolate_sort.dart`, `isolate_filter.dart` (background isolate processing for large datasets)
- `widgets/` — main widgets plus `cells/`, `custom_layout/` (quadrant-based virtualized rendering: pinned vs. unpinned columns via `CustomMultiChildLayout`), `filters/`, `overlays/`, `scroll/`, `viewport/`

## Architecture

RxDart-driven `DataGridController` + an event-driven model (data/sort/filter/selection/edit/pagination/keyboard events) that widgets react to. Rendering is virtualized via a `CustomMultiChildLayout`-based body split into pinned and unpinned column quadrants for independent horizontal scrolling. `grid_state.dart` uses Freezed for immutable state modeling. See README's "Architecture" and "Project Structure" sections for the full diagram.

## Rendering pipeline & optimizations

The body ([lib/widgets/custom_layout/custom_layout_grid_body.dart](lib/widgets/custom_layout/custom_layout_grid_body.dart)) is a `Stack` inside a `LayoutBuilder`: `GridUnpinnedQuadrant` fills the area, `GridPinnedQuadrant` overlays the frozen columns on the left, plus scrollbars and the drag-select overlay. Each quadrant is its own `StatefulWidget` driving its own `CustomMultiChildLayout` — this split is what lets pinned and unpinned columns scroll independently without repainting each other. This scheme replaced an earlier `TwoDimensionalScrollable`-based renderer (see README's Migration Guide, v0.0.16→v0.0.17) specifically for the optimizations below.

**Two-layer scroll updates — the central perf trick.** Scroll position lives in plain `ValueNotifier<double>` (`_hOffset`/`_vOffset`, owned by `_GridBodyScrollMixin`, one of the sanctioned mutable-state exceptions above), not in Freezed state — a state update per pointer-move frame would be far too expensive. Each quadrant reacts to offset changes on two separate layers ([grid_unpinned_quadrant.dart](lib/widgets/custom_layout/grid_unpinned_quadrant.dart), [grid_pinned_quadrant.dart](lib/widgets/custom_layout/grid_pinned_quadrant.dart)):
- **Widget layer** — the quadrant's offset listener calls `setState` *only* when the visible row/column index range actually changes (a cell crosses into/out of the viewport+buffer). Most scroll frames don't cross that boundary, so most frames call `setState` zero times.
- **RenderObject layer** — `GridLayoutDelegate` ([grid_layout_delegate.dart](lib/widgets/custom_layout/grid_layout_delegate.dart)) is constructed with `relayout: Listenable.merge([hOffset, vOffset])`, so *every* offset change calls `markNeedsLayout()` directly on the render object, bypassing the widget tree entirely. `performLayout` derives each cell's rect itself from two scroll-independent inputs: `columnSpans` (x/width, one entry per *column*, not per cell) and `row * rowHeight` (y/height), subtracting the current offset to get viewport space — so repositioning during a scroll never touches `build()`.

  **Don't precompute cell geometry in the widget layer.** An earlier version had the quadrants bake absolute per-cell `Rect`s into a `contentRects` map; that forced a widget-side rebuild to republish the map whenever anything about the geometry moved. Keeping x/y resolution inside `performLayout` is what keeps a scroll frame a pure `markNeedsLayout`.

**Cell widget-instance caching.** Each quadrant keeps a `Map<CellLayoutId, Widget> _cellCache`. When the visible range does shift and a rebuild is needed, cells that carry over into the new range are reused as the *identical* `LayoutId`/`LayoutGridCell` instance rather than being reconstructed — Flutter's `child.widget == newWidget` identity check then skips `build()` for that element completely. Only genuinely new cells (freshly scrolled into view) actually build.

**Jump frames key cells by slot, not by row — the reconciliation key is not the layout id.** A `LayoutId`'s `id` is what `GridLayoutDelegate` resolves geometry from and is always the absolute `CellLayoutId(row, column)`; its `key` decides which existing *element* Flutter matches the widget to, and the two are chosen independently (`_buildCell` in [grid_unpinned_quadrant.dart](lib/widgets/custom_layout/grid_unpinned_quadrant.dart)). While scrolling continuously the key is the absolute cell identity, which is what makes the cache above work. But dragging the scrollbar thumb over a large grid is *discontinuous* — with a ~500px track over 100k rows, 2px of thumb is ~390 rows — so every drag frame lands on a window sharing nothing with the last one, no absolute key matches, and the entire viewport is deactivated and re-inflated: new `State` objects, `RenderObject`s and gesture recognizers for every cell, every frame. That is what made thumb-dragging lag while wheel-scrolling stayed smooth.

Each quadrant therefore detects a jump (`|Δ vOffset| ≥ viewportHeight`) and on those frames (a) skips the cache-extent buffer, since nothing in it survives to the next frame — at the default extent that's 31 rows built to show 13 — and (b) keys cells by **viewport slot**, so the keys match the previous frame's and Flutter *updates* the elements instead of rebuilding them from scratch. `DataGridCell.didUpdateWidget` already handles being re-pointed at a different row (it re-subscribes and keeps `_cellWidget`'s identity), and a `const` leaf under the column's `cellWidget` is skipped outright. Measured on a 20-frame jump over 100k×6: builds 3720 → 1560, element inflations 3720 → **0**, with continuous-scroll costs unchanged. `test/widget/scroll_jump_performance_test.dart` guards both halves; `test/widget/cell_value_freshness_test.dart` guards that a reused element still shows its new row.

**Row/column virtualization windowing.** `_computeRowRange`/`_computeRange` derive the visible index range from `scrollOffset ÷ rowHeight` (and cumulative column widths for the unpinned quadrant's horizontal axis), padded by `cacheExtent` (clamped to 500px in debug mode — `kDebugMode` check — to keep hot-reload/debug builds fast; uncapped in release). Only cells inside that window are ever built, regardless of total row/column count — this is what makes 100k-row grids viable (see the live demo).

**Selective rebuild scoping via `InheritedModel`.** `DataGridStateScope` ([lib/widgets/data_grid_inherited.dart](lib/widgets/data_grid_inherited.dart)) extends `InheritedModel<DataGridAspect>` with aspects `columns`/`data`/`selection`/`edit`/`sort`/`filter`/`pagination`/`loading`. Widgets call `context.dataGridState<T>({DataGridAspect.data, ...})` to depend on only the slices they use; `updateShouldNotifyDependent` diffs just those slices, so e.g. a cell rebuilds on `data` changes but not on `sort`/`pagination` changes. `DataGridControllerScope` is a second, separate `InheritedWidget` carrying the controller/scroll-controller/focus-node references — these rarely change, so widgets that only need `context.dataGridController<T>()` never rebuild on state updates at all. When adding a new piece of state that widgets will read, add it as a `DataGridAspect` here rather than making everything depend on the whole state.

**Per-cell rebuild isolation via `CellScope`.** Column authors pass a `cellWidget` (ideally `const`) to `DataGridColumn`; `CellScope` ([lib/widgets/cells/cell_scope.dart](lib/widgets/cells/cell_scope.dart)) is an `InheritedWidget` injecting row/column/selection/value data beneath it. Because the `const` cell widget itself never changes, Flutter skips diffing its subtree on parent rebuilds — only descendants that actually call `CellScope.of<T>(context)` re-evaluate when the injected data changes. Prefer this over passing data through constructor parameters for custom cell widgets.

**Cell-edit fast path: mutate the row, notify by callback, not by state replacement.** `UpdateCellEvent` and `CommitCellEditEvent` ([lib/models/events/data_events.dart](lib/models/events/data_events.dart), [lib/models/events/edit_events.dart](lib/models/events/edit_events.dart)) write the new value via `column.cellValueSetter!(row, value)` — mutating the existing `DataGridRow` object in place — instead of building a new row and doing an immutable `rowsById` replace (`state.copyWith(rowsById: {...})`). This is deliberate, not an oversight: `rowsById`/`displayOrder` stay `identical()` to their previous value, so `DataGridAspect.data` doesn't fire on `DataGridStateScope`, and — critically — `GridPinnedQuadrant`/`GridUnpinnedQuadrant`'s `didUpdateWidget` checks (`!identical(old.rowsById, widget.rowsById)`) don't see a change, so their `_cellCache` is *not* cleared and every other visible cell keeps its cached widget instance. Only the edited cell needs to know. That's done via a narrow side channel: the event calls `context.notifyCellValueChanged` → `DataGridController._cellValueChanges` (`PublishSubject<CellValueChange>`) → the `cellValueChanges` stream. `DataGridCell` ([lib/widgets/cells/data_grid_cell.dart](lib/widgets/cells/data_grid_cell.dart)) subscribes to that stream filtered by **`change.affectsRow(rowId)`** and calls a local `setState(() {})` on a match — no data flows through the payload; the cell just knows to re-read `column.valueAccessor(widget.row)` on its next build. Net effect: editing a cell in a 100k-row grid rebuilds that one row's cells, not a `rowsById` copy or any virtualization-window recomputation.

  **Notification is row-scoped; precision comes from a per-cell value diff — keep both halves.** Every column's `valueAccessor` is handed the *whole row*, so a `cellValueSetter` that touches anything beyond its own field changes what other columns render: the example's Quantity setter calls `row.updateTotal()`, and the Total column reads `row.total`. Filtering the stream on `affectsCell` notified only the edited cell, leaving every derived cell stale until something unrelated (selecting the row, scrolling it out and back) happened to rebuild it. But widening the filter alone is the wrong trade — that rebuilds all 60 cells of a 60-column row for a one-field edit. So `affectsRow` only selects *candidates*, and `_shouldRefreshValue` then re-runs that cell's own accessor and calls `setState` only if the rendered value actually moved. Accessors are pure getters that already run on every build, so the extra call is far cheaper than the rebuild it avoids — and unlike a `dependsOn`-style declaration on the column, it cannot go stale because someone forgot to update it. An edit still costs one cell rebuild in the common case; a derived column costs one more.

  Two things the diff can't see, both of which rebuild unconditionally: a column with **no `valueAccessor`** (a custom `cellWidget` may read arbitrary fields off `CellScope.row`), and **`RefreshCellsEvent`** / `controller.refreshCells(rowIds:, columnIds:)` — the explicit escape hatch for a row mutated by application code outside the edit path, so nothing was ever emitted. That event produces no state (`apply` returns `null`); it only pushes `CellValueChange`s with `source: refresh`, so a forced repaint still costs no state emission and no virtualization work. `test/widget/cell_value_freshness_test.dart` and `data_grid_rebuild_test.dart` guard all of this. If you add a new "write a value into the grid" event, follow this same mutate + `notifyCellValueChanged` pattern rather than replacing `rowsById`.

**Never call `identical()` on a Freezed collection field.** `DataGridState.columns`, `rowsById` and `displayOrder` are Freezed collection getters, and Freezed re-wraps the backing collection in a **fresh** `EqualUnmodifiableListView`/`MapView` on *every access*:

```dart
Map<double, T> get rowsById {
  if (_rowsById is EqualUnmodifiableMapView) return _rowsById;
  return EqualUnmodifiableMapView(_rowsById);   // a new object, every call
}
```

So `identical(state.rowsById, state.rowsById)` is **false**. Every identity-based reuse check written against these getters silently always fires — that's what made the quadrants' `_cellCache` cold on every state emission, rebuilding the entire viewport for changes the cells didn't depend on. Those views *do* override `==` to compare their sources, which for a plain List/Map is identity, so **`==` is the correct O(1) "same underlying collection?" test**. `_DataGridState` latches each view once per build (`_syncStateViews` in [data_grid.dart](lib/widgets/data_grid.dart)) and passes the latched instance down through `DataGridStateScope`; read `context.dataGridRowsById<T>()` / `.dataGridEffectiveColumns<T>()` / `.dataGridDisplayRows<T>()` rather than reaching for `state.*` in the render path. Note this also means Freezed's generated `DataGridState ==` deep-compares all three — never use it on a hot path (see `_stateUnchanged`).

Two related rules for anything the quadrants receive: **derived lists must be memoized, and callbacks must be tear-offs.** `computeDisplayRows`, the effective-column list and the pinned/unpinned index split are all cached on their inputs, because the quadrants clear `_cellCache` when those lists change identity. Likewise `FullWidthRowBandLayer` clears its band cache when `bandBuilder`'s identity changes, so it takes a method tear-off (`_buildGroupBand`) — a closure literal would be a new object every build. `test/widget/state_emission_rebuild_test.dart` guards all of this: a state emission that changes nothing visible must rebuild **zero** cells.

**Row height is a single fixed scalar — deliberately.** Every row is `rowHeight` tall, so `row * rowHeight` resolves any row's y in O(1) and `visibleRowRange` ([grid_layout_delegate.dart](lib/widgets/custom_layout/grid_layout_delegate.dart)) is pure arithmetic. A content-measured `autoRowHeight` mode was built and then **removed**: making row height variable means a Fenwick-indexed offset table, a loose measurement layout pass per unmeasured row, a scroll-anchor correction when a row above the viewport resizes, and a `geometry` listenable threaded into every quadrant's `relayout` — and even with all measurement confined to the off-screen buffer it stayed materially more expensive than the fixed path. If it's ever revisited, note that `performLayout`'s tight `BoxConstraints` are what make each cell its own relayout boundary; the loose constraint a measurement pass needs silently gives that up, so an invalidation inside one cell dirties the whole quadrant.

The **header** is a different case and does still auto-size: `AutoHeaderHeight` ([auto_header_height.dart](lib/models/auto_header_height.dart)) is opt-in and cheap because the header is a single un-virtualized row — `RenderDataGridHeader` lays its cells out loose, takes the max, then lays them out tight at that height. The two-pass cost (`2 × columns` full subtree layouts) is memoized on the constraint width and `TextScaler`, invalidated by the column setters and by any `markNeedsLayout` arriving through a child; `textScaler` is plumbed in from the widget because a render object has no `MediaQuery` and tightly-laid-out header cells are relayout boundaries. The selection column deliberately renders `SizedBox.shrink()` rather than `expand()` — `expand` fills whatever it is given, so in the loose pass it would report `maxHeight` as the header's measured height (`test/widget/auto_header_height_selection_test.dart`).

**Isolate offloading for sort/filter.** `lib/utils/isolate_sort.dart` / `isolate_filter.dart` define top-level functions (required by `compute()`) that run off the UI thread via `DefaultSortDelegate`/`DefaultFilterDelegate` once row count exceeds `sortIsolateThreshold`/`filterIsolateThreshold` (both default `10000`, configurable on `DataGridController`). Below the threshold, sorting/filtering runs synchronously in-place — isolate spawn overhead isn't worth it for small datasets. `sortDebounce`/`filterDebounce` (defaults 300ms/500ms) additionally coalesce rapid changes (e.g. typing in a filter box) before a sort/filter pass runs at all.

## State management pattern — follow this for new features

This is the load-bearing convention in the codebase; match it rather than introducing a new state-management style.

**Controller = RxDart `BehaviorSubject` wrapping Freezed state.** `DataGridController` ([lib/controllers/data_grid_controller.dart](lib/controllers/data_grid_controller.dart)) is a plain class (not `ChangeNotifier`) holding `_stateSubject = BehaviorSubject<DataGridState<T>>.seeded(...)`. It exposes:
- `state` — sync getter for the current snapshot (`_stateSubject.value`)
- `state$` — the full stream
- narrower derived streams via `.map((s) => s.someSlice).distinct()` (e.g. `selection$`, `sort$`, `filter$`)
- public API methods that are thin wrappers dispatching a command, e.g. `void setPage(int page) => addEvent(SetPageEvent(page: page));`
- a `dispose()` that closes every subject/subscription it owns

`GridScrollController` ([lib/controllers/grid_scroll_controller.dart](lib/controllers/grid_scroll_controller.dart)) follows the same shape for scroll metrics. New controllers should look like these two.

**State = Freezed, one slice per concern, composed into `DataGridState`.** `grid_state.dart` defines `@freezed abstract class DataGridState<T> with _$DataGridState<T>` with a `const factory`, a `DataGridState._()` for derived getters, and a `DataGridState.initial()` factory. Sub-states (`SelectionState`, `SortState`, `FilterState`, `GroupState`, `EditState`, `PaginationState`) follow the same shape and compose into the top-level state. Transitions always go through `state.copyWith(...)` — never mutate a state object's fields directly. Adding a new slice means: a new `@freezed` class with its own `.initial()`, a field on `DataGridState`, and re-running codegen (see Dev commands).

**Behavior = `DataGridEvent` command objects, not controller methods with logic inline.** Each state transition is a class extending `DataGridEvent` ([lib/models/events/base_event.dart](lib/models/events/base_event.dart)) implementing `apply<T>(EventContext<T> context) → FutureOr<DataGridState<T>?>` — pure-ish, given the current `state` plus the collaborators in `EventContext` (delegates, `DataIndexer`, callback hooks), it returns the next state (or `null`/a `Future` for async work like debounced sort/filter). Events are grouped by domain into `lib/models/events/{data,sort,filter,selection,cell_selection,edit,keyboard,pagination,column,group}_events.dart`. The controller just does `addEvent(event)` → its internal `PublishSubject` → `_handleEvent` → `event.apply(...)` → `_updateStateWithInterceptors(...)`. When adding a feature, add an event class in the right domain file, not new logic inside `DataGridController`.

**Cross-cutting hooks = interceptors and delegates, not controller conditionals.** `DataGridInterceptor` ([lib/interceptors/data_grid_interceptor.dart](lib/interceptors/data_grid_interceptor.dart)) provides `onBeforeEvent`/`onBeforeStateUpdate`/`onAfterStateUpdate`/`onError` hooks, registered/removed at runtime. Swappable algorithms (sorting, filtering) are `SortDelegate`/`FilterDelegate` with `Default*Delegate` implementations that isolate-offload above a row-count threshold. Prefer one of these over special-casing behavior inside the controller or an event.

**Exception: mutable state, used deliberately and narrowly.** A few places break from Freezed/immutability on purpose — treat these as the sanctioned exception, not precedent for going mutable elsewhere:
- Bridging Flutter's own imperative APIs, e.g. `GridScrollController` wraps real `ScrollController`/`ScrollPosition` objects (framework-mandated, can't be immutable) while still projecting them out as reactive streams.
- Private, per-frame hot-path gesture/animation state scoped to a widget's `State`, e.g. `_GridBodyScrollMixin` ([lib/widgets/custom_layout/grid_body_scroll_mixin.dart](lib/widgets/custom_layout/grid_body_scroll_mixin.dart)) uses raw mutable fields and `ValueNotifier<double>` for drag/ballistic-scroll offsets — rebuilding a Freezed object every pointer-move frame would be wasteful, and this state never leaves the widget.
- Internal performance caches not exposed publicly, e.g. `DataIndexer` ([lib/utils/data_indexer.dart](lib/utils/data_indexer.dart)) holds a private mutable `Map<double, T> _data` so sort/filter don't have to rebuild from the immutable state each call.
- `DataGridRow` ([lib/models/data/row.dart](lib/models/data/row.dart)) itself is intentionally a plain mutable base class (`late double id`), since it's the consumer's own row model, not this package's internal state.
- Cell edits exploit that mutability on purpose: `UpdateCellEvent`/`CommitCellEditEvent` mutate the row via `column.cellValueSetter!(row, value)` in place rather than replacing it in `rowsById`, specifically to keep `rowsById`/`displayOrder` `identical()` and avoid invalidating the quadrants' cell caches on every keystroke-driven edit. See "Rendering pipeline & optimizations" above for the full mechanism (mutate + narrow `cellValueChanges` callback instead of a `DataGridAspect.data` state update).

  Use mutable state only for one of these reasons — bridging a mutable framework API, private per-frame widget-internal hot-path state, or an internal-only performance cache — and keep it private/unexported. Anything that's part of the public, reactive `DataGridState` snapshot stays Freezed and flows through the event/`copyWith` pattern above.

## Dev commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # required after editing any @freezed model (models/state/grid_state.dart)
flutter test                                                 # full suite: 140+ widget tests in test/widget/
cd example && flutter pub get && flutter run                 # run the example app
```

## Testing conventions

- Set `sortDebounce`/`filterDebounce: Duration.zero` on the controller/grid in tests to avoid timing-related flakiness.
- When asserting on state driven by async streams, wrap in `tester.runAsync` with a short delay.

## Example app & release/CI

- `example/` is a standalone Flutter app (`publish_to: 'none'`), used both for local manual testing and as the live demo (see README's Live Demo link).
- `.github/workflows/deploy_pages.yml` builds it with `flutter build web --release --wasm --base-href /data_grid/` and deploys to GitHub Pages on every push to `main`. Flag any change to the example's build config or base href — it affects this deploy.
- No automated pub.dev publish workflow — releases are manual. Bump `pubspec.yaml`'s `version` and update `CHANGELOG.md` before publishing (see README's Contributing section).

## Conventions

- Lint rules are just `package:flutter_lints/flutter.yaml` via `analysis_options.yaml` — no custom rules.
- Freezed is the only codegen in use; `mockito` is used for test mocks.
- Breaking API changes are documented in README's "Migration Guide" section — follow that precedent (old API → new API, with a short rationale) when introducing one.
