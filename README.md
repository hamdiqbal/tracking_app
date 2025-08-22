# Habit Tracker App

A beautiful and intuitive habit tracking application built with Flutter and GetX, following clean architecture principles.

## 🚀 Features

- 📅 Track daily habits and build routines
- 🎯 Set goals and track progress
- 🔔 Reminders and notifications
- 📊 Visual progress tracking
- 🌓 Dark/Light theme support
- 🌐 Multi-language support
- 🔄 Cloud sync with Firebase
- 📱 Cross-platform (iOS, Android, Web, Desktop)

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: GetX
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Storage**: GetStorage, SharedPreferences
- **UI Components**: Custom widgets, Flutter Native
- **Internationalization**: intl, intl_utils
- **Dependency Injection**: GetX
- **Routing**: GetX Navigation
- **Testing**: flutter_test, mockito

## 📱 Screenshots

*(Screenshots will be added after UI implementation)*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (for mobile development)
- Firebase account (for backend services)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/habit_tracking.git
   cd habit_tracking
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Add iOS/Android/Web app to your Firebase project
   - Download the configuration files and place them in the correct locations
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. Run the app:
   ```bash
   flutter run
   ```

## 🏗 Project Structure

```
lib/
├── core/
│   ├── bindings/       # Dependency injection bindings
│   ├── constants/      # App constants, colors, text styles
│   ├── routes/         # App routes and navigation
│   └── utils/          # Utility functions and extensions
│
├── data/
│   ├── models/         # Data models
│   └── repositories/    # Data repositories
│
├── logic/
│   └── controllers/    # Business logic controllers
│
└── presentation/
    ├── pages/          # App screens
    └── widgets/        # Reusable widgets
```

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 📦 Build

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Open Xcode and archive the app
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📬 Contact

For any questions or feedback, please reach out to [your.email@example.com](mailto:your.email@example.com)

---

Made with ❤️ using Flutter
