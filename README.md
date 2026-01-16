# Task Tracker - Flutter Time Tracking App

A professional Flutter application for task management with Kanban board, time tracking, and comments functionality.

## Features

✅ **Kanban Board** - Organize tasks in "To Do", "In Progress", and "Done" columns  
✅ **Time Tracking** - Start/stop timer for each task with session tracking  
✅ **Task History** - View completed tasks with time spent and completion dates  
✅ **Comments** - Add and manage comments on tasks  
✅ **Modern UI/UX** - Clean, professional design with Material 3  
✅ **Clean Architecture** - Following SOLID principles and best practices  

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── core/              # Core utilities, theme, constants
├── data/              # Data layer (models, repositories, API)
│   ├── api/          # Retrofit API service with Dio
│   ├── models/       # JSON serializable models
│   └── repositories/ # Data repositories
├── domain/            # Domain layer (entities)
└── presentation/      # Presentation layer (UI)
    ├── providers/    # Riverpod state management
    ├── screens/      # App screens
    └── widgets/      # Reusable widgets
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure API Token

1. Get your Todoist API token from [Todoist App Management Console](https://developer.todoist.com/appconsole.html)
2. Open `lib/core/constants/api_constants.dart`
3. Replace `YOUR_TODOIST_API_TOKEN_HERE` with your actual token:

```dart
static const String testToken = 'your_actual_token_here';
```

### 3. Generate Code

Run the build runner to generate JSON serialization and Retrofit code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note:** If you encounter Retrofit generator compatibility issues, you may need to:
- Update to the latest Flutter SDK
- Or use compatible versions (retrofit: ^4.0.3 with retrofit_generator: ^9.1.0)

### 4. Run the App

```bash
flutter run
```

## Tech Stack

### State Management
- **flutter_riverpod** - Modern state management solution

### Networking
- **dio** - Powerful HTTP client
- **retrofit** - Type-safe HTTP client generator
- **pretty_dio_logger** - Beautiful API request/response logging

### JSON Serialization
- **json_annotation** & **json_serializable** - Code generation for JSON

### Local Storage
- **shared_preferences** - Persistent storage for time tracking data

### UI Components
- **flutter_slidable** - Swipeable widgets
- **shimmer** - Loading placeholders
- **intl** - Internationalization and date formatting

## Project Structure

### Core
- `app_theme.dart` - Centralized theme configuration
- `api_constants.dart` - API endpoints and configuration
- `app_constants.dart` - App-wide constants
- `date_formatter.dart` - Date/time formatting utilities

### Data Layer
- **Models**: Task, Comment, Project, TaskTimeTracking
- **API Service**: TodoistApiService (Retrofit)
- **Repositories**: TaskRepository, CommentRepository, TimeTrackingRepository

### Presentation Layer
- **Providers**: Task, Timer, Comment providers using Riverpod
- **Screens**: HomeScreen (Kanban), HistoryScreen
- **Widgets**: KanbanBoard, TaskCard, TimerWidget, CommentsSection

## Key Features Implementation

### Kanban Board
- Three columns: To Do, In Progress, Done
- Tasks automatically move to "Done" when completed
- Visual indicators for active timers

### Time Tracking
- Start/stop timer per task
- Multiple sessions support
- Total time calculation
- Persistent storage using SharedPreferences

### Task History
- Shows all completed tasks
- Displays total time spent
- Sorted by completion date (newest first)

### Comments
- Add comments to tasks
- View comment history
- Delete comments

## Best Practices Applied

✅ **SOLID Principles** - Single responsibility, dependency inversion  
✅ **DRY** - Reusable widgets and utilities  
✅ **KISS** - Simple, maintainable code  
✅ **Clean Architecture** - Separation of concerns  
✅ **Type Safety** - Strong typing throughout  
✅ **Error Handling** - Proper error states in UI  
✅ **Performance** - Efficient state management and rendering  

## API Integration

The app uses the [Todoist REST API v2](https://developer.todoist.com/rest/v2/#overview):

- **Tasks**: Create, read, update, delete, close, reopen
- **Comments**: Create, read, update, delete
- **Projects**: Read project information

## Future Enhancements

Potential improvements:
- Drag-and-drop for moving tasks between columns
- Task editing functionality
- Priority indicators
- Due date management
- Offline support with sync
- Push notifications
- Multi-language support
- Custom themes

## License

This project is created as a take-home challenge for a Flutter developer position.
# Kanpan-Task
# Kanpan-Task
