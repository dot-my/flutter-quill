# Pattern Styling Integration Guide

This guide explains how to integrate and use the pattern-based text styling feature in your Flutter Quill application. This feature allows you to automatically detect and style text patterns (like hashtags, mentions, URLs, etc.) with custom formatting and interactive widgets.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [Step-by-Step Integration](#step-by-step-integration)
- [Configuration Options](#configuration-options)
- [Advanced Customization](#advanced-customization)
- [Real-World Examples](#real-world-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

The pattern styling feature provides:

- ✅ Automatic detection of text patterns using regular expressions
- ✅ Dynamic attribute application as users type
- ✅ Custom rendering with `WidgetSpan` (padding, borders, backgrounds, etc.)
- ✅ Interactive elements (tap handlers, long press, etc.)
- ✅ Full cursor support within styled text
- ✅ Compatible with other Quill formatting (bold, italic, colors, etc.)

**Common Use Cases:**

- Hashtags (#flutter, #dart)
- Mentions (@username)
- URLs (http://example.com)
- Email addresses
- Phone numbers
- Custom syntax (markdown-like, wiki-style, etc.)

---

## How It Works

The pattern styling system has three main components:

1. **PatternMatcher**: Defines a regex pattern and associates it with a custom attribute
2. **PatternAttributeHandler**: Automatically detects patterns and applies attributes (runs behind the scenes)
3. **CustomWidgetSpanBuilder**: Renders styled text with custom widgets

```
User Types → Pattern Detected → Attribute Applied → Custom Widget Rendered
```

---

## Quick Start

Here's a minimal example to get you started:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  // 1. Define a custom attribute for your pattern
  static const hashtagAttribute = Attribute('hashtag', AttributeScope.inline, 'hashtag');

  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 2. Create controller with pattern matcher
    _controller = QuillController(
      document: Document()..insert(0, 'Try typing #flutter #dart'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(
            r'#[a-zA-Z0-9_]+',  // Regex for hashtags
            hashtagAttribute,
            caseSensitive: false,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 3. Define custom rendering
  InlineSpan? _customWidgetSpanBuilder(
    BuildContext context,
    WidgetSpanContext spanContext,
  ) {
    if (spanContext.attribute.key != 'hashtag') {
      return null; // Let default rendering handle it
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          spanContext.text,
          style: spanContext.textStyle?.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      focusNode: _focusNode,
      scrollController: ScrollController(),
      controller: _controller,
      config: QuillEditorConfig(
        // 4. Hook up the custom widget span builder
        customWidgetSpanBuilder: _customWidgetSpanBuilder,
      ),
    );
  }
}
```

---

## Step-by-Step Integration

### Step 1: Define Custom Attributes

Create custom attributes for each pattern type you want to detect:

```dart
class MyEditorState extends State<MyEditor> {
  // Define custom attributes
  static const hashtagAttribute = Attribute('hashtag', AttributeScope.inline, 'hashtag');
  static const mentionAttribute = Attribute('mention', AttributeScope.inline, 'mention');
  static const urlAttribute = Attribute('url', AttributeScope.inline, 'url');

  // ... rest of your code
}
```

**Parameters:**

- First parameter: Unique key for the attribute (must be unique across your app)
- Second parameter: `AttributeScope.inline` (always use this for pattern matching)
- Third parameter: Value (typically same as the key)

### Step 2: Configure Pattern Matchers

Add pattern matchers to your `QuillController` configuration:

```dart
_controller = QuillController(
  document: Document(),
  selection: const TextSelection.collapsed(offset: 0),
  config: QuillControllerConfig(
    patternMatchers: [
      // Hashtags: #word
      PatternMatcher.fromString(
        r'#[a-zA-Z0-9_]+',
        hashtagAttribute,
        caseSensitive: false,
      ),

      // Mentions: @username
      PatternMatcher.fromString(
        r'@[a-zA-Z0-9_]+',
        mentionAttribute,
        caseSensitive: false,
      ),

      // URLs: http(s)://...
      PatternMatcher.fromString(
        r'https?://[^\s]+',
        urlAttribute,
        caseSensitive: false,
      ),
    ],
  ),
);
```

**Pattern Matcher Options:**

- `pattern` or use `fromString()`: Regular expression to match
- `attribute`: The attribute to apply when pattern matches
- `caseSensitive`: Whether matching is case-sensitive (default: true)

### Step 3: Implement Custom Widget Span Builder

Create a function to render your styled patterns:

```dart
InlineSpan? _customWidgetSpanBuilder(
  BuildContext context,
  WidgetSpanContext spanContext,
) {
  // Handle hashtags
  if (spanContext.attribute.key == 'hashtag') {
    return _buildHashtagSpan(context, spanContext);
  }

  // Handle mentions
  if (spanContext.attribute.key == 'mention') {
    return _buildMentionSpan(context, spanContext);
  }

  // Let default rendering handle everything else
  return null;
}

WidgetSpan _buildHashtagSpan(BuildContext context, WidgetSpanContext spanContext) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: GestureDetector(
      onTap: () {
        // Handle tap on hashtag
        print('Tapped: ${spanContext.text}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Text(
          spanContext.text,
          style: spanContext.textStyle?.copyWith(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
```

### Step 4: Configure the Editor

Pass your custom widget span builder to the editor:

```dart
QuillEditor(
  focusNode: _focusNode,
  scrollController: _scrollController,
  controller: _controller,
  config: QuillEditorConfig(
    customWidgetSpanBuilder: _customWidgetSpanBuilder,
    placeholder: 'Start typing...',
    // ... other config options
  ),
)
```

---

## Configuration Options

### PatternMatcher Configuration

```dart
// Option 1: Using fromString (recommended)
PatternMatcher.fromString(
  r'#[a-zA-Z0-9_]+',
  myAttribute,
  caseSensitive: false,
)

// Option 2: Using RegExp directly
PatternMatcher(
  pattern: RegExp(r'#[a-zA-Z0-9_]+', caseSensitive: false),
  attribute: myAttribute,
  caseSensitive: false,
)
```

### WidgetSpanContext Properties

Your custom widget span builder receives a `WidgetSpanContext` with:

```dart
class WidgetSpanContext {
  final String text;                    // The matched text
  final Attribute attribute;            // The attribute that matched
  final TextStyle? textStyle;           // Current text style
  final GestureRecognizer? recognizer;  // Optional gesture recognizer
  final int? cursorPositionInText;      // Cursor position (null if cursor not in this span)
}
```

### QuillEditorConfig Options

```dart
QuillEditorConfig(
  customWidgetSpanBuilder: _customWidgetSpanBuilder,  // Your custom builder
  placeholder: 'Start typing...',
  padding: EdgeInsets.all(16),
  // ... other standard config options
)
```

---

## Advanced Customization

### Handling Cursor Position

When using `WidgetSpan`, you need to handle cursor positioning properly. The example below shows the recommended approach:

```dart
InlineSpan? _customWidgetSpanBuilder(
  BuildContext context,
  WidgetSpanContext spanContext,
) {
  if (spanContext.attribute.key != 'hashtag') {
    return null;
  }

  final text = spanContext.text;
  final textLength = text.length;
  final cursorPos = spanContext.cursorPositionInText;

  // Calculate zero-width spaces needed for cursor positioning
  final zeroWidthSpaceCount = textLength - 1;

  // Build text widget with optional cursor indicator
  Widget textWidget;
  if (cursorPos != null && cursorPos >= 0 && cursorPos <= textLength) {
    // Cursor is within this text - show cursor line
    final beforeCursor = text.substring(0, cursorPos);
    final afterCursor = cursorPos < text.length ? text.substring(cursorPos) : '';

    textWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (beforeCursor.isNotEmpty)
          Text(beforeCursor, style: spanContext.textStyle),
        // Cursor indicator
        Container(
          width: 2,
          height: (spanContext.textStyle?.fontSize ?? 14) * 1.2,
          color: Colors.blue,
        ),
        if (afterCursor.isNotEmpty)
          Text(afterCursor, style: spanContext.textStyle),
      ],
    );
  } else {
    // No cursor - render normally
    textWidget = Text(text, style: spanContext.textStyle);
  }

  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: textWidget,
        ),
      ),
      // Add zero-width spaces to maintain cursor position
      for (var i = 0; i < zeroWidthSpaceCount; i++)
        const TextSpan(text: '\u200b'), // Zero-width space (U+200B)
    ],
  );
}
```

### Interactive Elements

Add tap, long-press, or other gestures:

```dart
WidgetSpan _buildInteractiveSpan(WidgetSpanContext spanContext) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: GestureDetector(
      // Handle existing recognizer if provided
      onTap: spanContext.recognizer is TapGestureRecognizer
          ? () => (spanContext.recognizer as TapGestureRecognizer).onTap?.call()
          : () {
              // Your custom tap handler
              _handleTap(spanContext.text);
            },
      onLongPress: () {
        // Your custom long-press handler
        _handleLongPress(spanContext.text);
      },
      child: Container(
        // Your custom styling
      ),
    ),
  );
}
```

### Multiple Pattern Types

Handle different patterns with different styles:

```dart
InlineSpan? _customWidgetSpanBuilder(
  BuildContext context,
  WidgetSpanContext spanContext,
) {
  switch (spanContext.attribute.key) {
    case 'hashtag':
      return _buildHashtagSpan(spanContext);
    case 'mention':
      return _buildMentionSpan(spanContext);
    case 'url':
      return _buildUrlSpan(spanContext);
    case 'email':
      return _buildEmailSpan(spanContext);
    default:
      return null; // Use default rendering
  }
}

WidgetSpan _buildHashtagSpan(WidgetSpanContext ctx) {
  return WidgetSpan(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(ctx.text, style: ctx.textStyle),
    ),
  );
}

WidgetSpan _buildMentionSpan(WidgetSpanContext ctx) {
  return WidgetSpan(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(ctx.text, style: ctx.textStyle),
    ),
  );
}
```

---

## Real-World Examples

### Example 1: Social Media Style (Hashtags + Mentions)

```dart
class SocialMediaEditor extends StatefulWidget {
  @override
  State<SocialMediaEditor> createState() => _SocialMediaEditorState();
}

class _SocialMediaEditorState extends State<SocialMediaEditor> {
  static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');
  static const mentionAttr = Attribute('mention', AttributeScope.inline, 'mention');

  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document()..insert(0, 'Hey @john, check out #flutter!'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr),
          PatternMatcher.fromString(r'@[a-zA-Z0-9_]+', mentionAttr),
        ],
      ),
    );
  }

  InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
    if (ctx.attribute.key == 'hashtag') {
      return WidgetSpan(
        child: GestureDetector(
          onTap: () => _onHashtagTap(ctx.text),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(ctx.text,
                style: ctx.textStyle?.copyWith(color: Colors.blue.shade700)),
          ),
        ),
      );
    }

    if (ctx.attribute.key == 'mention') {
      return WidgetSpan(
        child: GestureDetector(
          onTap: () => _onMentionTap(ctx.text),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(ctx.text,
                style: ctx.textStyle?.copyWith(color: Colors.purple.shade700)),
          ),
        ),
      );
    }

    return null;
  }

  void _onHashtagTap(String hashtag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search $hashtag'),
        content: Text('Would you like to search for posts with $hashtag?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to search results
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _onMentionTap(String mention) {
    final username = mention.substring(1); // Remove @
    // Navigate to user profile
    print('Navigate to profile: $username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social Media Editor')),
      body: QuillEditor(
        focusNode: FocusNode(),
        scrollController: ScrollController(),
        controller: _controller,
        config: QuillEditorConfig(
          customWidgetSpanBuilder: _customBuilder,
          placeholder: 'What\'s on your mind?',
        ),
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

### Example 2: Email Addresses with Action

```dart
class EmailEditor extends StatefulWidget {
  @override
  State<EmailEditor> createState() => _EmailEditorState();
}

class _EmailEditorState extends State<EmailEditor> {
  static const emailAttr = Attribute('email', AttributeScope.inline, 'email');

  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document()..insert(0, 'Contact me at user@example.com'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(
            r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            emailAttr,
          ),
        ],
      ),
    );
  }

  InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
    if (ctx.attribute.key != 'email') return null;

    return WidgetSpan(
      child: GestureDetector(
        onTap: () => _launchEmail(ctx.text),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.blue, width: 1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 14, color: Colors.blue),
              SizedBox(width: 4),
              Text(ctx.text,
                  style: ctx.textStyle?.copyWith(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    // Use url_launcher package to open email client
    print('Open email: $email');
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      controller: _controller,
      config: QuillEditorConfig(
        customWidgetSpanBuilder: _customBuilder,
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

### Example 3: URL Detection with Preview

```dart
class UrlEditor extends StatefulWidget {
  @override
  State<UrlEditor> createState() => _UrlEditorState();
}

class _UrlEditorState extends State<UrlEditor> {
  static const urlAttr = Attribute('url', AttributeScope.inline, 'url');

  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document()..insert(0, 'Visit https://flutter.dev for more info'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(
            r'https?://[^\s]+',
            urlAttr,
          ),
        ],
      ),
    );
  }

  InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
    if (ctx.attribute.key != 'url') return null;

    return WidgetSpan(
      child: GestureDetector(
        onTap: () => _openUrl(ctx.text),
        onLongPress: () => _showUrlPreview(ctx.text),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 14, color: Colors.blue),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  ctx.text,
                  style: ctx.textStyle?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    print('Open URL: $url');
    // Use url_launcher package
  }

  void _showUrlPreview(String url) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('URL Preview', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            SizedBox(height: 8),
            Text(url),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openUrl(url);
                  },
                  child: Text('Open'),
                ),
              ],
            ),
          ],
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
        customWidgetSpanBuilder: _customBuilder,
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

