import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient client;

  // Inisialisasi Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://bowngxwubyzewhrzhwsf.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvd25neHd1Ynl6ZXdocnpod3NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNDU0MjksImV4cCI6MjA3MDYyMTQyOX0.XHuiK8hGLgaB7Sv4pE1pElCoQc3aJxJMU4hFZBCkTLA',
    );
    client = Supabase.instance.client;
  }

  // Registrasi pengguna dan simpan data profil ke tabel profiles
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String course,
    DateTime? birthDate,
    String? phoneNumber,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Simpan data profil ke tabel profiles
        final profileResult = await client
            .from('profiles')
            .insert({
              'id': response.user!.id,
              'email': email,
              'name': name,
              'course': course,
              'birth_date': birthDate?.toIso8601String(),
              'phone_number': phoneNumber,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        print(
            'Pengguna terdaftar dan profil disimpan: ${profileResult['email']}');
        return {
          'success': true,
          'message': 'Registrasi berhasil! Silakan login.',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mendaftar: Tidak ada data pengguna.',
        };
      }
    } catch (e) {
      print('Kesalahan saat registrasi: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _saveUserToPrefs(response.user!);
        print('Login berhasil: ${response.user!.email}');
        return {
          'success': true,
          'message': 'Login berhasil.',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal login: Tidak ada data pengguna.',
        };
      }
    } catch (e) {
      print('Kesalahan saat login: $e');
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // Periksa apakah pengguna sudah login
  Future<bool> isUserLoggedIn() async {
    try {
      final User? user = client.auth.currentUser;
      final Session? session = client.auth.currentSession;

      print('Pengguna saat ini dari Supabase: ${user?.email}');
      print('Sesi saat ini ada: ${session != null}');

      if (user != null && session != null) {
        await _saveUserToPrefs(user);
        return true;
      } else {
        await _clearUserFromPrefs();
        return false;
      }
    } catch (e) {
      print('Kesalahan saat memeriksa status login: $e');
      await _clearUserFromPrefs();
      return false;
    }
  }
  // Logout pengguna
  Future<void> logoutUser() async {
    try {
      print('Mengeluarkan pengguna...');
      await client.auth.signOut();
      await _clearUserFromPrefs();
      print('Logout berhasil');
    } catch (e) {
      print('Kesalahan logout: $e');
      await _clearUserFromPrefs();
    }
  }

  // Simpan data pengguna ke SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email ?? '');
      print('Data pengguna disimpan ke preferensi: ${user.email}');
    } catch (e) {
      print('Kesalahan saat menyimpan preferensi pengguna: $e');
    }
  }

  // Bersihkan data pengguna dari SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Data pengguna dihapus dari preferensi');
    } catch (e) {
      print('Kesalahan saat menghapus preferensi pengguna: $e');
    }
  }

  // Ambil data pengguna saat ini
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        return {
          'id': user.id,
          'email': user.email,
        };
      }
      return {
        'id': null,
        'email': null,
      };
    } catch (e) {
      print('Kesalahan saat mengambil pengguna saat ini: $e');
      return {
        'id': null,
        'email': null,
      };
    }
  }

  // Simpan atau perbarui data profil ke tabel profiles
  Future<Map<String, dynamic>> saveUserProfile({
    required String userId,
    required String email,
    required String name,
    String? bio,
    DateTime? birthDate,
    String? phoneNumber,
    String? course,
  }) async {
    try {
      final response = await client
          .from('profiles')
          .upsert({
            'id': userId,
            'email': email,
            'name': name,
            'bio': bio,
            'birth_date': birthDate?.toIso8601String(),
            'phone_number': phoneNumber,
            'course': course,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id')
          .select()
          .single();

      print('Profil disimpan: ${response['email']}');
      return {
        'success': true,
        'message': 'Profil berhasil disimpan.',
        'data': response,
      };
    } catch (e) {
      print('Kesalahan saat menyimpan profil: $e');
      return {
        'success': false,
        'message': 'Gagal menyimpan profil: ${e.toString()}',
      };
    }
  }

  // Ambil data profil dari tabel profiles
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('profiles').select().eq('id', userId).maybeSingle();

      if (response != null) {
        print('Profil ditemukan: ${response['email']}');
        return {
          'success': true,
          'data': {
            'id': response['id'],
            'email': response['email'],
            'name': response['name'] ?? '',
            'bio': response['bio'] ?? '',
            'birth_date': response['birth_date'] != null
                ? DateTime.parse(response['birth_date'])
                : null,
            'phone_number': response['phone_number'] ?? '',
            'course': response['course'] ?? '',
          },
        };
      } else {
        print('Profil tidak ditemukan untuk userId: $userId');
        return {
          'success': false,
          'message': 'Profil tidak ditemukan.',
        };
      }
    } catch (e) {
      print('Kesalahan saat mengambil profil: $e');
      return {
        'success': false,
        'message': 'Gagal mengambil profil: ${e.toString()}',
      };
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Email atau kata sandi salah.';
        case 'User already registered':
          return 'Email sudah terdaftar.';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return 'Terjadi kesalahan: ${e.toString()}';
  }

  Future<Map<String, dynamic>> getUserTasks(String userId) async {
    try {
      final response =
          await client.from('tasks').select().eq('user_id', userId);

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      print('Kesalahan saat mengambil tasks: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
