import 'package:flutter/material.dart';

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
    return Positioned.fill(
      child: Container(
        color: backdropColor ?? Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: indicatorColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Processing...',
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