---

## Best Practices

### 1. Performance Considerations

- ✅ Keep regex patterns simple and efficient
- ✅ Avoid overly complex widget hierarchies in your custom spans
- ✅ Use `const` constructors where possible
- ❌ Don't use expensive operations in the widget span builder

### 2. Pattern Design

```dart
// ✅ GOOD: Specific, efficient patterns
PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr)
PatternMatcher.fromString(r'@[a-zA-Z0-9_]{1,15}', mentionAttr)

// ❌ BAD: Too greedy, can cause performance issues
PatternMatcher.fromString(r'.*', badAttr)
PatternMatcher.fromString(r'.+', badAttr)
```

### 3. Cursor Handling

- Always include zero-width spaces when using `WidgetSpan` to maintain proper cursor positioning
- The formula: `zeroWidthSpaceCount = textLength - 1`
- Test cursor positioning thoroughly when using custom widgets

### 4. Attribute Keys

```dart
// ✅ GOOD: Descriptive, unique keys
static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');
static const mentionAttr = Attribute('mention', AttributeScope.inline, 'mention');

// ❌ BAD: Generic or conflicting keys
static const attr1 = Attribute('custom', AttributeScope.inline, 'custom');
static const attr2 = Attribute('custom', AttributeScope.inline, 'custom'); // Conflict!
```

