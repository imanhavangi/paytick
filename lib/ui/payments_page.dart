import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';
import '../model/payment.dart';
import '../model/payment_category.dart';
import '../utils/date_utils.dart';
import 'add_payment_page.dart';

class PaymentsListPage extends StatelessWidget {
  const PaymentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paytick'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Total due this month banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total due this month:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.totalDueThisMonth.toStringAsFixed(2),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                  ],
                )),
          ),
          // Payments list
          Expanded(
            child: Obx(() {
              if (controller.payments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No payments yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first payment',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.payments.length,
                itemBuilder: (context, index) {
                  final payment = controller.payments[index];
                  return PaymentListItem(
                    payment: payment,
                    onTogglePaid: () => controller.togglePaid(payment),
                    onEdit: () =>
                        Get.to(() => AddPaymentPage(editPayment: payment)),
                    onDelete: () =>
                        _showDeleteDialog(context, payment, controller),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddPaymentPage()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Payment payment, PaymentController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
            'Are you sure you want to delete the payment for ${payment.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deletePayment(payment);
              Navigator.of(context).pop();
              Get.snackbar(
                'Success',
                'Payment deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentListItem({
    super.key,
    required this.payment,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPaymentOverdue = isOverdue(payment.nextDue);
    final isPaymentDueToday = isDueToday(payment.nextDue);
    final isPaymentDueTomorrow = isDueTomorrow(payment.nextDue);

    Color? cardColor;
    if (isPaymentOverdue) {
      cardColor = Colors.red.withValues(alpha: 0.1);
    } else if (isPaymentDueToday) {
      cardColor = Colors.orange.withValues(alpha: 0.1);
    } else if (isPaymentDueTomorrow) {
      cardColor = Colors.yellow.withValues(alpha: 0.1);
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value:
                  false, // Always false since marking as paid moves the date forward
              onChanged: (_) => onTogglePaid(),
            ),
            const SizedBox(width: 12),
            // Payment details
            Expanded(
              child: GestureDetector(
                onTap: onEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.formattedAmount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.frequency.displayName} • Due ${formatDateShort(payment.nextDue)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            // Status indicator
            if (isPaymentOverdue)
              const Icon(Icons.warning, color: Colors.red, size: 20)
            else if (isPaymentDueToday)
              const Icon(Icons.today, color: Colors.orange, size: 20)
            else if (isPaymentDueTomorrow)
              const Icon(Icons.schedule, color: Colors.yellow, size: 20),
          ],
        ),
      ),
    );
  }
}
