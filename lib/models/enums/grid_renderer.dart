/// Rendering strategy used for the grid body.
enum DataGridRendererType {
  /// Uses Flutter's [TwoDimensionalScrollView] with a custom [RenderObject].
  ///
  /// Leverages the framework's built-in two-axis viewport and scroll physics,
  /// which provides native scrollbar integration and accessibility support.
  twoDimensional,

  /// Uses [CustomMultiChildLayout] with raw pointer-based scrolling.
  ///
  /// Manages its own scroll offsets via [ValueNotifier] and handles input
  /// through [Listener], giving full control over scroll behaviour and
  /// enabling per-axis rebuild optimisation (pinned columns only rebuild
  /// on vertical scroll).
  customLayout,
}
