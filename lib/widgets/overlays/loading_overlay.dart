import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// Scoped loading overlay that only rebuilds when loading state changes.
///
/// Uses [InheritedModel] with [DataGridAspect.loading] to avoid
/// unnecessary rebuilds when unrelated grid state changes.
class DataGridLoadingScope<T extends DataGridRow> extends StatelessWidget {
  final Widget Function(BuildContext context, String? message)?
  loadingOverlayBuilder;
  final Color? backdropColor;
  final Color? indicatorColor;

  const DataGridLoadingScope({
    super.key,
    this.loadingOverlayBuilder,
    this.backdropColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>({DataGridAspect.loading});
    if (state == null || !state.isLoading) return const SizedBox.shrink();

    return loadingOverlayBuilder != null
        ? loadingOverlayBuilder!(context, state.loadingMessage)
        : DataGridLoadingOverlay(
            message: state.loadingMessage,
            backdropColor: backdropColor,
            indicatorColor: indicatorColor,
          );
  }
}

/// Default loading overlay widget displayed during heavy operations.
///
/// Shows a centered card with a circular progress indicator and optional message.
/// Used by DataGrid when performing operations like sorting large datasets.
class DataGridLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backdropColor;
  final Color? indicatorColor;

  const DataGridLoadingOverlay({
    super.key,
    this.message,
    this.backdropColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final overlayTheme = theme.overlay;

    return Positioned.fill(
      child: Container(
        color: backdropColor ?? overlayTheme.backdropColor,
        child: Center(
          child: Container(
            padding: overlayTheme.cardPadding,
            decoration: BoxDecoration(
              color: overlayTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(overlayTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: overlayTheme.shadowColor,
                  blurRadius: overlayTheme.shadowBlurRadius,
                  offset: overlayTheme.shadowOffset,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: overlayTheme.indicatorSize,
                  height: overlayTheme.indicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: overlayTheme.indicatorStrokeWidth,
                    color: indicatorColor,
                  ),
                ),
                SizedBox(height: overlayTheme.indicatorTextSpacing),
                Text(
                  message ?? overlayTheme.defaultMessage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
