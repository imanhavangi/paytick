import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';
import '../controller/navigation_controller.dart';
import '../model/payment.dart';
import '../utils/date_utils.dart';
import 'add_payment_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();
    final navController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const AddPaymentPage()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to PayTick',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your recurring payments with ease',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildStatCard(
                        context,
                        'Total Payments',
                        controller.payments.length.toString(),
                        Icons.payment,
                        Colors.blue,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildStatCard(
                        context,
                        'This Month',
                        '\$${controller.totalDueThisMonth.toStringAsFixed(0)}',
                        Icons.calendar_month,
                        Colors.green,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildStatCard(
                        context,
                        'Overdue',
                        controller.payments
                            .where((p) => isOverdue(p.nextDue))
                            .length
                            .toString(),
                        Icons.warning,
                        Colors.red,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildStatCard(
                        context,
                        'Due Today',
                        controller.payments
                            .where((p) => isDueToday(p.nextDue))
                            .length
                            .toString(),
                        Icons.today,
                        Colors.orange,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Payments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Payments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => navController.changePage(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final upcomingPayments = controller.payments
                  .where((p) => p.nextDue.isAfter(
                      DateTime.now().subtract(const Duration(days: 1))))
                  .take(3)
                  .toList();

              if (upcomingPayments.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming payments',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                Get.to(() => const AddPaymentPage()),
                            child: const Text('Add your first payment'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: upcomingPayments.map((payment) {
                  final isOverduePayment = isOverdue(payment.nextDue);
                  final isDueTodayPayment = isDueToday(payment.nextDue);

                  Color? cardColor;
                  if (isOverduePayment) {
                    cardColor = Colors.red.withValues(alpha: 0.1);
                  } else if (isDueTodayPayment) {
                    cardColor = Colors.orange.withValues(alpha: 0.1);
                  }

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOverduePayment
                            ? Colors.red
                            : isDueTodayPayment
                                ? Colors.orange
                                : Theme.of(context).primaryColor,
                        child: Text(
                          payment.clientName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        payment.clientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${payment.formattedAmount} • ${payment.frequency.displayName}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatDateShort(payment.nextDue),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isOverduePayment
                                  ? Colors.red
                                  : isDueTodayPayment
                                      ? Colors.orange
                                      : null,
                            ),
                          ),
                          if (isOverduePayment)
                            const Text('Overdue',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12))
                          else if (isDueTodayPayment)
                            const Text('Due Today',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 12)),
                        ],
                      ),
                      onTap: () =>
                          Get.to(() => AddPaymentPage(editPayment: payment)),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
