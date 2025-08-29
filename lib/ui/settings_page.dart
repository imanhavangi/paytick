import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';
import '../controller/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final themeController = Get.put(ThemeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader('App Settings', context),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Dark Theme'),
                      subtitle: const Text('Enable dark mode'),
                      value: themeController.isDarkMode.value,
                      onChanged: (value) => themeController.toggleTheme(),
                      secondary: const Icon(Icons.dark_mode),
                    )),
                Obx(() => SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Enable payment reminders'),
                      value: themeController.notificationsEnabled.value,
                      onChanged: (value) =>
                          themeController.toggleNotifications(),
                      secondary: const Icon(Icons.notifications),
                    )),
                ListTile(
                  title: const Text('Currency'),
                  subtitle: const Text('USD (\$)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  leading: const Icon(Icons.attach_money),
                  onTap: () => _showCurrencyDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management', context),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export Data'),
                  subtitle: const Text('Export all payments and history'),
                  leading: const Icon(Icons.download),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _exportData(paymentController, context),
                ),
                ListTile(
                  title: const Text('Import Data'),
                  subtitle: const Text('Import payments from file'),
                  leading: const Icon(Icons.upload),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _importData(context),
                ),
                ListTile(
                  title: const Text('Backup & Sync'),
                  subtitle: const Text('Backup data to cloud'),
                  leading: const Icon(Icons.cloud_upload),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showBackupOptions(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Section
          _buildSectionHeader('Statistics', context),
          Obx(() => Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Total Payments'),
                      trailing: Text(
                        paymentController.payments.length.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.payment),
                    ),
                    ListTile(
                      title: const Text('Payment History'),
                      trailing: Text(
                        paymentController.paymentHistory.length.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.history),
                    ),
                    ListTile(
                      title: const Text('Total Earned'),
                      trailing: Text(
                        '\$${paymentController.paymentHistory.fold(0.0, (sum, h) => sum + h.amount).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      leading: const Icon(Icons.trending_up),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Danger Zone Section
          _buildSectionHeader('Danger Zone', context),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all payments and history'),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearDataDialog(context, paymentController),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', context),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                  leading: const Icon(Icons.info),
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  leading: const Icon(Icons.description),
                  onTap: () => _showTermsOfService(context),
                ),
                ListTile(
                  title: const Text('Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  leading: const Icon(Icons.support),
                  onTap: () => _showSupport(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Currency Selection'),
        content: const Text(
            'Currency selection will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportData(PaymentController controller, BuildContext context) {
    // TODO: Implement actual export functionality
    Get.snackbar(
      'Export Data',
      'Export functionality will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _importData(BuildContext context) {
    // TODO: Implement actual import functionality
    Get.snackbar(
      'Import Data',
      'Import functionality will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Sync'),
        content: const Text(
            'Cloud backup and sync will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
      BuildContext context, PaymentController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your payments and history. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all data functionality
              Navigator.of(context).pop();
              Get.snackbar(
                'Data Cleared',
                'All data has been cleared successfully.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'PayTick Privacy Policy\n\n'
            'This app stores all data locally on your device. No personal information is collected or transmitted to external servers.\n\n'
            'Data Storage:\n'
            '• Payment information is stored locally using Hive database\n'
            '• No cloud synchronization by default\n'
            '• Notifications are handled locally\n\n'
            'Your privacy is important to us. All data remains on your device unless you explicitly choose to export or backup your data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'PayTick Terms of Service\n\n'
            'By using this app, you agree to:\n\n'
            '1. Use the app for legitimate payment tracking purposes\n'
            '2. Take responsibility for backing up your data\n'
            '3. Understand that the app is provided as-is\n'
            '4. Respect intellectual property rights\n\n'
            'The developers are not responsible for any data loss or business decisions made based on the app\'s information.\n\n'
            'This app is designed to assist with payment tracking but should not be the sole method for financial record keeping.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support'),
        content: const Text(
          'Need help with PayTick?\n\n'
          'For support and feedback, please contact us at:\n'
          'support@paytick.app\n\n'
          'We\'d love to hear from you!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
