import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/widgets/filters/filter_scope.dart';
import 'package:flutter_data_grid/widgets/filters/filter_text_field.dart';

/// Default filter widget using a simple debounced text input.
///
/// Reads column and filter state from the nearest [FilterScope] ancestor,
/// which is provided automatically by the grid for each filterable column.
///
/// To use a custom debounce duration:
/// ```dart
/// DataGridColumn<MyRow>(
///   filterWidget: const DefaultFilterWidget(debounce: Duration(milliseconds: 500)),
/// )
/// ```
class DefaultFilterWidget extends StatelessWidget {
  final Duration debounce;

  const DefaultFilterWidget({
    super.key,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final scope = FilterScope.of(context);
    return FilterTextField(
      column: scope.column,
      currentFilter: scope.currentFilter,
      onChange: scope.onChange,
      onClear: scope.onClear,
      debounce: debounce,
    );
  }
}
