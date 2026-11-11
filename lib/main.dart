import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/shoes_provider.dart';
import 'screens/auth/loading_splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/navigation/main_nav_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const EarthDnaApp());
}

class EarthDnaApp extends StatelessWidget {
  const EarthDnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => ShoesProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
      ],
      child: MaterialApp(
        title: 'Earth DNA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AppRoot(),
        routes: {
          '/splash': (_) => const LoadingSplashScreen(),
          '/welcome': (_) => const WelcomeScreen(),
          '/home': (_) => const MainNavScaffold(),
        },
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _splashFinished = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return LoadingSplashScreen(
        onFinished: () {
          setState(() => _splashFinished = true);
        },
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const LoadingSplashScreen();
        }
        if (auth.isAuthenticated) {
          return const MainNavScaffold();
        }
        return const WelcomeScreen();
      },
    );
  }
}
