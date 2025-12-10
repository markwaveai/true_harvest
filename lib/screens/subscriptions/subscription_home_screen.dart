import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/subscription_service.dart';
import 'package:task_new/models/advanced_subscription_model.dart';
import 'package:task_new/utils/app_colors.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionController = ref.watch(subscriptionServiceProvider);
    final activeSubscriptions = subscriptionController.activeSubscriptions;
    final todayDeliveries = subscriptionController.todayDeliveries;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.darkGreen,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Subscriptions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkGreen, AppColors.primary],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.subscriptions,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Today's Deliveries
          if (todayDeliveries.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Today's Deliveries",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final delivery = todayDeliveries[index];
                return _buildDeliveryCard(delivery, context);
              }, childCount: todayDeliveries.length),
            ),
          ],

          // Active Subscriptions
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                "My Subscriptions",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (activeSubscriptions.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final subscription = activeSubscriptions[index];
                return _buildSubscriptionCard(subscription, context);
              }, childCount: activeSubscriptions.length),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create subscription screen
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => const CreateSubscriptionScreen(),
          // ));
        },
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'New Subscription',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.darkGreen,
      ),
    );
  }

  Widget _buildSubscriptionCard(
    AdvancedSubscription subscription,
    BuildContext context,
  ) {
    final progress = subscription.completionPercentage / 100.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to subscription details
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SubscriptionDetailsScreen(
          //       subscription: subscription,
          //     ),
          //   ),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subscription.planType.toString().split('.').last,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        subscription.status,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subscription.status
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(subscription.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ---------- PRODUCT DETAILS ----------
              _buildDetailRow(
                'Product',
                '${subscription.productName} - ${subscription.unit}',
              ),
              _buildDetailRow('Price', '₹${subscription.pricePerUnit}/unit'),

              const SizedBox(height: 4),

              /// ---------- DELIVERY INFO ----------
              _buildDetailRow(
                'Next Delivery',
                subscription.nextDeliveryDate?.toString().split(' ')[0] ??
                    'N/A',
              ),
              _buildDetailRow(
                'Remaining',
                '${subscription.remainingDeliveries} deliveries',
              ),
              _buildDetailRow(
                'Progress',
                '${subscription.completionPercentage.toStringAsFixed(1)}%',
              ),

              const SizedBox(height: 8),

              /// ---------- PROGRESS BAR ----------
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(subscription.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    DeliveryScheduleItem delivery,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.local_shipping, color: Colors.white),
        ),
        title: Text('Delivery #${delivery.subscriptionId}'),
        subtitle: Text('Scheduled for ${delivery.deliveredAt}'),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () {
            // Mark as delivered
            // ref.read(subscriptionProvider.notifier).markAsDelivered(delivery.id);
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.red;
      case SubscriptionStatus.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getNextDeliveryDate(AdvancedSubscription subscription) {
    // Implement logic to get next delivery date
    // This is a simplified example
    return 'Tomorrow, 9:00 AM';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscriptions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey to fresh, organic products delivered to your doorstep',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create subscription screen
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) => const CreateSubscriptionScreen(),
                // ));
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
