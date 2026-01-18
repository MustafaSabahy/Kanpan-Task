import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
// import '../../gen/l10n/app_localizations.dart';
import '../widgets/kanban_board.dart';
import '../widgets/offline_indicator.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/locale_provider.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onDarkModeChanged;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    this.onDarkModeChanged,
    this.isDarkMode = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: Theme.of(context).textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  border: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Time Tracking App'),
        actions: [
          if (_selectedIndex == 0) ...[
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskBloc>().add(const LoadTasksEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showMenuOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                KanbanBoard(searchQuery: _searchQuery),
                const HistoryScreen(),
                const StatisticsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final contentController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                context.read<TaskBloc>().add(
                      CreateTaskEvent(
                        content: contentController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  widget.isDarkMode ? 'Disable Dark Mode' : 'Enable Dark Mode',
                  style: theme.textTheme.titleMedium,
                ),
                onTap: () {
                  widget.onDarkModeChanged?.call(!widget.isDarkMode);
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.language,
              //     color: theme.colorScheme.onSurface,
              //   ),
              //   title: Text(
              //     l10n.language,
              //     style: theme.textTheme.titleMedium,
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _showLanguageSelector(context);
              //   },
              // ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Clear All Tasks',
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearAllConfirmation(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  'Clear Tasks from Column',
                  style: theme.textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearColumnDialog(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // void _showLanguageSelector(BuildContext context) {
  //   final l10n = AppLocalizations.of(context)!;
  //   final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  //   final theme = Theme.of(context);
  //   
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(l10n.selectLanguage),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           RadioListTile<Locale>(
  //             title: Text(l10n.english),
  //             value: const Locale('en'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //           RadioListTile<Locale>(
  //             title: Text(l10n.german),
  //             value: const Locale('de'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //           RadioListTile<Locale>(
  //             title: Text(l10n.arabic),
  //             value: const Locale('ar'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(l10n.cancel),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showLanguageSelector(BuildContext context) {
  //   final l10n = AppLocalizations.of(context)!;
  //   final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  //   final theme = Theme.of(context);
  //   
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(l10n.selectLanguage),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           RadioListTile<Locale>(
  //             title: Text(l10n.english),
  //             value: const Locale('en'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //           RadioListTile<Locale>(
  //             title: Text(l10n.german),
  //             value: const Locale('de'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //           RadioListTile<Locale>(
  //             title: Text(l10n.arabic),
  //             value: const Locale('ar'),
  //             groupValue: localeProvider.locale,
  //             onChanged: (value) {
  //               if (value != null) {
  //                 localeProvider.setLocale(value);
  //                 Navigator.pop(context);
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(l10n.cancel),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showClearAllConfirmation(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskBloc>().add(const ClearAllTasksEvent());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showClearColumnDialog(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Tasks from Column'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.todoColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: const Text('To Do'),
              onTap: () {
                context.read<TaskBloc>().add(
                      ClearTasksFromColumnEvent(AppConstants.columnTodo),
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.inProgressColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: const Text('In Progress'),
              onTap: () {
                context.read<TaskBloc>().add(
                      ClearTasksFromColumnEvent(AppConstants.columnInProgress),
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.doneColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: const Text('Done'),
              onTap: () {
                context.read<TaskBloc>().add(
                      ClearTasksFromColumnEvent(AppConstants.columnDone),
                    );
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