### 5. Error Handling

```dart
InlineSpan? _customWidgetSpanBuilder(
  BuildContext context,
  WidgetSpanContext spanContext,
) {
  try {
    if (spanContext.attribute.key == 'hashtag') {
      return _buildHashtagSpan(spanContext);
    }
  } catch (e) {
    // Log error but don't crash the editor
    debugPrint('Error building custom span: $e');
    return null; // Fall back to default rendering
  }
  return null;
}
```

### 6. Testing

Always test:

- ✅ Typing new patterns
- ✅ Editing existing patterns
- ✅ Deleting pattern text
- ✅ Cursor positioning within patterns
- ✅ Copy/paste behavior
- ✅ Interaction with other formatting (bold, italic, etc.)
- ✅ Multiple patterns in the same line
- ✅ Overlapping pattern scenarios

---

## Troubleshooting

### Issue: Patterns Not Being Detected

**Possible Causes:**

1. Regex pattern doesn't match your text
2. Pattern matchers not added to `QuillControllerConfig`
3. Attribute keys don't match between matcher and builder

**Solution:**

```dart
// Test your regex separately
void testRegex() {
  final pattern = RegExp(r'#[a-zA-Z0-9_]+');
  final text = '#flutter is awesome!';
  final matches = pattern.allMatches(text);
  print('Found ${matches.length} matches');
  for (final match in matches) {
    print('Match: ${match.group(0)}');
  }
}
```

