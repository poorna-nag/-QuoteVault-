import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/constants.dart';
import 'package:quote_vault/core/constants/notification_service.dart';
import 'package:quote_vault/core/services/preferences_service.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/features/auth/presentation/auth_screen.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_event.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_state.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/home_screen.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Global theme notifier for reactive theme switching
final themeNotifier = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await NotificationService.init();

  // Load saved theme preference
  themeNotifier.value = await PreferencesService.getThemeIndex();

  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthEvent())),
        BlocProvider(create: (_) => QuoteBloc()),
        BlocProvider(create: (_) => CollectionsBloc()),
      ],
      child: ValueListenableBuilder<int>(
        valueListenable: themeNotifier,
        builder: (context, themeIndex, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themes[themeIndex],
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess && state.userId.isNotEmpty) {
                  return const HomeScreen();
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
