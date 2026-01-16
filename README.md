# Time Tracking Kanban App

A Flutter application for managing tasks with integrated time tracking using a Kanban board interface.

**Development Time:** 18 hours

## Features

- **Kanban Board**: Three columns (To Do, In Progress, Done) with drag and drop
- **Time Tracking**: Automatic timer for tasks in "In Progress" state
- **Statistics**: Visual charts showing time spent on tasks
- **History**: Detailed time session logs for each task
- **Notifications**: Local push notifications for tasks with due dates
- **Dark Mode**: Full dark mode support
- **Multi-Language**: English, Arabic (RTL), and German support
- **Search**: Real-time task search functionality

## Screenshots & Videos

Add your screenshots to `screenshots/` folder and videos links here.

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
