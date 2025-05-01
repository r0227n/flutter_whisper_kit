import 'dart:convert';

/// Represents a progress object with information about an ongoing task.
class Progress {
  const Progress({
    this.totalUnitCount = 0,
    this.completedUnitCount = 0,
    this.fractionCompleted = 0.0,
    this.isIndeterminate = false,
    this.isPaused = false,
    this.isCancelled = false,
  });

  /// The total number of units in the task.
  final int totalUnitCount;

  /// The number of completed units.
  final int completedUnitCount;

  /// The progress as a fraction (0.0 to 1.0).
  final double fractionCompleted;

  /// Whether the progress is indeterminate.
  final bool isIndeterminate;

  /// Whether the progress is paused.
  final bool isPaused;

  /// Whether the progress is cancelled.
  final bool isCancelled;

  /// Creates a [Progress] from a JSON map.
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      totalUnitCount: json['totalUnitCount'] as int? ?? 0,
      completedUnitCount: json['completedUnitCount'] as int? ?? 0,
      fractionCompleted: (json['fractionCompleted'] as num?)?.toDouble() ?? 0.0,
      isIndeterminate: json['isIndeterminate'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      isCancelled: json['isCancelled'] as bool? ?? false,
    );
  }

  /// Converts this [Progress] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'totalUnitCount': totalUnitCount,
      'completedUnitCount': completedUnitCount,
      'fractionCompleted': fractionCompleted,
      'isIndeterminate': isIndeterminate,
      'isPaused': isPaused,
      'isCancelled': isCancelled,
    };
  }
}
