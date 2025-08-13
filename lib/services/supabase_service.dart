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
      url: 'https://bowngxwubyzewhrzhwsf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvd25neHd1Ynl6ZXdocnpod3NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNDU0MjksImV4cCI6MjA3MDYyMTQyOX0.XHuiK8hGLgaB7Sv4pE1pElCoQc3aJxJMU4hFZBCkTLA',
    );
    client = Supabase.instance.client;
  }

  // Register user - FIXED: Tidak langsung save session
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String course,
  }) async {
    try {
      print('Attempting registration for email: $email');
      
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'course': course,
        },
      );

      print('Registration response: ${response.user?.email}');

      if (response.user != null) {
        // PENTING: Sign out setelah register agar user harus login manual
        await client.auth.signOut();
        
        return {
          'success': true,
          'message': 'Registration successful! Please login with your credentials.',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Please try again.',
        };
      }
    } on AuthException catch (e) {
      print('Registration AuthException: ${e.message}');
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Login user - FIXED: Hanya save session jika login berhasil
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for email: $email');
      
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Login response user: ${response.user?.email}');
      print('Login response session: ${response.session?.accessToken != null}');

      if (response.user != null && response.session != null) {
        // Save user data to SharedPreferences hanya setelah login berhasil
        await _saveUserToPrefs(response.user!);
        
        print('Login successful, user saved to preferences');
        return {
          'success': true,
          'message': 'Login berhasil!',
          'user': response.user,
        };
      } else {
        print('Login failed: No user or session returned');
        return {
          'success': false,
          'message': 'Login gagal. Periksa email dan password Anda.',
        };
      }
    } on AuthException catch (e) {
      print('Login AuthException: ${e.message}');
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Check if user is logged in - FIXED: Cek Supabase session dulu, baru SharedPreferences
  Future<bool> isUserLoggedIn() async {
    try {
      // Cek Supabase session terlebih dahulu
      final User? user = client.auth.currentUser;
      final Session? session = client.auth.currentSession;
      
      print('Current user from Supabase: ${user?.email}');
      print('Current session exists: ${session != null}');
      
      if (user != null && session != null) {
        // Jika ada session di Supabase, pastikan SharedPreferences juga sync
        await _saveUserToPrefs(user);
        return true;
      } else {
        // Jika tidak ada session di Supabase, clear SharedPreferences
        await _clearUserFromPrefs();
        return false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Fallback ke SharedPreferences jika ada error
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('user_email');
    }
  }

  // Get current user data
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final User? user = client.auth.currentUser;
      if (user != null) {
        return {
          'id': user.id,
          'email': user.email,
          'course': user.userMetadata?['course'] ?? 'Unknown Course',
          'name': user.userMetadata?['course'] ?? user.email?.split('@')[0] ?? 'User',
        };
      }
      
      // Fallback ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return {
        'email': prefs.getString('user_email') ?? '',
        'course': prefs.getString('user_course') ?? '',
        'name': prefs.getString('user_course') ?? prefs.getString('user_email')?.split('@')[0] ?? 'User',
      };
    } catch (e) {
      print('Error getting current user: $e');
      return {};
    }
  }

  // Logout user - FIXED: Clear both Supabase session and SharedPreferences
  Future<void> logoutUser() async {
    try {
      print('Logging out user...');
      await client.auth.signOut();
      await _clearUserFromPrefs();
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      // Tetap clear SharedPreferences meskipun Supabase logout error
      await _clearUserFromPrefs();
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_course', user.userMetadata?['course'] ?? '');
      print('User data saved to preferences: ${user.email}');
    } catch (e) {
      print('Error saving user to preferences: $e');
    }
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_course');
      print('User data cleared from preferences');
    } catch (e) {
      print('Error clearing user preferences: $e');
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(String error) {
    print('Original error: $error');
    
    if (error.toLowerCase().contains('invalid login credentials')) {
      return 'Email atau password salah. Periksa kembali data Anda.';
    } else if (error.toLowerCase().contains('email not confirmed')) {
      return 'Silakan konfirmasi email Anda terlebih dahulu.';
    } else if (error.toLowerCase().contains('user already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (error.toLowerCase().contains('weak password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    } else if (error.toLowerCase().contains('invalid email')) {
      return 'Format email tidak valid.';
    } else if (error.toLowerCase().contains('user not found')) {
      return 'User tidak ditemukan. Periksa email Anda.';
    } else if (error.toLowerCase().contains('signup disabled')) {
      return 'Registrasi sedang dinonaktifkan.';
    }
    
    return error;
  }

  // Method untuk reset password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Email reset password telah dikirim.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim email reset.',
      };
    }
  }

  // Method untuk cek status user di database
  Future<Map<String, dynamic>> checkUserStatus(String email) async {
    try {
      final response = await client
          .from('profiles') // Sesuaikan dengan nama table Anda
          .select()
          .eq('email', email)
          .maybeSingle();
      
      return {
        'exists': response != null,
        'data': response,
      };
    } catch (e) {
      print('Error checking user status: $e');
      return {
        'exists': false,
        'data': null,
      };
    }
  }
}