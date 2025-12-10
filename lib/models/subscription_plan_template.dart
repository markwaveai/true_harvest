enum PlanType {
  daily,
  alternateDay,
  weekly,
  monthly,
  quarterly,
  halfYearly,
  annual,
  custom,
}

class SubscriptionPlanTemplate {
  final PlanType planType;
  final String name;
  final String description;
  final int durationInDays;
  final double discountPercentage;
  final List<String> features;

  SubscriptionPlanTemplate({
    required this.planType,
    required this.name,
    required this.description,
    required this.durationInDays,
    required this.discountPercentage,
    required this.features,
  });

  static List<SubscriptionPlanTemplate> getDefaultPlans() {
    return [
      // SubscriptionPlanTemplate(
      //   planType: PlanType.daily,
      //   name: 'Daily Delivery',
      //   description: 'Fresh delivery every day',
      //   durationInDays: 30,
      //   discountPercentage: 0,
      //   features: ['Daily fresh delivery', 'Flexible pause/resume', 'No commitment'],
      // ),
      // SubscriptionPlanTemplate(
      //   planType: PlanType.weekly,
      //   name: 'Weekly Plan',
      //   description: 'Choose your delivery days',
      //   durationInDays: 30,
      //   discountPercentage: 5,
      //   features: ['Choose delivery days', '5% discount', 'Flexible scheduling'],
      // ),
      SubscriptionPlanTemplate(
        planType: PlanType.monthly,
        name: 'Monthly Plan',
        description: 'Full month subscription',
        durationInDays: 30,
        discountPercentage: 10,
        features: ['10% discount', 'Priority delivery', 'Free pause/resume'],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.quarterly,
        name: 'Quarterly Plan',
        description: '3 months of savings',
        durationInDays: 90,
        discountPercentage: 15,
        features: ['15% discount', 'Priority support', 'Free delivery'],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.halfYearly,
        name: 'Half-Yearly Plan',
        description: '6 months of maximum savings',
        durationInDays: 180,
        discountPercentage: 20,
        features: [
          '20% discount',
          'VIP support',
          'Free delivery',
          'Bonus gifts',
        ],
      ),
      SubscriptionPlanTemplate(
        planType: PlanType.annual,
        name: 'Annual Plan',
        description: 'Best value for a full year',
        durationInDays: 365,
        discountPercentage: 25,
        features: [
          '25% discount',
          'VIP support',
          'Free delivery',
          'Monthly bonus',
        ],
      ),
    ];
  }
}
