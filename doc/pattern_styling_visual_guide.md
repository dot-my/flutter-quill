# Pattern Styling - Visual Integration Guide

A visual, step-by-step guide to understanding and implementing pattern styling in Flutter Quill.

---

## 🎯 What Is Pattern Styling?

Pattern styling automatically detects text patterns (like #hashtags, @mentions, URLs) and renders them with custom styling and interactions.

### Before Pattern Styling
```
Plain text: Try #flutter and contact @john at https://example.com
```

### After Pattern Styling
```
Styled text: Try [#flutter] and contact [@john] at [https://example.com]
                   ^^^^^^^^           ^^^^^^        ^^^^^^^^^^^^^^^^^^^^
                   Blue pill          Purple pill   Blue underlined link
```

---

## 🔄 How It Works - Flow Diagram

```
┌─────────────────┐
│   User Types    │
│   "#flutter"    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  PatternMatcher         │
│  Detects pattern with   │
│  regex: r'#[a-zA-Z0-9_]+' │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ PatternAttributeHandler │
│ Applies 'hashtag'       │
│ attribute to matched    │
│ text                    │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ CustomWidgetSpanBuilder │
│ Renders with custom     │
│ WidgetSpan (blue pill   │
│ with border)            │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Styled Text           │
│   [#flutter]            │
│   (clickable blue pill) │
└─────────────────────────┘
```

---

## 📦 Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                    QuillController                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │        QuillControllerConfig                    │   │
│  │  ┌───────────────────────────────────────┐     │   │
│  │  │     patternMatchers: [                │     │   │
│  │  │       PatternMatcher(                 │     │   │
│  │  │         pattern: r'#[a-zA-Z0-9_]+',   │     │   │
│  │  │         attribute: hashtagAttr,       │     │   │
│  │  │       ),                              │     │   │
│  │  │     ]                                 │     │   │
│  │  └───────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │    PatternAttributeHandler (automatic)          │   │
│  │    • Listens to document changes                │   │
│  │    • Applies attributes when patterns match     │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────┐
│                      QuillEditor                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │        QuillEditorConfig                        │   │
│  │  ┌───────────────────────────────────────┐     │   │
│  │  │   customWidgetSpanBuilder:            │     │   │
│  │  │     _customWidgetSpanBuilder          │     │   │
│  │  └───────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  Rendering Pipeline:                                    │
│  Text → Detect Attributes → Custom Builder → Display   │
└──────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────┐
│         Your Custom Widget Span Builder                  │
│                                                          │
│  InlineSpan? _customWidgetSpanBuilder(                  │
│    BuildContext context,                                │
│    WidgetSpanContext spanContext,                       │
│  ) {                                                    │
│    if (spanContext.attribute.key == 'hashtag') {       │
│      return WidgetSpan(                                │
│        child: Container(/* styled widget */),          │
│      );                                                │
│    }                                                    │
│    return null; // Use default rendering               │
│  }                                                      │
└──────────────────────────────────────────────────────────┘
```

---

## 🎨 Component Breakdown

### 1️⃣ Attribute Definition

```dart
┌─────────────────────────────────────────┐
│  static const hashtagAttribute =        │
│    Attribute(                           │
│      'hashtag',              ◄── Unique key (identifier)
│      AttributeScope.inline,  ◄── Always use inline
│      'hashtag',              ◄── Value (usually same as key)
│    );                                   │
└─────────────────────────────────────────┘
```

**Purpose:** Creates a unique identifier that connects pattern detection to rendering.

### 2️⃣ Pattern Matcher

```dart
┌─────────────────────────────────────────┐
│  PatternMatcher.fromString(             │
│    r'#[a-zA-Z0-9_]+',      ◄── Regex pattern
│    hashtagAttribute,        ◄── Links to attribute
│    caseSensitive: false,   ◄── Optional: case sensitivity
│  )                                      │
└─────────────────────────────────────────┘
```

**Purpose:** Defines what text to detect and which attribute to apply.

**Regex Breakdown:**
```
#              ◄── Literal hash symbol
[a-zA-Z0-9_]+  ◄── One or more alphanumeric chars or underscore
```

### 3️⃣ Custom Widget Builder

```dart
┌─────────────────────────────────────────────────────┐
│  InlineSpan? _customWidgetSpanBuilder(              │
│    BuildContext context,                            │
│    WidgetSpanContext spanContext, ◄── Contains:    │
│  ) {                                  • text       │
│    if (spanContext.attribute.key == 'hashtag') {   • attribute   │
│      return WidgetSpan(               • textStyle  │
│        child: Container(              • recognizer │
│          // Your custom styling       • cursorPos  │
│        ),                                          │
│      );                                            │
│    }                                               │
│    return null; // Fallback to default            │
│  }                                                  │
└─────────────────────────────────────────────────────┘
```

**Purpose:** Decides how matched patterns should be rendered.

---

## 🎨 Styling Examples Visualized

### Example 1: Pill/Chip Style
```
┌──────────────┐
│  #flutter    │  ◄── Blue background
└──────────────┘      Rounded corners
                      Border

Code:
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.15),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: Colors.blue),
  ),
  child: Text('#flutter'),
)
```

### Example 2: Underlined Link Style
```
https://flutter.dev
──────────────────  ◄── Blue underline

