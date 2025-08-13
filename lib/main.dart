import 'package:flutter/material.dart';
import 'package:projek2_aplikasi_todolist/app/todo_app.dart';
import 'services/supabase_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const TodoApp());
}