# Pattern Styling Configuration

Automatically detect and style text patterns (hashtags, mentions, URLs, etc.) with custom widgets.

## Overview

Pattern styling allows you to:
- Detect text patterns using regex (hashtags, mentions, URLs, emails, etc.)
- Apply custom styling with WidgetSpan (padding, borders, backgrounds)
- Add interactive behaviors (tap, long-press)
- Maintain proper cursor positioning

## Quick Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  // 1. Define custom attribute
  static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');
  
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    
    // 2. Configure pattern matcher
    _controller = QuillController(
      document: Document()..insert(0, 'Type #hashtags here!'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(
            r'#[a-zA-Z0-9_]+',  // Regex pattern
            hashtagAttr,         // Associated attribute
            caseSensitive: false,
          ),
        ],
      ),
    );
  }

  // 3. Define custom rendering
  InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
    if (ctx.attribute.key != 'hashtag') return null;

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => print('Tapped: ${ctx.text}'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            ctx.text,
            style: ctx.textStyle?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      controller: _controller,
      config: QuillEditorConfig(
        customWidgetSpanBuilder: _customBuilder,  // 4. Hook it up
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Configuration Options

### PatternMatcher

```dart
// Option 1: Using fromString (recommended)
PatternMatcher.fromString(
  r'#[a-zA-Z0-9_]+',     // Regex pattern
  myAttribute,           // Attribute to apply
  caseSensitive: false,  // Case sensitivity (default: true)
)

// Option 2: Using RegExp directly
PatternMatcher(
  pattern: RegExp(r'#[a-zA-Z0-9_]+'),
  attribute: myAttribute,
  caseSensitive: false,
)
```

### Multiple Patterns

```dart
QuillControllerConfig(
  patternMatchers: [
    PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr),
    PatternMatcher.fromString(r'@[a-zA-Z0-9_]+', mentionAttr),
    PatternMatcher.fromString(r'https?://[^\s]+', urlAttr),
  ],
)
```

## Common Patterns

| Pattern Type | Regex | Example |
|-------------|-------|---------|
| **Hashtags** | `r'#[a-zA-Z0-9_]+'` | #flutter |
| **Mentions** | `r'@[a-zA-Z0-9_]+'` | @user |
| **URLs** | `r'https?://[^\s]+'` | https://flutter.dev |
| **Emails** | `r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'` | user@example.com |

## WidgetSpanContext Properties

When building custom widgets, you receive a `WidgetSpanContext`:

```dart
class WidgetSpanContext {
  final String text;                    // The matched text
  final Attribute attribute;            // The attribute that matched
  final TextStyle? textStyle;           // Current text style
  final GestureRecognizer? recognizer;  // Optional gesture recognizer
  final int? cursorPositionInText;      // Cursor position (if within this span)
}
```

## Advanced: Cursor Support

When using `WidgetSpan`, add zero-width spaces to maintain cursor position:

```dart
InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
  final text = ctx.text;
  final zeroWidthSpaceCount = text.length - 1;

  return TextSpan(
    children: [
      WidgetSpan(
        child: /* your widget */,
      ),
      // Add zero-width spaces
      for (var i = 0; i < zeroWidthSpaceCount; i++)
        const TextSpan(text: '\u200b'),
    ],
  );
}
```

## Interactive Elements

### Simple Tap Handler

```dart
GestureDetector(
  onTap: () {
    print('Tapped: ${ctx.text}');
  },
  child: /* your widget */,
)
```

### Respecting Existing Recognizers

```dart
GestureDetector(
  onTap: ctx.recognizer is TapGestureRecognizer
      ? () => (ctx.recognizer as TapGestureRecognizer).onTap?.call()
      : () => _customHandler(ctx.text),
  child: /* your widget */,
)
```

## Complete Examples

- **Full Guide:** [Pattern Styling Guide](../pattern_styling_guide.md)
- **Quick Reference:** [Pattern Styling Quick Reference](../pattern_styling_quick_reference.md)
- **Working Code:** [Pattern Styling Example](../../example/lib/pattern_styling_example.dart)

## Troubleshooting

### Patterns not detected?
- Verify pattern matcher is in `QuillControllerConfig.patternMatchers`
- Test your regex separately
- Check attribute keys match between matcher and builder

### Cursor position wrong?
- Add zero-width spaces after WidgetSpan (see "Advanced: Cursor Support")

### Tap not working?
- Use `GestureDetector` and handle existing recognizers (see "Interactive Elements")

## Best Practices

✅ **DO:**
- Use specific, efficient regex patterns
- Keep widget hierarchies simple
- Test with various text lengths

❌ **DON'T:**
- Use greedy patterns like `.*` or `.+`
- Perform expensive operations in the builder
- Forget zero-width spaces when using WidgetSpan

## Learn More

For comprehensive documentation, see:
- [Pattern Styling Guide](../pattern_styling_guide.md) - Full integration guide
- [Quick Reference](../pattern_styling_quick_reference.md) - Code snippets and templates

