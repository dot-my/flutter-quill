import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Example demonstrating custom pattern-based text styling with WidgetSpan
///
/// This example shows how to:
/// 1. Define custom attributes for pattern matching
/// 2. Configure pattern matchers to detect hashtags (#tagname)
/// 3. Render matched patterns with custom WidgetSpan (padding, borders, background)
/// 4. Handle interactions (taps) on styled patterns
class PatternStylingExample extends StatefulWidget {
  const PatternStylingExample({super.key});

  @override
  State<PatternStylingExample> createState() => _PatternStylingExampleState();
}

class _PatternStylingExampleState extends State<PatternStylingExample> {
  // Define a custom attribute for hashtags
  static const hashtagAttribute =
      Attribute('hashtag', AttributeScope.inline, 'hashtag');

  late final QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Create controller with pattern matchers configured
    _controller = QuillController(
      document: Document()
        ..insert(0,
            'Try typing hashtags like #flutter #dart #awesome!\n\nYou can also mix them with #bold text and other formatting.'),
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        patternMatchers: [
          // Match hashtags: # followed by alphanumeric characters and underscores
          PatternMatcher.fromString(
            r'#[a-zA-Z0-9_]+',
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
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  /// Custom widget span builder that renders hashtags with special styling
  InlineSpan? _customWidgetSpanBuilder(
    BuildContext context,
    WidgetSpanContext spanContext,
  ) {
    // Only handle our hashtag attribute
    if (spanContext.attribute.key != 'hashtag') {
      return null;
    }

    final text = spanContext.text;
    final textLength = text.length;
    final cursorPos = spanContext.cursorPositionInText;

    // Fix cursor position issue with WidgetSpan
    // WidgetSpan counts as 1 character, but the original text was longer
    // We need to add zero-width spaces to maintain cursor position
    // Number of zero-width spaces = original text length - 1 (for the WidgetSpan itself)
    final zeroWidthSpaceCount = textLength - 1;

    // Build the text with cursor line if cursor is in this span
    Widget textWidget;
    if (cursorPos != null && cursorPos >= 0 && cursorPos <= textLength) {
      // Cursor is within this text, show a cursor line before the character at cursor position
      final beforeCursor = text.substring(0, cursorPos);
      final atCursorAndAfter =
          cursorPos < text.length ? text.substring(cursorPos) : '';

      textWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (beforeCursor.isNotEmpty)
            Text(
              beforeCursor,
              style: spanContext.textStyle?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          // Draw cursor line
          Container(
            width: 2,
            height: (spanContext.textStyle?.fontSize ?? 14) * 1.2,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          if (atCursorAndAfter.isNotEmpty)
            Text(
              atCursorAndAfter,
              style: spanContext.textStyle?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    } else {
      // No cursor in this span, render normally
      textWidget = Text(
        text,
        style: spanContext.textStyle?.copyWith(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: spanContext.recognizer is TapGestureRecognizer
                ? () => (spanContext.recognizer as TapGestureRecognizer)
                    .onTap
                    ?.call()
                : () {
                    // Custom tap handler for hashtags
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on $text'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                // Gradient background
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.15),
                    Colors.purple.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Rounded corners
                borderRadius: BorderRadius.circular(6),
                // Border
                border: Border.all(
                  color: Colors.blue.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: textWidget,
            ),
          ),
        ),
        // Add zero-width spaces to maintain proper cursor position
        // WidgetSpan = 1 char, but original text was longer
        // So we need (textLength - 1) zero-width spaces
        for (var i = 0; i < zeroWidthSpaceCount; i++)
          const TextSpan(text: '\u200b'), // Zero-width space (U+200B)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Styling Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Pattern Styling Demo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Type hashtags (e.g., #flutter) and they will automatically be styled with padding, borders, and a gradient background!',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Example: ',
                              style: TextStyle(fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.15),
                                  Colors.purple.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '#flutter',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar
            QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
              ),
            ),

            // Editor
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QuillEditor(
                  focusNode: _editorFocusNode,
                  scrollController: _editorScrollController,
                  controller: _controller,
                  config: QuillEditorConfig(
                    placeholder: 'Start typing... Try #hashtags!',
                    padding: EdgeInsets.zero,
                    customWidgetSpanBuilder: _customWidgetSpanBuilder,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example showing how to use pattern styling as main app
void main() {
  runApp(const PatternStylingApp());
}

class PatternStylingApp extends StatelessWidget {
  const PatternStylingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pattern Styling Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      home: const PatternStylingExample(),
    );
  }
}
