# Finance Tracker

A cross-platform personal finance tracking application built with Flutter that enables users to manage expenses and income while gaining real-time insights into their financial habits through interactive analytics and visualizations.

---

## Features

### Cross-Platform Expense Tracking
Developed a Flutter-based application allowing users to log expenses and income and view summarized financial information through a clean mobile interface.

### Persistent Data Storage and Synchronization
Integrated backend persistence using Firebase and/or local storage to securely store transactions and maintain data consistency across devices.

### Interactive Financial Visualizations
Implemented dynamic bar and pie charts using the `fl_chart` library to convert raw transaction data into monthly and category-wise spending insights.

### Real-Time Financial KPIs
Designed efficient aggregation logic in Dart to compute real-time metrics such as:
- Total spending
- Daily averages
- Monthly summaries

### Modular Analytics Dashboard
Built a dedicated analytics screen that groups financial data and maps it to custom chart widgets, enabling detailed category-level spending analysis.

---

## Tech Stack

- Flutter
- Dart
- Firebase / Local Storage
- fl_chart

---

## Application Highlights

- Responsive mobile-first UI
- Modular and scalable architecture
- Efficient state and data handling
- Real-time analytics rendering

---

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Emulator or physical device

### Installation

```bash
git clone https://github.com/eshanaaajith/Finance-tracker-03.git
cd Finance-tracker-03
flutter pub get
flutter run
```

---

## Project Structure

```
Finance-tracker-03/
│
├── android/        # Android native configuration
├── ios/            # iOS native configuration
├── web/            # Web support
├── lib/
│   ├── main.dart   # Application entry point
│   ├── models/     # Data models
│   ├── screens/    # UI screens
│   ├── widgets/    # Reusable UI components
│   └── services/   # Data handling and logic
├── test/           # Test files
└── pubspec.yaml    # Dependencies and configuration
```

---

## Future Improvements

- Budget tracking and alerts
- Authentication
- Cloud backup
- Export financial reports
- Advanced analytics

---

## License

This project is licensed under the MIT License.
