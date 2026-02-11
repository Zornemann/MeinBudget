// The following changes check if the widget is still mounted before using the BuildContext after async operations.

// Example of where you might have async calls, such as fetching data:

/// be sure to add this condition before accessing context
if (mounted) {
  // Perform your context-related operations here.
}