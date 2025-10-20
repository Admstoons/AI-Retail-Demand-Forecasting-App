// Cross-platform HTTP client via conditional imports

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_demand/provider/theme_provider.dart';
import 'package:retail_demand/screens/create_password_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/dashboard_screen.dart';
import 'package:retail_demand/screens/home_page.dart';
import 'package:retail_demand/screens/login_screen.dart';
import 'package:retail_demand/screens/dashboard_screens/upload_data_screen.dart';
import 'package:retail_demand/screens/signup_screen.dart';
import 'package:retail_demand/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'utils/http_client_factory.dart';

import 'app_colors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  try {
    debugPrint('🔄 Initializing Supabase...');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      // Cross-platform client with global request timeout
      httpClient: createHttpClient(),
    );

    final supabase = Supabase.instance.client;

    // ✅ Check for magic link redirect
    final uri = Uri.base;
    if (uri.toString().contains('access_token')) {
      final response = await supabase.auth.getSessionFromUrl(uri);
      // ignore: unnecessary_null_comparison
      if (response.session != null) {
        debugPrint('✅ Session restored from magic link');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/set-password',
          (route) => false,
        );
      } else {
        debugPrint('❌ Failed to restore session from magic link');
      }
    }

    // ✅ Listen for sign in event
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      }
    });

    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('❌ Supabase initialization failed: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor:null,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.black),
          trackColor: WidgetStateProperty.all(Colors.grey),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondary,
          primary: AppColors.appBarColor,
          error: AppColors.error,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: null,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.all(Colors.grey),
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: AppColors.secondary,
          primary: Colors.black,
          error: AppColors.error,
        ),
      ),
      themeAnimationDuration: const Duration(milliseconds: 200),

      // ✅ Initial screen
      home: const SplashScreen(),

      // ✅ Routes
      routes: {
        '/upload': (context) => const UploadDataScreen(),
        '/login': (context) => const LoginScreen(),
        '/homepage': (context) => const HomePage(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/set-password':
            (context) => const CreatePasswordScreen(
              email: '',
            ), // 🧠 Will fill email later
      },
    );
  }
}
