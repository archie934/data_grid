/// Base class for rows displayed in a [DataGrid].
///
/// Implement this class to define your data model. Each row must have
/// a unique [id] for identification and state tracking.
///
/// Example:
/// ```dart
/// class Person extends DataGridRow {
///   @override
///   double id;
///   String name;
///   int age;
///
///   Person({required this.id, required this.name, required this.age});
/// }
/// ```
abstract class DataGridRow {
  /// Unique identifier for this row.
  late double id;
}
