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
