import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import 'package:mojood_app/presentation/screens/login_screen.dart';
import 'package:mojood_app/presentation/screens/home_screen.dart';
import 'package:mojood_app/presentation/screens/hotels_screen.dart';
import 'package:mojood_app/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ezrgiaxcolbbaaqjeouo.supabase.co',
    anonKey: 'sb_publishable_v4zEiA6tiItYbClK8FIRCA_LIfqY_KA',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color kPrimary = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mojood App',
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/hotels': (_) => const HotelsScreen(),
      },
    );
  }
}