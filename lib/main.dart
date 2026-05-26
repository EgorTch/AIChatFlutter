import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/provider_screen.dart';   // Новый экран
import 'screens/stats_screen.dart';      // Новый экран
import 'screens/expenses_screen.dart';   // Новый экран

// Виджет-обёртка для отлова ошибок
class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;
  const ErrorBoundaryWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          debugPrint('Error in ErrorBoundaryWidget: $error');
          debugPrint('Stack trace: $stackTrace');
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.red,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    await dotenv.load(fileName: ".env");
    debugPrint('Environment loaded');
    debugPrint('API Key present: ${dotenv.env['OPENROUTER_API_KEY'] != null}');
    debugPrint('Base URL: ${dotenv.env['BASE_URL']}');

    runApp(const ErrorBoundaryWidget(child: MyApp()));
  } catch (e, stackTrace) {
    debugPrint('Error starting app: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error starting app: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        try {
          return ChatProvider();
        } catch (e, stackTrace) {
          debugPrint('Error creating ChatProvider: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      },
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: child!,
          );
        },
        title: 'AI Chat',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru', 'RU'),
        supportedLocales: const [
          Locale('ru', 'RU'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF262626),
            foregroundColor: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF333333),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            contentTextStyle: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.white,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
              ),
            ),
          ),
        ),
        // ========== НОВОЕ: Многостраничная навигация ==========
        home: const MainShell(),
      ),
    );
  }
}

// ========== НОВЫЙ ВИДЖЕТ: Оболочка с BottomNavigationBar ==========
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Список экранов (ленивая загрузка для производительности)
  final List<Widget> _screens = const [
    ChatScreen(),
    ProviderScreen(),
    StatsScreen(),
    ExpensesScreen(),
  ];

  // Заголовки AppBar для каждого экрана
  final List<String> _titles = const [
    'AI Chat',
    'Провайдеры',
    'Статистика',
    'Расходы',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        toolbarHeight: 48,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontSize: 16),
        ),
        // Автоматически показываем AppBar из ChatScreen, если это чат
        // Для остальных экранов — свой заголовок
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF262626),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 22),
            activeIcon: Icon(Icons.chat_bubble, size: 22),
            label: 'Чат',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.api_outlined, size: 22),
            activeIcon: Icon(Icons.api, size: 22),
            label: 'Провайдеры',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined, size: 22),
            activeIcon: Icon(Icons.analytics, size: 22),
            label: 'Статистика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: 22),
            activeIcon: Icon(Icons.bar_chart, size: 22),
            label: 'Расходы',
          ),
        ],
      ),
    );
  }
}