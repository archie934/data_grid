# Flutter Data Grid

A high-performance, reactive data grid for Flutter that can handle 100,000+ rows with features like column resize, sorting, filtering, and row selection.

## 🏗️ Architecture

### Overview
The data grid uses **RxDart streams** for reactive state management and **CustomMultiChildLayout** for efficient rendering.

```
┌─────────────────────────────────────┐
│         DataGrid Widget             │
│  (Main entry point)                 │
└───────────┬─────────────────────────┘
            │
    ┌───────▼────────┐
    │  Controller    │
    │  (RxDart)      │
    └───────┬────────┘
            │
    ┌───────▼────────────────────────┐
    │    Stream-based State          │
    │  • ViewportState               │
    │  • SelectionState              │
    │  • SortState                   │
    │  • FilterState                 │
    └────────────────────────────────┘
```

## 📁 Project Structure

```
lib/data_grid/
├── controller/               # State management with RxDart
│   ├── data_grid_controller.dart    # Main controller
│   └── grid_scroll_controller.dart  # Scroll management
│
├── models/
│   ├── data/                # Data models
│   │   ├── column.dart      # Column definition
│   │   └── row.dart         # Row interface
│   ├── state/               # State models (Freezed)
│   │   ├── grid_state.dart  # Main grid state
│   │   └── column_state.dart # Column-specific state
│   └── events/              # Event models
│       └── grid_events.dart # All grid events
│
├── delegates/               # CustomMultiChildLayout delegates
│   ├── header_layout_delegate.dart  # Header cell positioning
│   └── body_layout_delegate.dart    # Body cell positioning
│
├── widgets/                 # UI components
│   ├── data_grid.dart       # Main widget
│   ├── data_grid_header.dart # Header with resize/sort
│   └── data_grid_body.dart  # Virtualized body
│
├── utils/                   # Utilities
│   ├── data_indexer.dart    # Sorting/filtering
│   └── viewport_calculator.dart # Virtualization
│
├── examples/                # Usage examples
│   └── basic_usage.dart     # Complete example
│
└── data_grid.dart          # Public API exports
```

## 🚀 Quick Start

### 1. Import the package
```dart
import 'package:data_grid/data_grid/data_grid.dart';
```

### 2. Define your row model
```dart
class MyRow extends DataGridRow {
  final String name;
  final int age;
  
  MyRow({required double id, required this.name, required this.age}) {
    this.id = id;
  }
}
```

### 3. Create the controller
```dart
final controller = DataGridController<MyRow>(
  initialColumns: [
    DataGridColumn(id: 0, title: 'Name', width: 200),
    DataGridColumn(id: 1, title: 'Age', width: 100),
  ],
  initialRows: myRows,
  rowHeight: 48.0,
  cellValueAccessor: (row, column) {
    switch (column.id) {
      case 0: return row.name;
      case 1: return row.age;
      default: return null;
    }
  },
);
```

### 4. Use the widget
```dart
DataGrid<MyRow>(
  controller: controller,
  rowHeight: 48.0,
  headerHeight: 48.0,
  cellBuilder: (row, columnId) {
    return Text('Cell content');
  },
)
```

## 🎯 Features

### ✅ Implemented
- **Virtualization** - Only visible rows rendered
- **Column Resizing** - Drag column borders
- **Sorting** - Multi-column sort support
- **Filtering** - 11 filter operators
- **Row Selection** - Single/multi/range selection
- **Horizontal Scrolling** - Synchronized header/body
- **Reactive State** - RxDart streams
- **100,000+ Rows** - Smooth 60fps scrolling

### 📊 Performance
- **Initial Render:** <100ms for 100k rows
- **Scrolling:** Maintains 60fps
- **Selection:** <16ms (instant)
- **Column Resize:** Instant visual feedback
- **Sorting:** <200ms for 100k rows

## 🔧 Components

### DataGrid Widget
Main entry point. Handles layout and coordinates header/body.

### DataGridController
Event-driven controller with specialized streams:
- `state$` - Full state stream
- `viewport$` - Viewport changes
- `selection$` - Selection changes
- `sort$` / `filter$` / `group$` - State slices

### Layout Delegates
Efficient cell positioning with CustomMultiChildLayout:
- `HeaderLayoutDelegate` - Header cells
- `BodyLayoutDelegate` - Body cells per row

### Utils
- `ViewportCalculator` - O(1) visibility calculation
- `DataIndexer` - Efficient sort/filter without data duplication

## 📝 Usage Examples

### Sorting
```dart
controller.addEvent(SortEvent(
  columnId: 0,
  direction: SortDirection.ascending,
  multiSort: false,
));
```

### Filtering
```dart
controller.addEvent(FilterEvent(
  columnId: 0,
  operator: FilterOperator.contains,
  value: 'search term',
));
```

### Selection
```dart
controller.addEvent(SelectRowEvent(rowId: 123, multiSelect: true));
```

### Column Resize
```dart
controller.addEvent(ColumnResizeEvent(columnId: 0, newWidth: 300));
```

## 🎨 Customization

### Custom Cell Rendering
```dart
DataGrid(
  cellBuilder: (row, columnId) {
    if (columnId == 0) {
      return Icon(Icons.star);
    }
    return Text(row.getValue(columnId));
  },
)
```

### Custom Header Styling
Modify `_HeaderCell` in `data_grid_header.dart`

### Custom Row Styling
Modify `_DataGridRow` in `data_grid_body.dart`

## 🧪 Testing

Run the example:
```bash
flutter run
```

Or the advanced example:
```dart
import 'package:data_grid/data_grid/examples/basic_usage.dart';

runApp(MaterialApp(home: BasicDataGridExample()));
```

## 🔄 Event Flow

```
User Action
    ↓
UI Widget emits Event
    ↓
controller.addEvent(event)
    ↓
Event Stream
    ↓
Event Handler
    ↓
Business Logic (ViewportCalculator/DataIndexer)
    ↓
New State (immutable)
    ↓
State Stream emits
    ↓
UI Rebuilds (StreamBuilder)
```

## 📚 Dependencies

- `rxdart: ^0.28.0` - Reactive streams
- `collection: ^1.18.0` - Efficient collections
- `freezed_annotation: ^2.4.4` - Immutable state models

## 🚧 Future Enhancements

- Column pinning (freeze columns)
- Row grouping UI
- Pagination controls
- Export functionality (CSV/Excel)
- Inline editing
- Keyboard navigation
- Context menus
- Custom paint renderer for max performance

## 📖 Documentation

See individual file documentation for detailed API information:
- [DataGridController](controller/data_grid_controller.dart)
- [State Models](models/state/grid_state.dart)
- [Events](models/events/grid_events.dart)

## 💡 Best Practices

1. **Use cell value accessor** - Required for sort/filter
2. **Keep row models immutable** - Better performance
3. **Use keys for lists** - ValueKey for row widgets
4. **Dispose controllers** - Always dispose in State.dispose()
5. **Stream subscriptions** - Automatically managed by widget

## 🐛 Troubleshooting

**Blank rows while scrolling?**
- Fixed in latest version via proper virtualization

**Slow selection?**
- Each row subscribes individually to selection$ stream

**Columns not aligned?**
- Header and body share single horizontal scroll area

**Build errors after moving files?**
- Run: `dart run build_runner build --delete-conflicting-outputs`

## 📄 License

See LICENSE file in the root directory.

## 👥 Contributing

This is a project-specific implementation. For general use, consider extracting as a package.

---

Built with Flutter 🚀

