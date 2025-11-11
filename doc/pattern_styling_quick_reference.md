# Pattern Styling - Quick Reference

A fast reference guide for implementing pattern-based text styling in Flutter Quill.

---

## Minimal Implementation (3 Steps)

### 1. Define Attribute

```dart
static const myAttribute = Attribute('mykey', AttributeScope.inline, 'mykey');
```

### 2. Configure Controller

```dart
QuillController(
  document: Document(),
  selection: TextSelection.collapsed(offset: 0),
  config: QuillControllerConfig(
    patternMatchers: [
      PatternMatcher.fromString(
        r'your_regex_here',
        myAttribute,
      ),
    ],
  ),
);
```

### 3. Implement Custom Builder

```dart
InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
  if (ctx.attribute.key == 'mykey') {
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
  return null;
}

// In QuillEditor config:
QuillEditorConfig(
  customWidgetSpanBuilder: _customBuilder,
)
```

---

## Common Patterns

### Hashtags

```dart
// Attribute
static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');

// Pattern
PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr)
```

### Mentions

```dart
// Attribute
static const mentionAttr = Attribute('mention', AttributeScope.inline, 'mention');

// Pattern
PatternMatcher.fromString(r'@[a-zA-Z0-9_]+', mentionAttr)
```

### URLs

```dart
// Attribute
static const urlAttr = Attribute('url', AttributeScope.inline, 'url');

// Pattern
PatternMatcher.fromString(r'https?://[^\s]+', urlAttr)
```

### Emails

```dart
// Attribute
static const emailAttr = Attribute('email', AttributeScope.inline, 'email');

// Pattern
PatternMatcher.fromString(
  r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  emailAttr,
)
```

### Phone Numbers (US)

```dart
// Attribute
static const phoneAttr = Attribute('phone', AttributeScope.inline, 'phone');

// Pattern
PatternMatcher.fromString(
  r'\+?1?\s*\(?[0-9]{3}\)?[\s.-]?[0-9]{3}[\s.-]?[0-9]{4}',
  phoneAttr,
)
```

---

## Common Widget Styles

### Pill/Chip Style

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue),
  ),
  child: Text(ctx.text, style: ctx.textStyle),
)
```

### Underline Style

```dart
Container(
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
  child: Text(
    ctx.text,
    style: ctx.textStyle?.copyWith(color: Colors.blue),
  ),
)
```

### Badge Style

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    ctx.text,
    style: ctx.textStyle?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Icon + Text Style

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(Icons.tag, size: 14, color: Colors.blue),
    SizedBox(width: 4),
    Text(ctx.text, style: ctx.textStyle),
  ],
)
```

---

## Handling Interactions

### Simple Tap

```dart
WidgetSpan(
  child: GestureDetector(
    onTap: () {
      print('Tapped: ${ctx.text}');
    },
    child: /* your widget */,
  ),
)
```

### Tap + Long Press

```dart
GestureDetector(
  onTap: () => _handleTap(ctx.text),
  onLongPress: () => _handleLongPress(ctx.text),
  child: /* your widget */,
)
```

### Respecting Existing Recognizer

```dart
GestureDetector(
  onTap: ctx.recognizer is TapGestureRecognizer
      ? () => (ctx.recognizer as TapGestureRecognizer).onTap?.call()
      : () => _customTapHandler(ctx.text),
  child: /* your widget */,
)
```

---

## Cursor Support Template

Use this when you need proper cursor display within styled text:

```dart
InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
  if (ctx.attribute.key != 'mykey') return null;

  final text = ctx.text;
  final cursorPos = ctx.cursorPositionInText;
  final zeroWidthSpaceCount = text.length - 1;

  Widget textWidget;
  if (cursorPos != null && cursorPos >= 0 && cursorPos <= text.length) {
    // Show cursor
    final before = text.substring(0, cursorPos);
    final after = cursorPos < text.length ? text.substring(cursorPos) : '';

    textWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (before.isNotEmpty) Text(before, style: ctx.textStyle),
        Container(
          width: 2,
          height: (ctx.textStyle?.fontSize ?? 14) * 1.2,
          color: Colors.blue,
        ),
        if (after.isNotEmpty) Text(after, style: ctx.textStyle),
      ],
    );
  } else {
    textWidget = Text(text, style: ctx.textStyle);
  }

  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(/* your styling */),
          child: textWidget,
        ),
      ),
      for (var i = 0; i < zeroWidthSpaceCount; i++)
        const TextSpan(text: '\u200b'),
    ],
  );
}
```

---

## Multiple Patterns Example

```dart
class MyEditorState extends State<MyEditor> {
  // Define all attributes
  static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');
  static const mentionAttr = Attribute('mention', AttributeScope.inline, 'mention');
  static const urlAttr = Attribute('url', AttributeScope.inline, 'url');

  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document(),
      selection: TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr),
          PatternMatcher.fromString(r'@[a-zA-Z0-9_]+', mentionAttr),
          PatternMatcher.fromString(r'https?://[^\s]+', urlAttr),
        ],
      ),
    );
  }

  InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
    switch (ctx.attribute.key) {
      case 'hashtag':
        return _buildHashtag(ctx);
      case 'mention':
        return _buildMention(ctx);
      case 'url':
        return _buildUrl(ctx);
      default:
        return null;
    }
  }

  WidgetSpan _buildHashtag(WidgetSpanContext ctx) {
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

  WidgetSpan _buildMention(WidgetSpanContext ctx) {
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

  WidgetSpan _buildUrl(WidgetSpanContext ctx) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () => _openUrl(ctx.text),
        child: Text(
          ctx.text,
          style: ctx.textStyle?.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) {
    // Handle URL tap
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

## Debugging Checklist

- [ ] Attribute defined with unique key
- [ ] Pattern matcher added to `QuillControllerConfig.patternMatchers`
- [ ] Custom builder passed to `QuillEditorConfig.customWidgetSpanBuilder`
- [ ] Attribute key matches between matcher and builder
- [ ] Regex pattern tested and working
- [ ] Zero-width spaces added when using `WidgetSpan`
- [ ] Error handling in place

---

## Performance Tips

✅ **DO:**

- Use simple, specific regex patterns
- Keep widget hierarchy shallow
- Use `const` constructors
- Test with large documents

❌ **DON'T:**

- Use greedy patterns like `.*` or `.+`
- Create expensive widgets in the builder
- Perform async operations in the builder
- Nest multiple complex widgets

---

## Common Pitfalls

### 1. Wrong Cursor Position

**Problem:** Cursor appears in wrong place
**Solution:** Add zero-width spaces: `textLength - 1` times

### 2. Pattern Not Detected

**Problem:** Text doesn't get styled
**Solution:** Test regex separately, verify attribute keys match

### 3. Tap Not Working

**Problem:** GestureDetector doesn't respond
**Solution:** Check if recognizer exists, handle it properly

### 4. Performance Issues

**Problem:** Editor lags with patterns
**Solution:** Simplify regex, use simpler widgets

---

## Need More Details?

See the full guide: `doc/pattern_styling_guide.md`
