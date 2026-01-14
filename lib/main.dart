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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await NotificationService.init();

  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatefulWidget {
  const QuoteVaultApp({super.key});

  @override
  State<QuoteVaultApp> createState() => _QuoteVaultAppState();
}

class _QuoteVaultAppState extends State<QuoteVaultApp> {
  int _themeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeIndex = await PreferencesService.getThemeIndex();
    final themes = AppTheme.themes;
    setState(() => _themeIndex = themeIndex.clamp(0, themes.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthEvent())),
        BlocProvider(create: (_) => QuoteBloc()),
        BlocProvider(create: (_) => CollectionsBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themes[_themeIndex],
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess && state.userId.isNotEmpty) {
              return const HomeScreen();
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
