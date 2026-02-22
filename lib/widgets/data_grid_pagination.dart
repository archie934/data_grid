import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class DataGridPagination<T extends DataGridRow> extends StatelessWidget {
  const DataGridPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.dataGridController<T>()!;
    final theme = DataGridTheme.of(context);
    // Subscribe only to pagination and data aspects. Previously this widget
    // used a StreamBuilder on the full state stream, causing it to rebuild on
    // every state change (selection, edit, sort, etc.).
    final state = context.dataGridState<T>({DataGridAspect.pagination, DataGridAspect.data})!;

    if (!state.pagination.enabled) return const SizedBox.shrink();

    final pagination = state.pagination;
    final totalPages = pagination.totalPages(state.totalItems);
    final currentPage = pagination.currentPage;
    final pageSize = pagination.pageSize;
    final startItem = state.currentPageStart;
    final endItem = state.currentPageEnd;

    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: theme.colors.headerColor,
        border: Border(
          top: BorderSide(color: theme.colors.headerColor, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing $startItem-$endItem of ${state.totalItems}',
              style: const TextStyle(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: state.hasPreviousPage
                ? () => controller.firstPage()
                : null,
            tooltip: 'First page',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.hasPreviousPage
                ? () => controller.previousPage()
                : null,
            tooltip: 'Previous page',
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.hasNextPage
                ? () => controller.nextPage()
                : null,
            tooltip: 'Next page',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: state.hasNextPage
                ? () => controller.lastPage()
                : null,
            tooltip: 'Last page',
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: pageSize,
            items: [10, 25, 50, 100, 200]
                .map(
                  (size) => DropdownMenuItem(
                    value: size,
                    child: Text('$size per page'),
                  ),
                )
                .toList(),
            onChanged: (newSize) {
              if (newSize != null) {
                controller.setPageSize(newSize);
              }
            },
          ),
        ],
      ),
    );
  }
}