### Issue: Cursor Position Is Wrong

**Cause:** Missing zero-width spaces when using `WidgetSpan`

**Solution:**

```dart
return TextSpan(
  children: [
    WidgetSpan(/* your widget */),
    // Add zero-width spaces
    for (var i = 0; i < textLength - 1; i++)
      const TextSpan(text: '\u200b'),
  ],
);
```

### Issue: Styles Not Applying

**Possible Causes:**

1. `customWidgetSpanBuilder` not passed to `QuillEditorConfig`
2. Builder returning `null` for your attribute
3. Attribute key mismatch

**Solution:**

```dart
// Verify configuration
QuillEditor(
  controller: _controller,
  config: QuillEditorConfig(
    customWidgetSpanBuilder: _customWidgetSpanBuilder, // ← Make sure this is set
  ),
)

// Add debug logging
InlineSpan? _customWidgetSpanBuilder(BuildContext context, WidgetSpanContext ctx) {
  print('Building span for attribute: ${ctx.attribute.key}'); // ← Debug

  if (ctx.attribute.key == 'hashtag') {
    return /* your custom span */;
  }
  return null;
}
```

### Issue: Tap Handlers Not Working

**Solution:** Use `GestureDetector` properly and handle existing recognizers:

```dart
WidgetSpan(
  child: GestureDetector(
    onTap: spanContext.recognizer is TapGestureRecognizer
        ? () => (spanContext.recognizer as TapGestureRecognizer).onTap?.call()
        : () {
            // Your custom tap handler
          },
    child: /* your widget */,
  ),
)
```

