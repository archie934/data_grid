import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';

/// Toolbar button that opens a checklist popup for toggling column
/// visibility. Uses [MenuAnchor] (rather than [PopupMenuButton]) with
/// `closeOnActivate: false` so the popup stays open while multiple
/// columns are toggled.
class ColumnVisibilityMenu<T extends DataGridRow> extends StatelessWidget {
  final DataGridController<T> controller;

  const ColumnVisibilityMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DataGridColumn<T>>>(
      // listEquals, not the default `==`: `==` on a List is identity, and
      // `effectiveColumns` builds a new list on every access, so the default
      // predicate never filtered anything and this menu (plus every
      // MenuItemButton and Checkbox in it) rebuilt on every state emission.
      stream: controller.state$
          .map((s) => s.effectiveColumns)
          .distinct(listEquals),
      initialData: controller.state.effectiveColumns,
      builder: (context, snapshot) {
        final columns = (snapshot.data ?? const [])
            .where((c) => c.id != kSelectionColumnId && c.id >= 0)
            .toList();

        return MenuAnchor(
          builder: (context, menuController, child) {
            return IconButton(
              icon: const Icon(Icons.view_column),
              tooltip: 'Toggle column visibility',
              onPressed: () {
                if (menuController.isOpen) {
                  menuController.close();
                } else {
                  menuController.open();
                }
              },
            );
          },
          menuChildren: [
            for (final column in columns)
              MenuItemButton(
                closeOnActivate: false,
                leadingIcon: Checkbox(
                  value: column.visible,
                  onChanged: (_) => controller.setColumnVisibility(
                    column.id,
                    !column.visible,
                  ),
                ),
                onPressed: () =>
                    controller.setColumnVisibility(column.id, !column.visible),
                child: Text(column.title),
              ),
          ],
        );
      },
    );
  }
}
