import 'package:flutter/foundation.dart';

import '../../document/attribute.dart';

/// Represents a single pattern match result in text
@immutable
class PatternMatchResult {
  const PatternMatchResult({
    required this.text,
    required this.start,
    required this.end,
    required this.attribute,
  });

  /// The matched text
  final String text;

  /// Start position of the match in the document
  final int start;

  /// End position of the match in the document
  final int end;

  /// The attribute associated with this pattern
  final Attribute attribute;

  /// Length of the match
  int get length => end - start;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternMatchResult &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          start == other.start &&
          end == other.end &&
          attribute == other.attribute;

  @override
  int get hashCode =>
      text.hashCode ^ start.hashCode ^ end.hashCode ^ attribute.hashCode;

  @override
  String toString() =>
      'PatternMatchResult(text: $text, start: $start, end: $end, attribute: ${attribute.key})';
}

/// Defines a pattern to match in text and its associated attribute
@immutable
class PatternMatcher {
  const PatternMatcher({
    required this.pattern,
    required this.attribute,
    this.caseSensitive = true,
  });

  /// Regular expression pattern to match
  final RegExp pattern;

  /// Attribute to apply to matched text
  final Attribute attribute;

  /// Whether pattern matching is case sensitive
  final bool caseSensitive;

  /// Convenience constructor for string patterns
  factory PatternMatcher.fromString(
    String patternString,
    Attribute attribute, {
    bool caseSensitive = true,
  }) {
    return PatternMatcher(
      pattern: RegExp(patternString, caseSensitive: caseSensitive),
      attribute: attribute,
      caseSensitive: caseSensitive,
    );
  }

  /// Find all matches of this pattern in the given text
  /// Returns list of [PatternMatchResult] with absolute positions based on [baseOffset]
  List<PatternMatchResult> findMatches(String text, int baseOffset) {
    final matches = <PatternMatchResult>[];
    final regexMatches = pattern.allMatches(text);

    for (final match in regexMatches) {
      matches.add(PatternMatchResult(
        text: match.group(0)!,
        start: baseOffset + match.start,
        end: baseOffset + match.end,
        attribute: attribute,
      ));
    }

    return matches;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternMatcher &&
          runtimeType == other.runtimeType &&
          pattern.pattern == other.pattern.pattern &&
          attribute == other.attribute &&
          caseSensitive == other.caseSensitive;

  @override
  int get hashCode =>
      pattern.pattern.hashCode ^ attribute.hashCode ^ caseSensitive.hashCode;

  @override
  String toString() =>
      'PatternMatcher(pattern: ${pattern.pattern}, attribute: ${attribute.key})';
}

/// Manager for multiple pattern matchers
class PatternMatcherManager {
  PatternMatcherManager(this.matchers);

  /// List of pattern matchers to apply
  final List<PatternMatcher> matchers;

  /// Find all pattern matches in the given text range
  /// Returns a list of all matches from all matchers, sorted by position
  List<PatternMatchResult> findAllMatches(String text, int baseOffset) {
    final allMatches = <PatternMatchResult>[];

    for (final matcher in matchers) {
      allMatches.addAll(matcher.findMatches(text, baseOffset));
    }

    // Sort matches by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    return allMatches;
  }

  /// Check if any matcher handles the given attribute
  bool hasMatcherForAttribute(Attribute attribute) {
    return matchers.any((m) => m.attribute.key == attribute.key);
  }

  /// Get matcher for a specific attribute
  PatternMatcher? getMatcherForAttribute(Attribute attribute) {
    try {
      return matchers.firstWhere((m) => m.attribute.key == attribute.key);
    } catch (e) {
      return null;
    }
  }
}

