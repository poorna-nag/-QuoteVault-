import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/services/preferences_service.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/core/constants/notification_service.dart';
import 'package:quote_vault/features/auth/presentation/auth_screen.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_event.dart';
import 'package:quote_vault/features/auth/presentation/profile_screen.dart';
import 'package:quote_vault/features/quotes/data/repo/quote_repo.dart';
import 'package:quote_vault/main.dart';

class SettingsScreen extends StatefulWidget {
  final bool embed;

  const SettingsScreen({super.key, this.embed = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _themeIndex = 0;
  double _fontSize = 18.0;
  TimeOfDay? _notificationTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeIndex = await PreferencesService.getThemeIndex();
    final fontSize = await PreferencesService.getFontSize();
    final notificationTimeStr = await PreferencesService.getNotificationTime();

    setState(() {
      _themeIndex = themeIndex.clamp(0, AppTheme.themes.length - 1);
      _fontSize = fontSize;
      if (notificationTimeStr != null) {
        final parts = notificationTimeStr.split(':');
        _notificationTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });
  }

  Future<void> _selectNotificationTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() => _notificationTime = time);
      await PreferencesService.setNotificationTime(
        '${time.hour}:${time.minute}',
      );
      final repo = QuoteRepo();
      final quotes = await repo.fetchQuotes();
      if (quotes.isNotEmpty) {
        await NotificationService.scheduleDailyQuote(
          quotes[0].quote,
          time: time,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, top: 24, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget settingsCard({required Widget child}) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: child,
      );
    }

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle('Appearance'),

        settingsCard(
          child: ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(AppTheme.themeNames[_themeIndex]),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _themeIndex,
                items: List.generate(AppTheme.themeNames.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(AppTheme.themeNames[index]),
                  );
                }),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() => _themeIndex = value);
                    await PreferencesService.setThemeIndex(value);
                    // Update the global theme notifier to trigger app-wide theme change
                    themeNotifier.value = value;
                  }
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        settingsCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Font Size'),
                  subtitle: Text('${_fontSize.toStringAsFixed(0)} px'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: _fontSize,
                    min: 14,
                    max: 28,
                    divisions: 14,
                    label: '${_fontSize.toStringAsFixed(0)}px',
                    onChanged: (value) async {
                      setState(() => _fontSize = value);
                      await PreferencesService.setFontSize(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        sectionTitle('Notifications'),

        settingsCard(
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Daily Quote'),
            subtitle: Text(
              _notificationTime != null
                  ? 'Every day at ${_notificationTime!.format(context)}'
                  : 'Not scheduled',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectNotificationTime,
          ),
        ),

        sectionTitle('Account'),

        settingsCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );

    if (widget.embed) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: content,
    );
  }
}
