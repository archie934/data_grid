import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/events/group_events.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';

/// Full-width band shown for a [GridGroupHeaderRow] slot: expand/collapse
/// chevron, grouped column title and value, and a row-count badge.
class GroupHeaderBand<T extends DataGridRow> extends StatelessWidget {
  final GridGroupHeaderRow<T> header;

  const GroupHeaderBand({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>();

    final subgroupCount = header.subgroupCount;
    final countLabel = subgroupCount != null
        ? '$subgroupCount groups'
        : '${header.rowCount} rows';

    return Semantics(
      label:
          '${header.columnTitle}: ${header.displayLabel}, '
          '$countLabel, '
          '${header.isExpanded ? 'expanded' : 'collapsed'}',
      button: true,
      child: InkWell(
        onTap: () => controller?.addEvent(
          ToggleGroupExpansionEvent(groupKey: header.groupKey),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.groupHeaderColor,
            border: theme.borders.headerBorder,
          ),
          padding: theme.padding.headerPadding,
          child: Row(
            children: [
              SizedBox(width: header.depth * theme.padding.groupIndentWidth),
              Icon(
                header.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
              SizedBox(width: theme.padding.iconSpacing),
              Flexible(
                child: Text(
                  '${header.columnTitle}: ${header.displayLabel}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: theme.padding.iconSpacing),
              Text(
                '(${subgroupCount ?? header.rowCount})',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
