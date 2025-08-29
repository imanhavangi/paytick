import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';
import '../model/payment_history.dart';
import '../utils/date_utils.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('This Month'),
                      _buildFilterChip('Last Month'),
                      _buildFilterChip('This Year'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: Obx(() {
              final history = controller.paymentHistory;
              final filteredHistory = _filterHistory(history);

              if (filteredHistory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'All'
                            ? 'No payments found'
                            : 'No payment history yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'All'
                            ? 'Try adjusting your search or filter'
                            : 'Payment history will appear here when you mark payments as paid',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Group history by month
              final groupedHistory = _groupHistoryByMonth(filteredHistory);

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: groupedHistory.length,
                itemBuilder: (context, index) {
                  final monthYear = groupedHistory.keys.elementAt(index);
                  final monthHistory = groupedHistory[monthYear]!;
                  final monthTotal =
                      monthHistory.fold(0.0, (sum, h) => sum + h.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthYear,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '\$${monthTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // History items for this month
                      ...monthHistory
                          .map((historyItem) => _buildHistoryItem(historyItem)),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildHistoryItem(PaymentHistory historyItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(Icons.check, color: Colors.white),
        ),
        title: Text(
          historyItem.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${historyItem.frequency.displayName} payment',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${historyItem.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              formatDateShort(historyItem.paidDate),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PaymentHistory> _filterHistory(List<PaymentHistory> history) {
    var filtered = history;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              h.clientName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'This Month':
        filtered = filtered.where((h) => isInCurrentMonth(h.paidDate)).toList();
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1);
        filtered = filtered
            .where((h) =>
                h.paidDate.year == lastMonth.year &&
                h.paidDate.month == lastMonth.month)
            .toList();
        break;
      case 'This Year':
        filtered = filtered.where((h) => h.paidDate.year == now.year).toList();
        break;
    }

    return filtered;
  }

  Map<String, List<PaymentHistory>> _groupHistoryByMonth(
      List<PaymentHistory> history) {
    final grouped = <String, List<PaymentHistory>>{};

    for (final item in history) {
      final monthYear = formatMonthYear(item.paidDate);
      grouped.putIfAbsent(monthYear, () => []).add(item);
    }

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGrouped = <String, List<PaymentHistory>>{};

    for (final key in sortedKeys) {
      final items = grouped[key]!;
      items.sort((a, b) => b.paidDate.compareTo(a.paidDate));
      sortedGrouped[key] = items;
    }

    return sortedGrouped;
  }
}
