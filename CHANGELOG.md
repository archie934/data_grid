## 0.0.6

* Performance: Replaced AnimatedBuilder in header/filter rows with custom RenderObject (`RenderDataGridHeader`)
* Header and filter rows now use `markNeedsPaint()` on scroll instead of widget rebuilds
* Eliminated widget rebuilds during horizontal scrolling for smoother performance
* Added `DataGridHeaderViewport` widget for efficient header/filter rendering
* Added 8 new tests for header viewport with pinned/unpinned columns
* Fixed README image path
* Updated test count to 128 passing tests

## 0.0.5

* Performance: Refactored DataGridCell from StatefulWidget to StatelessWidget (StatefulWidget only used during editing)
* Performance: Removed nested StreamBuilders from cells - now using direct state access
* Performance: Added column caching in viewport renderer to avoid recalculating pinned/unpinned columns on every layout
* Performance: Added RepaintBoundary to grid body
* Performance: Removed scroll debounce timer from GridScrollController
* Added `cacheExtent` parameter to DataGrid for controlling pre-rendered content
* Added smooth scroll physics for better horizontal scrolling momentum
* Simplified DataGridCheckboxCell by removing StreamBuilder
* Removed unused `rowRenderer` parameter from DataGrid
* Removed unused `default_row_renderer.dart` file
* Fixed conditional updateRenderObject to avoid unnecessary updates
* Fixed scroll handling - viewport now handles scroll internally via ViewportOffset

## 0.0.4

* Removed unnecessary import in data_grid_controller.dart

## 0.0.3

* Added pagination support with client-side and server-side modes
* New `DataGridPagination` widget with page navigation and page size selector
* Pagination controller methods: `enablePagination()`, `setServerSidePagination()`, `setPage()`, `setPageSize()`, `nextPage()`, `previousPage()`, `firstPage()`, `lastPage()`
* Server-side pagination with `onLoadPage` and `onGetTotalCount` callbacks
* Loading overlay during async operations
* New `SetTotalItemsEvent` for server-side pagination total count

## 0.0.2

* Updated dependencies to latest versions
* Added dartdoc documentation to public API
* Added topics for pub.dev discoverability
* Fixed example directory structure
* Migrated to freezed v3

## 0.0.1

* Initial release
* High-performance virtualized data grid with support for 100k+ rows
* Core features:
  * Column management (resize, pin, hide/show)
  * Multi-column sorting with isolate support for large datasets
  * Column filtering with multiple operators
  * Row selection (none/single/multiple modes)
  * Inline cell editing with validation
  * Keyboard navigation
  * Fully customizable theming
  * Event-driven architecture with interceptors
* Performance optimizations:
  * Viewport virtualization for 60fps scrolling
  * Background isolate processing for sort/filter operations
  * Debounced operations
