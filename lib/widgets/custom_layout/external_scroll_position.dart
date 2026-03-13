import 'package:flutter/widgets.dart';

/// [ScrollPosition] subclass that can be driven externally without a viewport.
///
/// Overrides dimension getters to return safe defaults when no viewport has
/// called [applyContentDimensions]/[applyViewportDimension], preventing null
/// check failures when downstream code reads [ScrollMetrics] properties.
class ExternalScrollPosition extends ScrollPositionWithSingleContext {
  ExternalScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
  });

  void syncPixels(double value) {
    if (pixels != value) forcePixels(value);
  }

  /// When this position is driven externally (no real viewport / notification
  /// context) use [syncPixels] so we never dereference a null notificationContext.
  @override
  void jumpTo(double value) {
    if (context.notificationContext == null) {
      syncPixels(value);
    } else {
      super.jumpTo(value);
    }
  }

  @override
  double get minScrollExtent =>
      hasContentDimensions ? super.minScrollExtent : 0.0;

  @override
  double get maxScrollExtent =>
      hasContentDimensions ? super.maxScrollExtent : 0.0;

  @override
  double get viewportDimension =>
      hasViewportDimension ? super.viewportDimension : 0.0;
}
