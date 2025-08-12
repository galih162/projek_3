import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient client;

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://jrkxqonlssjvwezsvecg.supabase.co', // Ganti dengan URL Supabase Anda
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impya3hxb25sc3NqdndlenN2ZWNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5NjcxMDYsImV4cCI6MjA3MDU0MzEwNn0.HN__mcg7oGTNVqEMhWLLU1vpWchgKiz2vPZ9A638FQI', // Ganti dengan Anon Key Anda
    );
    client = Supabase.instance.client;
  }

  // Register user
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String course,
  }) async {
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'course': course,
        },
      );

      if (response.user != null) {
        // Save user data to SharedPreferences
        await _saveUserToPrefs(response.user!);
        
        return {
          'success': true,
          'message': 'Account created successfully!',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Please try again.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Save user data to SharedPreferences
        await _saveUserToPrefs(response.user!);
        
        return {
          'success': true,
          'message': 'Login berhasil!',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Login gagal masukan email dan password yang benar.',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    await client.auth.signOut();
    await _clearUserFromPrefs();
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_email');
  }

  // Get current user from SharedPreferences
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'course': prefs.getString('user_course'),
    };
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_course', user.userMetadata?['course'] ?? '');
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_course');
  }

  // Get user-friendly error messages
  String _getErrorMessage(String error) {
    if (error.toLowerCase().contains('email')) {
      return 'Invalid email format';
    } else if (error.toLowerCase().contains('password')) {
      return 'Password must be at least 6 characters';
    } else if (error.toLowerCase().contains('user not found')) {
      return 'User not found. Please check your email.';
    } else if (error.toLowerCase().contains('invalid credentials')) {
      return 'Invalid email or password';
    } else if (error.toLowerCase().contains('email already registered')) {
      return 'Email is already registered';
    }
    return error;
  }
}