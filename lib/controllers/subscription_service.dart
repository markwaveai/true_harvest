import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/models/product_model.dart';
import 'package:task_new/models/subscription_plan_template.dart';

// Advanced subscription service provider
final subscriptionServiceProvider =
    ChangeNotifierProvider<SubscriptionController>((ref) {
      return SubscriptionController();
    });
final subscriptionPlansProvider = Provider<List<SubscriptionPlanTemplate>>((
  ref,
) {
  return SubscriptionPlanTemplate.getDefaultPlans();
});

class SubscriptionController extends ChangeNotifier {
  final List<AdvancedSubscription> _subscriptions = [];
  final List<DeliveryScheduleItem> _deliverySchedule = [];

  List<AdvancedSubscription> get subscriptions =>
      List.unmodifiable(_subscriptions);
  List<AdvancedSubscription> get activeSubscriptions =>
      _subscriptions.where((s) => s.isActive).toList();
  List<AdvancedSubscription> get pausedSubscriptions =>
      _subscriptions.where((s) => s.isPaused).toList();

  List<DeliveryScheduleItem> get deliverySchedule =>
      List.unmodifiable(_deliverySchedule);
  List<DeliveryScheduleItem> get todayDeliveries {
    final today = DateTime.now();
    return _deliverySchedule
        .where(
          (item) =>
              item.date.year == today.year &&
              item.date.month == today.month &&
              item.date.day == today.day &&
              item.isScheduled,
        )
        .toList();
  }

  // Create a new subscription
  Future<String> createSubscription({
    required String userId,
    required Product product,
    required String unit,
    required PlanType planType,
    required DeliveryPattern deliveryPattern,
    required DateTime startDate,
    int defaultQty = 1,
    List<String> weeklyDays = const [],
    List<CustomDeliveryDate> customDates = const [],
    required String deliveryAddress,
    String? deliveryInstructions,
    required PaymentMode paymentMode,
  }) async {
    try {
      // Calculate subscription details
      final subscriptionId = _generateSubscriptionId();
      final planTemplate = SubscriptionPlanTemplate.getDefaultPlans()
          .firstWhere((plan) => plan.planType == planType);

      final endDate = startDate.add(
        Duration(days: planTemplate.durationInDays),
      );
      final pricePerUnit = _getPricePerUnit(product, unit);
      final totalDeliveries = _calculateTotalDeliveries(
        startDate,
        endDate,
        deliveryPattern,
        weeklyDays,
        customDates,
        defaultQty,
      );

      final originalAmount = totalDeliveries * pricePerUnit;
      final discountAmount =
          originalAmount * (planTemplate.discountPercentage / 100);
      final totalAmount = originalAmount - discountAmount;

      final subscription = AdvancedSubscription(
        subscriptionId: subscriptionId,
        userId: userId,
        productId: product.id,
        productName: product.name,
        unit: unit,
        pricePerUnit: pricePerUnit,
        startDate: startDate,
        endDate: endDate,
        planType: planType,
        deliveryPattern: deliveryPattern,
        weeklyDays: weeklyDays,
        customDates: customDates,
        defaultQty: defaultQty,
        status: SubscriptionStatus.active,
        paymentMode: paymentMode,
        totalAmount: totalAmount,
        remainingDeliveries: totalDeliveries,
        deliveryAddress: deliveryAddress,
        deliveryInstructions: deliveryInstructions,
        createdAt: DateTime.now(),
      );

      _subscriptions.add(subscription);

      // Generate delivery schedule
      await _generateDeliverySchedule(subscription);

      notifyListeners();
      return subscriptionId;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  // Pause subscription
  Future<void> pauseSubscription(
    String subscriptionId,
    List<DateTime> pauseDates,
  ) async {
    try {
      final index = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
      if (index == -1) throw Exception('Subscription not found');

      final subscription = _subscriptions[index];
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.paused,
        pauseDates: [...subscription.pauseDates, ...pauseDates],
        pausedAt: DateTime.now(),
      );

      _subscriptions[index] = updatedSubscription;

      // Update delivery schedule
      await _updateDeliveryScheduleForPause(subscriptionId, pauseDates);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to pause subscription: $e');
    }
  }

  // Resume subscription
  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      final index = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
      if (index == -1) throw Exception('Subscription not found');

      final subscription = _subscriptions[index];
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.active,
        resumedAt: DateTime.now(),
      );

