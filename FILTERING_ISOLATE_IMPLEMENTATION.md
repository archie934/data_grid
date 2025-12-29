# Filtering Isolate Implementation

## Overview
Implemented isolate-based filtering for large datasets (similar to the existing sorting implementation), improving performance and UI responsiveness when filtering many rows.

## Changes Made

### New Files Created

1. **lib/utils/isolate_filter.dart**
   - Contains `FilterParameters` class for passing filter data to isolate
   - Top-level `performFilterInIsolate()` function that executes in isolate
   - Filtering logic that matches all filter operators

2. **lib/delegates/filter_delegate.dart**
   - Abstract `FilterDelegate` interface for pluggable filtering behavior
   - Defines async `applyFilters()` method

3. **lib/delegates/default_filter_delegate.dart**
   - Default implementation with debouncing and isolate support
   - Uses isolate when row count exceeds threshold (default: 10,000 rows)
   - Falls back to synchronous filtering for smaller datasets

### Modified Files

1. **lib/controllers/data_grid_controller.dart**
   - Added `filterDebounce` and `filterIsolateThreshold` parameters
   - Integrated `FilterDelegate` into controller
   - Passes filter delegate to event context

2. **lib/models/events/event_context.dart**
   - Added `filterDelegate` field to context

3. **lib/models/events/base_event.dart**
   - Changed return type to `FutureOr<DataGridState<T>?>` to support async operations

4. **lib/models/events/filter_events.dart**
   - Updated `FilterEvent` and `ClearFilterEvent` to use filter delegate
   - Made apply methods async
   - Changed loading threshold to 10,000 rows (consistent with isolate threshold)

5. **lib/models/events/data_events.dart**
   - Updated `LoadDataEvent`, `InsertRowEvent`, `InsertRowsEvent`, and `UpdateRowEvent`
   - All now use filter delegate instead of direct `dataIndexer.filter()` calls
   - Made apply methods async where filtering is used

6. **lib/delegates/default_sort_delegate.dart**
   - Updated to accept optional `FilterDelegate`
   - Uses filter delegate when available for consistency
   - Ensures filtering also benefits from isolate when sorting

## Configuration

### Default Values
- **Filter Debounce**: 300ms
- **Isolate Threshold**: 10,000 rows

### Custom Configuration
```dart
final controller = DataGridController<MyRow>(
  filterDebounce: Duration(milliseconds: 500),
  filterIsolateThreshold: 5000,
  filterDelegate: CustomFilterDelegate(), // Optional custom implementation
);
```

## Performance Characteristics

- **Small datasets (< 10,000 rows)**: Synchronous filtering on main thread
- **Large datasets (≥ 10,000 rows)**: Async filtering in isolate
- **Debouncing**: Prevents excessive filtering during rapid user input
- **Loading indicator**: Shown automatically for large datasets

## Benefits

1. **Non-blocking UI**: Large filtering operations don't freeze the UI
2. **Better performance**: Utilizes multiple cores for heavy filtering
3. **Consistent architecture**: Follows same pattern as sorting
4. **Backward compatible**: Existing code works without changes
5. **Configurable**: Thresholds and delegates can be customized

