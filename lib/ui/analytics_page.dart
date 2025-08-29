import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';
import '../model/payment.dart';
import '../model/payment_history.dart';
import '../utils/date_utils.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Period',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        'This Month',
                        'Last Month',
                        'This Year',
                        'All Time',
                      ]
                          .map((period) => FilterChip(
                                label: Text(period),
                                selected: _selectedPeriod == period,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedPeriod = period;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Income Summary
            Obx(() {
              final income = _calculateIncome(controller.paymentHistory);
              final projectedIncome =
                  _calculateProjectedIncome(controller.payments);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income Summary',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Received',
                              '\$${income.toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.green,
                              context,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Projected',
                              '\$${projectedIncome.toStringAsFixed(2)}',
                              Icons.schedule,
                              Colors.blue,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Payment Frequency Analysis
            Obx(() {
              final frequencyData =
                  _analyzePaymentFrequency(controller.payments);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Frequency',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      ...frequencyData.entries.map((entry) {
                        final percentage = controller.payments.isEmpty
                            ? 0.0
                            : (entry.value / controller.payments.length) * 100;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${entry.value} payments (${percentage.toStringAsFixed(1)}%)',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  entry.key == PaymentFrequency.monthly
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Top Clients
            Obx(() {
              final topClients = _getTopClients(controller.payments);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Clients by Value',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      if (topClients.isEmpty)
                        Center(
                          child: Text(
                            'No clients data available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      else
                        ...topClients.take(5).map((client) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                client['name'].substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              client['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              '\$${client['amount'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Overdue Analysis
            Obx(() {
              final overduePayments = controller.payments
                  .where((p) => isOverdue(p.nextDue))
                  .toList();
              final overdueAmount =
                  overduePayments.fold(0.0, (sum, p) => sum + p.amount);

              return Card(
                color: overduePayments.isNotEmpty
                    ? Colors.red.withValues(alpha: 0.05)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: overduePayments.isNotEmpty
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Overdue Payments',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: overduePayments.isNotEmpty
                                      ? Colors.red
                                      : null,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Count',
                              overduePayments.length.toString(),
                              Icons.payment,
                              Colors.red,
                              context,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Amount',
                              '\$${overdueAmount.toStringAsFixed(2)}',
                              Icons.attach_money,
                              Colors.red,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateIncome(List<PaymentHistory> history) {
    final filteredHistory = _filterByPeriod(history);
    return filteredHistory.fold(0.0, (sum, h) => sum + h.amount);
  }

  double _calculateProjectedIncome(List<Payment> payments) {
    final now = DateTime.now();
    var total = 0.0;

    for (final payment in payments) {
      switch (_selectedPeriod) {
        case 'This Month':
          if (isInCurrentMonth(payment.nextDue)) {
            total += payment.amount;
          }
          break;
        case 'This Year':
          if (payment.nextDue.year == now.year) {
            total += payment.amount;
          }
          break;
        default:
          total += payment.amount;
      }
    }

    return total;
  }

  Map<PaymentFrequency, int> _analyzePaymentFrequency(List<Payment> payments) {
    final analysis = <PaymentFrequency, int>{};

    for (final payment in payments) {
      analysis[payment.frequency] = (analysis[payment.frequency] ?? 0) + 1;
    }

    return analysis;
  }

  List<Map<String, dynamic>> _getTopClients(List<Payment> payments) {
    final clientTotals = <String, double>{};

    for (final payment in payments) {
      clientTotals[payment.clientName] =
          (clientTotals[payment.clientName] ?? 0) + payment.amount;
    }

    final sortedClients = clientTotals.entries
        .map((e) => {'name': e.key, 'amount': e.value})
        .toList()
      ..sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    return sortedClients;
  }

  List<PaymentHistory> _filterByPeriod(List<PaymentHistory> history) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'This Month':
        return history.where((h) => isInCurrentMonth(h.paidDate)).toList();
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1);
        return history
            .where((h) =>
                h.paidDate.year == lastMonth.year &&
                h.paidDate.month == lastMonth.month)
            .toList();
      case 'This Year':
        return history.where((h) => h.paidDate.year == now.year).toList();
      default:
        return history;
    }
  }
}
