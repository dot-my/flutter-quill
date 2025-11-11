import 'package:meta/meta.dart';

import '../common/pattern/pattern_matcher.dart';
import 'clipboard/quill_clipboard_config.dart';

export 'clipboard/quill_clipboard_config.dart';

class QuillControllerConfig {
  const QuillControllerConfig({
    this.requireScriptFontFeatures = false,
    @experimental this.clipboardConfig,
    this.patternMatchers = const [],
  });

  @experimental
  final QuillClipboardConfig? clipboardConfig;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;

  /// List of pattern matchers for automatic attribute application
  ///
  /// When text matches a pattern, the associated attribute will be automatically
  /// applied to the matched text.
  final List<PatternMatcher> patternMatchers;
}
