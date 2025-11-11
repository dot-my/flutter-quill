import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../document/attribute.dart';

/// Context information for building custom widget spans
@immutable
class WidgetSpanContext {
  const WidgetSpanContext({
    required this.text,
    required this.attribute,
    required this.textStyle,
    this.recognizer,
    this.cursorPositionInText,
  });

  /// The matched text to render
  final String text;

  /// The attribute associated with this match
  final Attribute attribute;

  /// The text style that would normally be applied
  final TextStyle? textStyle;

  /// Optional gesture recognizer for interactions
  final GestureRecognizer? recognizer;

  /// Position of cursor within this text (0-based), null if cursor is not in this span
  /// This is calculated from the zero-width spaces position
  final int? cursorPositionInText;
}

/// Builder function for creating custom widget spans
///
/// This function is called when text with a custom attribute needs to be rendered.
/// It can return:
/// - A [WidgetSpan] for full control over the rendering (padding, borders, etc.)
/// - A [TextSpan] with custom styling
/// - null to fall back to default rendering
///
/// Parameters:
/// - [context]: Build context
/// - [widgetSpanContext]: Information about the text to render
///
/// Example:
/// ```dart
/// InlineSpan? myWidgetSpanBuilder(
///   BuildContext context,
///   WidgetSpanContext spanContext,
/// ) {
///   if (spanContext.attribute.key == 'hashtag') {
///     return WidgetSpan(
///       alignment: PlaceholderAlignment.middle,
///       child: GestureDetector(
///         onTap: spanContext.recognizer is TapGestureRecognizer
///             ? () => (spanContext.recognizer as TapGestureRecognizer).onTap?.call()
///             : null,
///         child: Container(
///           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
///           decoration: BoxDecoration(
///             color: Colors.blue.withOpacity(0.1),
///             borderRadius: BorderRadius.circular(4),
///             border: Border.all(color: Colors.blue),
///           ),
///           child: Text(
///             spanContext.text,
///             style: spanContext.textStyle?.copyWith(color: Colors.blue),
///           ),
///         ),
///       ),
///     );
///   }
///   return null;
/// }
/// ```
typedef CustomWidgetSpanBuilder = InlineSpan? Function(
  BuildContext context,
  WidgetSpanContext spanContext,
);