      _subscriptions[index] = updatedSubscription;

      // Regenerate delivery schedule from resume date
      await _generateDeliverySchedule(updatedSubscription);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to resume subscription: $e');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final index = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
      if (index == -1) throw Exception('Subscription not found');

      final subscription = _subscriptions[index];
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.cancelled,
      );

      _subscriptions[index] = updatedSubscription;

      // Cancel future deliveries
      await _cancelFutureDeliveries(subscriptionId);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Update subscription quantity
  Future<void> updateSubscriptionQuantity(
    String subscriptionId,
    int newQuantity,
  ) async {
    try {
      final index = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
      if (index == -1) throw Exception('Subscription not found');

      final subscription = _subscriptions[index];
      final updatedSubscription = subscription.copyWith(
        defaultQty: newQuantity,
      );

      _subscriptions[index] = updatedSubscription;

      // Update future delivery schedule
      await _updateDeliveryScheduleQuantity(subscriptionId, newQuantity);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update subscription quantity: $e');
    }
  }

  // Mark delivery as completed
  Future<void> markDeliveryCompleted(
    String subscriptionId,
    DateTime deliveryDate, {
    String? notes,
  }) async {
    try {
      final deliveryIndex = _deliverySchedule.indexWhere(
        (item) =>
            item.subscriptionId == subscriptionId &&
            _isSameDay(item.date, deliveryDate),
      );

      if (deliveryIndex == -1) throw Exception('Delivery not found');

      final delivery = _deliverySchedule[deliveryIndex];
      final updatedDelivery = delivery.copyWith(
        status: 'delivered',
        deliveredAt: DateTime.now(),
        deliveryNotes: notes,
      );

      _deliverySchedule[deliveryIndex] = updatedDelivery;

      // Update remaining deliveries count
      final subscriptionIndex = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
      if (subscriptionIndex != -1) {
        final subscription = _subscriptions[subscriptionIndex];
        final updatedSubscription = subscription.copyWith(
          remainingDeliveries: subscription.remainingDeliveries - 1,
        );
        _subscriptions[subscriptionIndex] = updatedSubscription;
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to mark delivery as completed: $e');
    }
  }

  // Get subscription by ID
  AdvancedSubscription? getSubscriptionById(String subscriptionId) {
    try {
      return _subscriptions.firstWhere(
        (s) => s.subscriptionId == subscriptionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user subscriptions
  List<AdvancedSubscription> getUserSubscriptions(String userId) {
    return _subscriptions.where((s) => s.userId == userId).toList();
  }

  // Get delivery schedule for date range
  List<DeliveryScheduleItem> getDeliveryScheduleForDateRange(
    DateTime from,
    DateTime to,
  ) {
    return _deliverySchedule
        .where(
          (item) =>
              item.date.isAfter(from.subtract(const Duration(days: 1))) &&
              item.date.isBefore(to.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Calculate subscription price
  double calculateSubscriptionPrice({
    required Product product,
    required String unit,
    required PlanType planType,
    required DeliveryPattern deliveryPattern,
    required DateTime startDate,
    required DateTime endDate,
    int defaultQty = 1,
    List<String> weeklyDays = const [],
    List<CustomDeliveryDate> customDates = const [],
  }) {
    final pricePerUnit = _getPricePerUnit(product, unit);
    final totalDeliveries = _calculateTotalDeliveries(
      startDate,
      endDate,
      deliveryPattern,
      weeklyDays,
      customDates,
      defaultQty,
    );

    final planTemplate = SubscriptionPlanTemplate.getDefaultPlans().firstWhere(
      (plan) => plan.planType == planType,
    );

    final originalAmount = totalDeliveries * pricePerUnit;
    final discountAmount =
        originalAmount * (planTemplate.discountPercentage / 100);

    return originalAmount - discountAmount;
  }

  // Private helper methods
  String _generateSubscriptionId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}';
  }

  double _getPricePerUnit(Product product, String unit) {
    try {
      return product.units.firstWhere((u) => u.unitName == unit).price;
    } catch (e) {
      return 0.0;
    }
  }

  int _calculateTotalDeliveries(
    DateTime startDate,
    DateTime endDate,
    DeliveryPattern pattern,
    List<String> weeklyDays,
    List<CustomDeliveryDate> customDates,
    int defaultQty,
  ) {
    switch (pattern) {
      case DeliveryPattern.daily:
        return endDate.difference(startDate).inDays * defaultQty;

      case DeliveryPattern.alternate:
        return (endDate.difference(startDate).inDays / 2).ceil() * defaultQty;

      case DeliveryPattern.weekly:
        final weeksInPeriod = (endDate.difference(startDate).inDays / 7).ceil();
        return weeksInPeriod * weeklyDays.length * defaultQty;

      case DeliveryPattern.monthly:
        final monthsInPeriod = (endDate.difference(startDate).inDays / 30)
            .ceil();
        return monthsInPeriod * defaultQty;

      case DeliveryPattern.custom:
        return customDates.fold(0, (sum, cd) => sum + cd.quantity);

      default:
        return 0;
    }
  }

  Future<void> _generateDeliverySchedule(
    AdvancedSubscription subscription,
  ) async {
    // Remove existing schedule for this subscription
    _deliverySchedule.removeWhere(
      (item) => item.subscriptionId == subscription.subscriptionId,
    );

    // Generate new schedule
    final schedule = subscription.generateDeliverySchedule(
      subscription.startDate,
      subscription.endDate,
    );

    _deliverySchedule.addAll(schedule);
  }

  Future<void> _updateDeliveryScheduleForPause(
    String subscriptionId,
    List<DateTime> pauseDates,
  ) async {
    for (final pauseDate in pauseDates) {
      final deliveryIndex = _deliverySchedule.indexWhere(
        (item) =>
            item.subscriptionId == subscriptionId &&
            _isSameDay(item.date, pauseDate),
      );

      if (deliveryIndex != -1) {
        final delivery = _deliverySchedule[deliveryIndex];
        final updatedDelivery = delivery.copyWith(status: 'cancelled');
        _deliverySchedule[deliveryIndex] = updatedDelivery;
      }
    }
  }

  Future<void> _cancelFutureDeliveries(String subscriptionId) async {
    final today = DateTime.now();
    for (int i = 0; i < _deliverySchedule.length; i++) {
      final delivery = _deliverySchedule[i];
      if (delivery.subscriptionId == subscriptionId &&
          delivery.date.isAfter(today) &&
          delivery.isScheduled) {
        _deliverySchedule[i] = delivery.copyWith(status: 'cancelled');
      }
    }
  }

  Future<void> _updateDeliveryScheduleQuantity(
    String subscriptionId,
    int newQuantity,
  ) async {
    final today = DateTime.now();
    for (int i = 0; i < _deliverySchedule.length; i++) {
      final delivery = _deliverySchedule[i];
      if (delivery.subscriptionId == subscriptionId &&
          delivery.date.isAfter(today) &&
          delivery.isScheduled) {
        _deliverySchedule[i] = delivery.copyWith(quantity: newQuantity);
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get subscription statistics
  Map<String, dynamic> getSubscriptionStats(String userId) {
    final userSubscriptions = getUserSubscriptions(userId);
    final activeCount = userSubscriptions.where((s) => s.isActive).length;
    final pausedCount = userSubscriptions.where((s) => s.isPaused).length;
    final completedCount = userSubscriptions.where((s) => s.isCompleted).length;

    final totalSavings = userSubscriptions.fold(0.0, (sum, sub) {
      final planTemplate = SubscriptionPlanTemplate.getDefaultPlans()
          .firstWhere((plan) => plan.planType == sub.planType);
      final originalAmount =
          sub.totalAmount / (1 - planTemplate.discountPercentage / 100);
      return sum + (originalAmount - sub.totalAmount);
    });

    return {
      'totalSubscriptions': userSubscriptions.length,
      'activeSubscriptions': activeCount,
      'pausedSubscriptions': pausedCount,
      'completedSubscriptions': completedCount,
      'totalSavings': totalSavings,
      'nextDeliveries': userSubscriptions
          .where((s) => s.isActive)
          .map((s) => s.nextDeliveryDate)
          .where((date) => date != null)
          .length,
    };
  }
}
