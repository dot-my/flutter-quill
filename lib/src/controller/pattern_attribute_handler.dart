import 'dart:async';

import '../common/pattern/pattern_matcher.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import '../document/nodes/leaf.dart';
import '../document/structs/doc_change.dart';

/// Handles automatic application of attributes based on pattern matching
///
/// This class listens to document changes and automatically applies
/// custom attributes to text that matches configured patterns.
class PatternAttributeHandler {
  PatternAttributeHandler({
    required this.document,
    required List<PatternMatcher> patternMatchers,
  }) : _manager = PatternMatcherManager(patternMatchers) {
    _subscription = document.changes.listen(_handleDocumentChange);
    // Process existing document content
    Future.microtask(() {
      if (document.length > 0) {
        processEntireDocument();
      }
    });
  }

  final Document document;
  final PatternMatcherManager _manager;
  StreamSubscription<DocChange>? _subscription;

  /// Whether the handler is currently processing changes
  /// Used to prevent infinite loops when applying attributes
  bool _isProcessing = false;

  /// Handle document changes and apply pattern-based attributes
  void _handleDocumentChange(DocChange change) {
    // Prevent processing our own changes
    if (_isProcessing) {
      return;
    }

    // Only process local changes (user input)
    if (change.source != ChangeSource.local) {
      return;
    }

    final delta = change.change;
    if (delta.isEmpty) {
      return;
    }

    try {
      // Calculate the affected range
      var offset = 0;
      int? changeStart;
      int? changeEnd;

      for (final op in delta.toList()) {
        if (op.isInsert) {
          changeStart ??= offset;
          final length = op.length ?? 0;
          changeEnd = offset + length;
          offset += length;
        } else if (op.isDelete) {
          changeStart ??= offset;
          changeEnd = offset;
          // Don't increment offset for deletes
        } else if (op.isRetain) {
          offset += op.length ?? 0;
        }
      }

      if (changeStart == null || changeEnd == null) {
        return;
      }

      // Get the affected line(s) and process them
      _processRange(changeStart, changeEnd);
    } catch (e) {
      // Silently ignore errors to prevent blocking user input
      // Pattern matching is a nice-to-have feature and shouldn't break typing
    }
  }

  /// Process a range of text for pattern matches
  void _processRange(int start, int end) {
    try {
      // Ensure we're not processing too late
      if (start >= document.length) {
        return;
      }

      // Find the line(s) containing the changed text
      final startNode = document.queryChild(start);
      if (startNode.node == null) {
        return;
      }

      // Get the entire line to check for patterns
      final line = startNode.node!;
      final lineOffset = line.documentOffset;
      final lineLength = line.length;

      // Safety check
      if (lineLength <= 0) {
        return;
      }

      // Get the plain text of the line
      final lineText = _getLineText(line, lineOffset);

      // Find all pattern matches in this line
      final matches = _manager.findAllMatches(lineText, lineOffset);

      // Apply attributes to matches
      _applyMatches(matches, lineOffset, lineLength);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Get plain text from a line
  String _getLineText(dynamic node, int offset) {
    try {
      final buffer = StringBuffer();
      
      // Get the line node and iterate through its children
      final children = node.children;
      if (children != null) {
        for (final child in children) {
          if (child is QuillText) {
            buffer.write(child.value);
          }
        }
      }
      
      // Remove trailing newline if present
      final text = buffer.toString();
      if (text.endsWith('\n')) {
        return text.substring(0, text.length - 1);
      }
      
      return text;
    } catch (e) {
      return '';
    }
  }

  /// Apply attributes to matched patterns
  void _applyMatches(
    List<PatternMatchResult> matches,
    int lineOffset,
    int lineLength,
  ) {
    _isProcessing = true;
    try {
      // First, clear any existing pattern attributes from the entire line
      _clearLinePatternAttributes(lineOffset, lineLength);

      // Then apply new pattern attributes to matches
      if (matches.isNotEmpty) {
        for (final match in matches) {
          final matchLength = match.length;
          if (matchLength > 0 && match.start + matchLength <= document.length) {
            try {
              document.format(match.start, matchLength, match.attribute);
            } catch (e) {
              // Ignore errors for individual matches
            }
          }
        }
      }
    } catch (e) {
      // Ensure we always reset the flag
    } finally {
      _isProcessing = false;
    }
  }

  /// Clear pattern attributes from a line
  void _clearLinePatternAttributes(int offset, int length) {
    // Safety check
    if (length <= 1) {
      return;
    }

    // Get all attributes managed by our matchers
    final managedAttributes = _manager.matchers.map((m) => m.attribute).toList();

    for (final attr in managedAttributes) {
      try {
        // Format with null value to remove the attribute
        final unsetAttr = Attribute(attr.key, attr.scope, null);
        document.format(offset, length - 1, unsetAttr); // -1 to exclude newline
      } catch (e) {
        // Ignore errors when clearing individual attributes
      }
    }
  }

  /// Manually trigger pattern detection for a specific range
  /// Useful for initialization or reprocessing
  void processRange(int start, int end) {
    _processRange(start, end);
  }

  /// Process the entire document for pattern matches
  void processEntireDocument() {
    final length = document.length;
    if (length > 0) {
      _processRange(0, length);
    }
  }

  /// Dispose of this handler
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

