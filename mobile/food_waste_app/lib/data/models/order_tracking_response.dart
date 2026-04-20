import 'tracking_step.dart';

class OrderTrackingResponse {
  final String orderCode;
  final int minutesLeft;
  final String pickupCode;
  final List<TrackingStep> steps;

  OrderTrackingResponse({
    required this.orderCode,
    required this.minutesLeft,
    required this.pickupCode,
    required this.steps,
  });
}