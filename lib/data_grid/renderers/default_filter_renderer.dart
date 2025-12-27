import 'dart:async';
import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/renderers/filter_renderer.dart';

/// Default filter renderer using a simple text input with "contains" operator.
class DefaultFilterRenderer extends FilterRenderer {
  final Duration debounce;

  const DefaultFilterRenderer({this.debounce = const Duration(milliseconds: 300)});

  @override
  Widget buildFilter(
    BuildContext context,
    DataGridColumn column,
    ColumnFilter? currentFilter,
    void Function(FilterOperator operator, dynamic value) onChange,
    void Function() onClear,
  ) {
    return _FilterTextField(
      column: column,
      currentFilter: currentFilter,
      onChange: onChange,
      onClear: onClear,
      debounce: debounce,
    );
  }
}

class _FilterTextField extends StatefulWidget {
  final DataGridColumn column;
  final ColumnFilter? currentFilter;
  final void Function(FilterOperator operator, dynamic value) onChange;
  final void Function() onClear;
  final Duration debounce;

  const _FilterTextField({
    required this.column,
    required this.currentFilter,
    required this.onChange,
    required this.onClear,
    required this.debounce,
  });

  @override
  State<_FilterTextField> createState() => _FilterTextFieldState();
}

class _FilterTextFieldState extends State<_FilterTextField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentFilter?.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_FilterTextField oldWidget) {
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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasFilter = widget.currentFilter != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          hintText: 'Filter ${widget.column.title}...',
          hintStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            icon: Icon(Icons.clear, size: 16, color: hasFilter ? colorScheme.onSurfaceVariant : Colors.transparent),
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
          suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        style: textTheme.bodySmall,
      ),
    );
  }
}
