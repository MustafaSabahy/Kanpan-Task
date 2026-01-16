# Time Tracking Kanban App

A Flutter application for managing tasks with integrated time tracking using a Kanban board interface.

![GitHub Cards Preview](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/cover.png?raw=true)



## Features

- **Kanban Board**: Three columns (To Do, In Progress, Done) with drag and drop
- **Time Tracking**: Automatic timer for tasks in "In Progress" state
- **Statistics**: Visual charts showing time spent on tasks
- **History**: Detailed time session logs for each task
- **Notifications**: Local push notifications for tasks with due dates
- **Dark Mode**: Full dark mode support
- **Multi-Language**: English, Arabic (RTL), and German support
- **Search**: Real-time task search functionality
## Demo Videos 🎥

### Full App Walkthrough
[![App Demo](https://img.youtube.com/vi/1gdANEV0PyY/0.jpg)](https://www.youtube.com/watch?v=1gdANEV0PyY)
## Screenshots 📸

### Light Mode 🌞
Home Screen | Task Details | Statistics | History | Done details | Splash Screen | list sheet actions
--- | --- | --- | --- | --- | --- | ---
![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/light%20home.png) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/light%20details.png)|![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/analytics%20light.png) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/history%20.png) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/done%20details.png) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/splash.png) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/list%20sheet%20.png)

### Dark Mode 🌙
Home Screen | Task Details | Statistics | History
--- | --- | --- | ---
![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/screenshots/home_screen_dark.png?raw=true) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/screenshots/task_details_dark.png?raw=true) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/screenshots/statistics_dark.png?raw=true) |![](https://github.com/MustafaSabahy/Kanpan-Task/blob/main/screenshots/history_dark.png?raw=true)

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- Todoist API token

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Configure API token:
   - Open `lib/core/config/app_config.dart`
   - Replace `YOUR_TODOIST_API_TOKEN_HERE` with your Todoist API token

3. Run the app:
```bash
flutter run
```

### iOS Setup
```bash
cd ios
pod install
cd ..
flutter run -d "iPhone 15"
```

## Technology Stack

- **Flutter** - UI Framework
- **BLoC** - State Management
- **Retrofit/Dio** - API Client
- **shared_preferences** - Local Storage
- **flutter_local_notifications** - Push Notifications
- **flutter_localizations** - Multi-language Support

## Time Tracking Logic

### Column Behaviors

**To Do**
- No timer running
- Moving to "In Progress" starts timer

**In Progress**
- Timer starts automatically
- Only one timer active at a time
- Time calculated on-the-fly
- Moving to "To Do" or "Done" stops timer and saves time

**Done**
- Timer stopped permanently
- Time preserved
- Can be reopened to "In Progress" (resumes timer)

### Time Sessions

Each state change creates/closes a time session:
- **To Do → In Progress**: Creates session with reason "start"
- **In Progress → To Do**: Closes session with reason "paused"
- **In Progress → Done**: Closes session with reason "done"
- **Done → In Progress**: Creates new session with reason "reopened"

Sessions are immutable once closed. Total time = sum of all session durations.

## Architecture

```
lib/
├── core/          # Config, theme, services
├── data/          # API, models, repositories
├── domain/        # Entities
└── presentation/  # BLoC, screens, widgets
```

## Localization

Supports English, Arabic (RTL), and German. Language can be changed from settings menu.

## License

Private project - not licensed for public use.

---

**Last Updated**: January 2024