Code:
Container(
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
  child: Text('https://flutter.dev'),
)
```

### Example 3: Badge with Gradient
```
┌──────────────┐
│  #trending   │  ◄── Blue-to-purple gradient
└──────────────┘      White text, rounded

Code:
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text('#trending', style: TextStyle(color: Colors.white)),
)
```

### Example 4: Icon + Text
```
🏷️ #flutter  ◄── Icon before text

Code:
Row(
  children: [
    Icon(Icons.tag, size: 14),
    SizedBox(width: 4),
    Text('#flutter'),
  ],
)
```

---

## 🖱️ Interaction Flow

### Simple Tap Handler

```
User sees: [#flutter]
           ↓
User taps
           ↓
GestureDetector.onTap
           ↓
Your handler: _handleTap('#flutter')
           ↓
Navigate / Show Dialog / etc.
```

**Code:**
```dart
GestureDetector(
  onTap: () {
    print('Tapped: ${spanContext.text}');
    // Navigate to hashtag search
    // Show dialog
    // Copy to clipboard
    // etc.
  },
  child: Container(/* styled widget */),
)
```

---

## 🎯 Multiple Patterns Example

### Visual Representation

```
Input:  "Check @john's post on #flutter at https://flutter.dev"

After pattern matching:
        "Check [@john]'s post on [#flutter] at [https://flutter.dev]"
               ^^^^^^              ^^^^^^^^      ^^^^^^^^^^^^^^^^^^
               Purple pill         Blue pill     Blue underlined link
               (mention)           (hashtag)     (url)
```

### Code Structure

```dart
// 1. Define attributes
static const hashtagAttr = Attribute('hashtag', AttributeScope.inline, 'hashtag');
static const mentionAttr = Attribute('mention', AttributeScope.inline, 'mention');
static const urlAttr = Attribute('url', AttributeScope.inline, 'url');

// 2. Configure matchers
patternMatchers: [
  PatternMatcher.fromString(r'#[a-zA-Z0-9_]+', hashtagAttr),
  PatternMatcher.fromString(r'@[a-zA-Z0-9_]+', mentionAttr),
  PatternMatcher.fromString(r'https?://[^\s]+', urlAttr),
]

// 3. Build different styles
InlineSpan? _customBuilder(BuildContext context, WidgetSpanContext ctx) {
  switch (ctx.attribute.key) {
    case 'hashtag':  return _buildBlueChip(ctx);
    case 'mention':  return _buildPurpleChip(ctx);
    case 'url':      return _buildUnderlinedLink(ctx);
    default:         return null;
  }
}
```

---

## ⚡ Quick Integration Checklist

```
Setup Phase:
├─ □ Define custom attribute(s)
├─ □ Create PatternMatcher(s) with regex
├─ □ Add matchers to QuillControllerConfig
└─ □ Implement customWidgetSpanBuilder

Implementation Phase:
├─ □ Check attribute key in builder
├─ □ Return WidgetSpan with custom styling
├─ □ Add GestureDetector for interactions (optional)
└─ □ Add zero-width spaces for cursor support (if using WidgetSpan)

Testing Phase:
├─ □ Type new patterns
├─ □ Edit existing patterns
├─ □ Delete patterns
├─ □ Test cursor positioning
├─ □ Test tap/long-press handlers
└─ □ Test with other formatting (bold, italic, etc.)
```

---

## 🐛 Debugging Visual Guide

### Problem: Pattern Not Detected

```
Input:     #flutter
Expected:  [#flutter]  (styled)
Actual:    #flutter    (plain text)

Debug Steps:
1. Test regex separately ──┐
2. Check matchers list ────┼─→ Pattern should match
3. Verify attribute keys ──┘
```

### Problem: Wrong Cursor Position

```
Typing "fl" in #flutter:

Wrong:  #flutte|r    ◄── Cursor shifted
               └─ cursor

Correct: #fl|utter   ◄── Cursor in correct position
            └─ cursor

Solution: Add zero-width spaces
for (var i = 0; i < textLength - 1; i++)
  const TextSpan(text: '\u200b'),
```

---

## 📚 Documentation Navigation

```
┌─────────────────────────────────────────────────────┐
│              Documentation Structure                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Start Here (choose one):                          │
│  ├─ 📘 Pattern Styling Guide (COMPREHENSIVE)       │
│  │   └─ Full explanations, examples, troubleshooting
│  │                                                  │
│  ├─ 📗 Quick Reference (LOOKUP)                    │
│  │   └─ Code snippets, patterns, templates         │
│  │                                                  │
│  ├─ 📙 Configuration Doc (QUICK START)             │
│  │   └─ Basic setup, common use cases              │
│  │                                                  │
│  └─ 📕 Example Code (HANDS-ON)                     │
│      └─ Complete working Flutter app               │
│                                                     │
│  Additional Resources:                             │
│  ├─ Integration Summary                            │
│  │   └─ Overview of all components                 │
│  │                                                  │
│  └─ Visual Guide (THIS FILE)                       │
│      └─ Diagrams and visual explanations           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎓 Learning Path

```
Beginner Path:
1. Read: Configuration Doc (doc/configurations/pattern_styling.md)
2. Run: Example App (example/lib/pattern_styling_example.dart)
3. Try: Modify the example with your own pattern
4. Reference: Quick Reference when coding

Intermediate Path:
1. Read: Pattern Styling Guide (doc/pattern_styling_guide.md)
2. Study: Advanced customization sections
3. Implement: Multiple patterns in your app
4. Add: Custom interactions and styling

Advanced Path:
1. Explore: Source code (lib/src/common/pattern/, lib/src/controller/)
2. Implement: Complex regex patterns
3. Optimize: Performance for large documents
4. Extend: Create custom pattern behaviors
```

---

## 🎨 Common Styling Patterns Reference

```
┌────────────────────────────────────────────────────────────┐
│ Pill/Chip        │  [#tag]      │ padding + rounded border │
│ Underlined Link  │  link        │ bottom border            │
│                  │  ─────                                   │
│ Badge            │  [Badge]     │ solid background         │
│ Icon + Text      │  🏷️ text     │ icon prefix              │
│ Outlined         │  ┌────┐      │ border, no background    │
│                  │  │text│                                 │
│                  │  └────┘                                 │
│ Gradient         │  [░▒▓text]   │ gradient background      │
└────────────────────────────────────────────────────────────┘
```

---

## ✅ Success Criteria

Your implementation is successful when:

- ✅ Patterns are detected as you type
- ✅ Matched text shows custom styling
- ✅ Cursor moves correctly within styled text
- ✅ Tap/interactions work as expected
- ✅ Styles combine with other formatting (bold, italic, etc.)
- ✅ Copy/paste preserves patterns
- ✅ No performance issues with normal-sized documents

---

**Need Help?**

- 📘 Detailed Guide: `doc/pattern_styling_guide.md`
- 📗 Code Snippets: `doc/pattern_styling_quick_reference.md`
- 📙 Quick Start: `doc/configurations/pattern_styling.md`
- 📕 Working Example: `example/lib/pattern_styling_example.dart`

---

**Happy Coding! 🚀**

