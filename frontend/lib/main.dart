import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/event_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: MaterialApp(
        title: 'Arab Sportswashing Timeline',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0E27),
          colorScheme: ColorScheme.dark(
            primary: Colors.blue[400]!,
            secondary: Colors.orange[400]!,
            surface: const Color(0xFF1A1F3A),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
