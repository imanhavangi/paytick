# Paytick

A Flutter app for tracking recurring payments from clients that works entirely offline.

## Features

- Track recurring payments with client name, amount, and frequency (monthly/weekly)
- Mark payments as paid and automatically schedule next due date
- View total amount due this month
- Local notifications one day before payment due dates
- Add new payments with form validation
- Delete payments with long-press
- Offline-first with Hive local storage

## Requirements

- Flutter ≥ 3.22
- Dart ≥ 3.0

## Dependencies

- `get` - State management
- `hive` & `hive_flutter` - Local database
- `intl` - Date/number formatting
- `flutter_local_notifications` - Push notifications
- `path_provider` - File system paths
- `timezone` - Timezone handling

## Build Instructions

1. **Clone or create the project structure:**
   ```bash
   # If cloning, navigate to project directory
   cd paytick
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Testing

Run unit tests:
```bash
flutter test
```

The test suite includes:
- PaymentFrequency.nextDate logic validation
- PaymentController.togglePaid functionality
- Edge cases for date calculations
- Data persistence verification

## Project Structure

```
lib/
├── model/
│   └── payment.dart              # Payment model & Hive adapter
├── controller/
│   └── payment_controller.dart   # GetX controller with business logic
├── ui/
│   ├── payments_page.dart        # Main payments list page
│   └── add_payment_page.dart     # Add payment form
├── utils/
│   └── date_utils.dart           # Date utility functions
└── main.dart                     # App entry point

test/
├── payment_frequency_test.dart   # Unit tests for frequency logic
└── payment_controller_test.dart  # Unit tests for controller
```

## Usage

1. **Add a Payment:**
   - Tap the + button
   - Fill in client name, amount, frequency, and next due date
   - Tap "Add Payment"

2. **Mark Payment as Paid:**
   - Tap the checkbox next to a payment
   - The next due date will automatically advance based on frequency

3. **Delete a Payment:**
   - Long-press on a payment item
   - Confirm deletion in the dialog

4. **View Monthly Total:**
   - The banner at the top shows total amount due this month

## Notifications

The app schedules local notifications one day before each payment is due. Make sure to grant notification permissions when prompted.

## Offline Functionality

The app works entirely offline using Hive for local storage. All data is persisted locally on the device.

## Platform Support

- Android ✅
- iOS ✅ (with additional notification setup)
- Web ⚠️ (limited Hive support)
- Desktop ⚠️ (limited notification support)
