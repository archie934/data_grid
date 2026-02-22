import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// A debounced text input used as the default filter UI for a column.
///
/// Fires [onChange] with [FilterOperator.contains] while the user types,
/// or [onClear] when the field is emptied. Not intended for direct use —
/// instantiated by [DefaultFilterWidget] via [FilterScope].
class FilterTextField extends StatefulWidget {
  final DataGridColumn column;
  final ColumnFilter? currentFilter;
  final void Function(FilterOperator operator, dynamic value) onChange;
  final void Function() onClear;
  final Duration debounce;

  const FilterTextField({
    super.key,
    required this.column,
    required this.currentFilter,
    required this.onChange,
    required this.onClear,
    required this.debounce,
  });

  @override
  State<FilterTextField> createState() => _FilterTextFieldState();
}

class _FilterTextFieldState extends State<FilterTextField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentFilter?.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(FilterTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilter?.value != oldWidget.currentFilter?.value) {
      _controller.text = widget.currentFilter?.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      if (value.isEmpty) {
        widget.onClear();
      } else {
        widget.onChange(FilterOperator.contains, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridTheme = DataGridTheme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasFilter = widget.currentFilter != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: gridTheme.borders.filterBorder,
      ),
      padding: gridTheme.padding.filterPadding,
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          hintText: 'Filter ${widget.column.title}...',
          hintStyle: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          isDense: true,
          contentPadding: gridTheme.padding.filterInputPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              size: 16,
              color: hasFilter
                  ? colorScheme.onSurfaceVariant
                  : Colors.transparent,
            ),
            onPressed: hasFilter
                ? () {
                    _controller.clear();
                    widget.onClear();
                  }
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            iconSize: 16,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
        style: textTheme.bodySmall,
      ),
    );
  }
}