### Issue: Performance Problems with Many Patterns

**Solution:**

1. Simplify your regex patterns
2. Limit the number of pattern matchers
3. Use simpler widgets in your custom builder
4. Consider debouncing or throttling for real-time updates

```dart
// Example: Simpler widget hierarchy
WidgetSpan(
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    color: Colors.blue.withOpacity(0.1), // Use color instead of BoxDecoration when possible
    child: Text(ctx.text, style: ctx.textStyle),
  ),
)
```

---

## API Reference

### PatternMatcher

```dart
class PatternMatcher {
  const PatternMatcher({
    required RegExp pattern,
    required Attribute attribute,
    bool caseSensitive = true,
  });

  factory PatternMatcher.fromString(
    String patternString,
    Attribute attribute, {
    bool caseSensitive = true,
  });
}
```

### WidgetSpanContext

```dart
class WidgetSpanContext {
  const WidgetSpanContext({
    required String text,
    required Attribute attribute,
    required TextStyle? textStyle,
    GestureRecognizer? recognizer,
    int? cursorPositionInText,
  });
}
```

### CustomWidgetSpanBuilder

```dart
typedef CustomWidgetSpanBuilder = InlineSpan? Function(
  BuildContext context,
  WidgetSpanContext spanContext,
);
```

---

## Need Help?

- Check the example file: `example/lib/pattern_styling_example.dart`
- File an issue on GitHub
- Consult the Flutter Quill documentation

---

## License

This feature is part of Flutter Quill and follows the same license.
