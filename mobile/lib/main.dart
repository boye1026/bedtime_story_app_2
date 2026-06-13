// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'pages/home_page.dart';
import 'pages/info_setup_page.dart';
import 'pages/story_list_page.dart';
import 'pages/story_display_page.dart';
import 'pages/profile_page.dart';
import 'pages/membership_page.dart';
import 'pages/favorites_page.dart';

class AppState extends ChangeNotifier {
  bool isVip = false;
  int freeCount = 3;
  bool isLoading = false;
  
  void updateVipStatus(bool vip) {
    isVip = vip;
    notifyListeners();
  }
  
  void updateFreeCount(int count) {
    freeCount = count;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();
  await TtsService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const BedtimeStoryApp(),
    ),
  );
}

class BedtimeStoryApp extends StatelessWidget {
  const BedtimeStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI睡前故事',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade50,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/info-setup': (context) => const InfoSetupPage(),
        '/story-list': (context) => const StoryListPage(),
        '/profile': (context) => const ProfilePage(),
        '/membership': (context) => const MembershipPage(),
        '/favorites': (context) => const FavoritesPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
