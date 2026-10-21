import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/sales_provider.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DairySalesApp());
}

class DairySalesApp extends StatefulWidget {
  const DairySalesApp({super.key});

  @override
  State<DairySalesApp> createState() => _DairySalesAppState();
}

class _DairySalesAppState extends State<DairySalesApp> {
  late final SalesProvider _salesProvider;

  @override
  void initState() {
    super.initState();
    _salesProvider = SalesProvider();
  }

  @override
  void dispose() {
    _salesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.outfitTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      title: 'Quesitos Kenia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFE65100),
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: textTheme,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
      home: HomeScreen(provider: _salesProvider),
    );
  }
}
