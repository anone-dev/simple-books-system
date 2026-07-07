import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'providers/orders_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/books/books_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const SimpleBooksApp());
}

class SimpleBooksApp extends StatelessWidget {
  const SimpleBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => BooksProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Simple Books',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1B4B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: Color(0x2EFFFFFF)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            surfaceTintColor: Colors.transparent,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xE60F172A),
            indicatorColor: const Color(0xFF6366F1).withOpacity(0.3),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0x0FFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x2EFFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x2EFFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF1E1B4B),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: const AppRoot(),
      ),
    );
  }
}

/// Root widget that checks auth state and shows appropriate screen.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();
    await auth.loadSavedToken();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }
    return const MainNavigation();
  }
}

/// Bottom navigation between Books and Orders.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [BooksScreen(), OrdersScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        key: const Key('main_bottom_nav'),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            key: Key('nav_books'),
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          NavigationDestination(
            key: Key('nav_orders'),
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            key: Key('nav_info'),
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}
