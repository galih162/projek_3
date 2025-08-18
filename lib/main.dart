import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  
  runApp(const TodoApp(title: 'My Todo App'));
}

class TodoApp extends StatelessWidget {
  final String title;
  const TodoApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(), 
    );
  }
}
