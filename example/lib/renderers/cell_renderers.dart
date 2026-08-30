import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';
import '../models/product_row.dart';

/// Reads row data from [CellScope] — no builder function, no allocations.
/// Declare as `const` on the column for maximum element reuse.
class RedPriceCell extends StatelessWidget {
  const RedPriceCell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);
    final theme = DataGridTheme.of(context);

    return Container(
      color: Colors.red,
      padding: theme.padding.cellPadding,
      // Container's `alignment` param inserts a plain Align (no
      // heightFactor), which expands to fill any bounded incoming height —
      // harmless when tightly constrained (fixed row height, or a settled
      // auto-measured row: the container is force-fit to that size either
      // way), but it would report DataGrid.autoRowHeight's maxHeight as this
      // cell's "measured" height during the initial loose measurement pass.
      // heightFactor: 1.0 makes Align shrink-wrap to the text instead.
      child: Align(
        alignment: Alignment.centerLeft,
        heightFactor: 1.0,
        child: Text(
          '\$${scope.row.price.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// A colored square "thumbnail" standing in for a product photo — deliberately
/// taller than the default row height, so rows with [ProductRow.hasPhoto] set
/// exercise `autoRowHeight`. Uses a synthetic color (no network dependency)
/// so the example stays fast and offline-friendly.
class PhotoThumbnailCell extends StatelessWidget {
  const PhotoThumbnailCell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);
    if (!scope.row.hasPhoto) return const SizedBox.shrink();

    final hue = (scope.row.id.toInt() * 47) % 360;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.55).toColor(),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image, color: Colors.white),
      ),
    );
  }
}

/// Wrapped free-text notes — empty for most rows, several sentences for
/// others, so row height genuinely varies with content rather than a single
/// fixed "tall row" size. Self-clips so a long note never bleeds into the
/// row below when `autoRowHeight` is off (the row is then a fixed height and
/// can't grow to fit).
class NotesCell extends StatelessWidget {
  const NotesCell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);
    final theme = DataGridTheme.of(context);
    if (scope.row.notes.isEmpty) return const SizedBox.shrink();

    return ClipRect(
      child: Padding(
        padding: theme.padding.cellPadding,
        // heightFactor: 1.0 shrink-wraps Align to the text's actual height —
        // required under autoRowHeight's loose (but bounded) measurement
        // pass, where a plain Align would otherwise expand to fill the
        // measurement's maxHeight clamp on every row, defeating measurement.
        child: Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1.0,
          child: Text(scope.row.notes, softWrap: true, maxLines: 6),
        ),
      ),
    );
  }
}

class ActionsCellWidget extends StatelessWidget {
  final void Function(double rowId) onDelete;

  const ActionsCellWidget({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);

    // Center is Align(alignment: center) with no heightFactor — see
    // RedPriceCell for why that needs heightFactor: 1.0 under autoRowHeight.
    return Center(
      heightFactor: 1.0,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        tooltip: 'Delete row',
        onPressed: () => onDelete(scope.row.id),
      ),
    );
  }
}
