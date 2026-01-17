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
