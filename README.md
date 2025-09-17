# HealthyMe – iOS Final Project

HealthyMe is an iOS application that helps users build and track daily healthy habits while providing motivational insights and lifestyle guidance.
The project is designed to meet and exceed the requirements of the iOS final-term assignment, demonstrating a clean SwiftUI + MVVM architecture and modern iOS development best practices.

## Features

### Fundamentals
- **Multi-screen navigation**: TabView for the main tab bar and NavigationStack for hierarchical flows.
- **List of daily habits**: List bound to @StateObject HabitsViewModel for real-time updates.
- **Weekly progress grid**: LazyVGrid displaying a 7×N calendar-style completion grid.
- **Motivational quotes**: QuoteAPIService fetches data from ZenQuotes.io using Alamofire with async/await.
- **Persistent storage**: UserDefaults via @AppStorage and a lightweight wrapper for saving habits.
- **Custom font**: SeoulHangang font added to the project and configured through Info.plist. Example:
  ```swift
  Text("HealthyMe").font(.custom("SeoulHangang", size: 24))
  ```

### Uplift Features
- **Local notifications**: UNUserNotificationCenter in NotificationService schedules daily habit reminders.
- **Biometric login**: LAContext wrapped in BiometricAuthService enables Face ID or passcode unlock with a simple LockScreenView.
- **Localization**: English and Burmese (my) support using Localizable.strings and @Environment(\.locale).
- **Data validation**: AddHabitView uses a Form with TextField validation and alerts for missing or invalid input.
- **Animations**: Habit completion shows a checkmark with withAnimation and .transition(.scale) for a delightful effect.

### Special Features
- **MVVM architecture**: All state is managed by ObservableObject view models for clean, maintainable code.
- **App Widget**: A WidgetKit extension displays “unchecked habits” directly on the iOS Home Screen using a TimelineProvider.
- **HealthKit integration**: HKHealthStore (optional) reads step counts, calories, and sleep data with user permission.

## Tech Stack
- **Language:** Swift 5 / SwiftUI
- **Frameworks & APIs:** Combine, WidgetKit, HealthKit, UserNotifications, LocalAuthentication, Alamofire
- **Architecture:** MVVM

## Contributors
- Sam Yati
- Wyne Nadi

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/narattscoward/healthyme-iOS-final-project.git
   ```
2. Open `HealthyMe.xcodeproj` in Xcode 15 or later.
3. Run on iOS 17+ simulator or a real device.

HealthyMe showcases a modern iOS application with a clean codebase, scalable architecture, perfect for demonstrating SwiftUI development in an academic setting.
