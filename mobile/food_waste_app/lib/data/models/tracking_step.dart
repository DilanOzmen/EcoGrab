class TrackingStep {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final String? completedAt;

  TrackingStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isCurrent,
    this.completedAt,
  });
}