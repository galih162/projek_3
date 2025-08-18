import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek2_aplikasi_todolist/services/supabase_service.dart';
import 'package:intl/intl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // Controllers untuk form
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerCourseController =
      TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // State untuk tanggal lahir
  DateTime? _registerBirthDate;

  // State untuk password visibility
  bool _isRegisterPasswordVisible = false;
  bool _isRegisterConfirmPasswordVisible = false;
  bool _isLoginPasswordVisible = false;

  // State untuk loading
  bool _isRegisterLoading = false;
  bool _isLoginLoading = false;

  String get formatTanggal {
    if (_registerBirthDate == null) return 'Pilih tanggal lahir';
    return DateFormat('dd MMMM yyyy').format(_registerBirthDate!);
  }

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  // Check if user is already logged in
  Future<void> _checkUserLogin() async {
    final isLoggedIn = await _supabaseService.isUserLoggedIn();
    print('isUserLoggedIn: $isLoggedIn');
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Register function
  Future<void> _register() async {
    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      _showSnackBar('Kata sandi tidak cocok!', isError: true);
      return;
    }

    if (_registerEmailController.text.isEmpty ||
        _registerNameController.text.isEmpty ||
        _registerCourseController.text.isEmpty ||
        _registerPhoneController.text.isEmpty ||
        _registerPasswordController.text.isEmpty ||
        _registerBirthDate == null) {
      _showSnackBar('Harap isi semua kolom!', isError: true);
      return;
    }

    setState(() {
      _isRegisterLoading = true;
    });

    final result = await _supabaseService.registerUser(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      name: _registerNameController.text.trim(),
      course: _registerCourseController.text.trim(),
      birthDate: _registerBirthDate,
      phoneNumber: _registerPhoneController.text.trim(),
    );

    setState(() {
      _isRegisterLoading = false;
    });

    if (result['success']) {
      // Clear register form
      _registerEmailController.clear();
      _registerNameController.clear();
      _registerCourseController.clear();
      _registerPhoneController.clear();
      _registerPasswordController.clear();
      _registerConfirmPasswordController.clear();
      _registerBirthDate = null;

      _showSnackBar(
          'Akun berhasil dibuat! Silakan login dengan kredensial Anda.',
          isError: false);
      Navigator.pop(context); // Close register modal

      // Otomatis buka login modal setelah register berhasil
      Future.delayed(const Duration(milliseconds: 500), () {
        _showLoginModal();
      });
    } else {
      _showSnackBar(result['message'], isError: true);
    }
  }

  // Login function
  Future<void> _login() async {
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      _showSnackBar('Harap isi semua kolom!', isError: true);
      return;
    }

    setState(() {
      _isLoginLoading = true;
    });

    final result = await _supabaseService.loginUser(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );

    setState(() {
      _isLoginLoading = false;
    });

    if (result['success']) {
      // Clear login form
      _loginEmailController.clear();
      _loginPasswordController.clear();

      _showSnackBar(result['message'], isError: false);
      Navigator.pop(context); // Close modal

      // Navigate to home with proper route clearing
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      _showSnackBar(result['message'], isError: true);
    }
  }

  // Show snackbar
  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _registerEmailController.dispose();
    _registerNameController.dispose();
    _registerCourseController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'To Do Day',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA0D7C8),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 326,
                    height: 282,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA0D7C8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'Logo.png',
                        width: 195,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Get organized  your life',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF584A4A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'simple and affective\n'
                      'to-do list and task manager app\n'
                      'which helps you manage time\n',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF584A4A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // CREATE ACCOUNT BUTTON
                    GestureDetector(
                      onTap: () {
                        _showRegisterModal();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFA0D7C8),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LOGIN BUTTON
                        GestureDetector(
                          onTap: () {
                            _showLoginModal();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 115, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFA0D7C8),
                                width: 3.0,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFA0D7C8)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRegisterModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _registerEmailController,
                        hintText: "contoh@email.com",
                        labelText: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _registerNameController,
                        hintText: "Masukkan nama",
                        labelText: "Nama",
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _registerCourseController,
                        hintText: "Ilmu Komputer",
                        labelText: "Kursus",
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _registerPhoneController,
                        hintText: "081234567890",
                        labelText: "Nomor Telepon",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        child: TextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: formatTanggal),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _registerBirthDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _registerBirthDate = picked;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: "Pilih tanggal lahir",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            labelText: "Tanggal Lahir",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 3.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 3.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _registerPasswordController,
                        hintText: "Kata sandi",
                        labelText: "Kata Sandi",
                        isVisible: _isRegisterPasswordVisible,
                        onToggleVisibility: () {
                          setModalState(() {
                            _isRegisterPasswordVisible =
                                !_isRegisterPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _registerConfirmPasswordController,
                        hintText: "Konfirmasi kata sandi",
                        labelText: "Konfirmasi Kata Sandi",
                        isVisible: _isRegisterConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setModalState(() {
                            _isRegisterConfirmPasswordVisible =
                                !_isRegisterConfirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _isRegisterLoading
                            ? null
                            : () async {
                                setModalState(() {
                                  _isRegisterLoading = true;
                                });
                                await _register();
                                setModalState(() {
                                  _isRegisterLoading = false;
                                });
                              },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                _isRegisterLoading ? Colors.grey : Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: _isRegisterLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF584A4A),
                                )
                              : Text(
                                  'Daftar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF584A4A),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showLoginModal();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF584A4A)),
                            ),
                            Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLoginModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Wrap(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA0D7C8),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF584A4A),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                          controller: _loginEmailController,
                          hintText: "contoh@email.com",
                          labelText: "Email",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          controller: _loginPasswordController,
                          hintText: "Kata sandi",
                          labelText: "Kata Sandi",
                          isVisible: _isLoginPasswordVisible,
                          onToggleVisibility: () {
                            setModalState(() {
                              _isLoginPasswordVisible =
                                  !_isLoginPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _isLoginLoading
                              ? null
                              : () async {
                                  setModalState(() {
                                    _isLoginLoading = true;
                                  });
                                  await _login();
                                  setModalState(() {
                                    _isLoginLoading = false;
                                  });
                                },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  _isLoginLoading ? Colors.grey : Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: _isLoginLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF584A4A),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(0xFF584A4A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showRegisterModal();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF584A4A),
                                ),
                              ),
                              Text(
                                'Daftar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
          ),
        ),
      ),
    );
  }

  // Build Password Field Widget
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          labelText: labelText,
          suffixIcon: InkWell(
            onTap: onToggleVisibility,
            child: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
              size: 26,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
          ),
        ),
      ),
    );
  }
}
