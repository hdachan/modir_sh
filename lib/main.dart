import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'Auth/Service/AuthService.dart';
import 'Auth/ViewModel/AuthViewModel.dart';
import 'Mypage/viewmodels/ProfileViewModel.dart';
import 'Mypage/viewmodels/WithdrawalViewModel.dart';
import 'feed/sevices/FeedService.dart';
import 'feed/sevices/supabase_service.dart';
import 'feed/viewmodels/FeedViewModel.dart';
import 'feed/views/screen1.dart';
import 'feed/views/screen3.dart';
import 'utils/router.dart';
import 'confing/SupabaseConfig.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => WithdrawalViewModel()),
        ChangeNotifierProvider(create: (_) => FeedViewModel()),
        ChangeNotifierProvider(create: (_) => Test1ViewModel(SupabaseService())),
        ChangeNotifierProvider(create: (_) => Screen3ViewModel(FeedService(), SupabaseService())),
        // ScreenViewModel 제거 (정의되지 않았거나 불필요한 경우)
      ],
      child: MaterialApp.router(
        title: 'modirApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A1A)),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}