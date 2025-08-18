import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:projek2_aplikasi_todolist/screens/splash_screen.dart';
import 'package:projek2_aplikasi_todolist/services/supabase_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<MyProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? tanggalTerpilih;
  Map<String, dynamic>? userProfile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = false;
    });
    final currentUser = await _supabaseService.getCurrentUser();
    final userId = currentUser['id'];
    if (userId != null) {
      final result = await _supabaseService.getUserProfile(userId);
      if (result['success']) {
        setState(() {
          userProfile = result['data'];
          _nameController.text = userProfile?['name'] ?? '';
          _bioController.text = userProfile?['bio'] ?? '';
          _phoneController.text = userProfile?['phone_number'] ?? '';
          tanggalTerpilih = userProfile?['birth_date'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Gagal memuat profil: ${result['message']}', isError: true);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Pengguna tidak ditemukan.', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    final currentUser = await _supabaseService.getCurrentUser();
    final userId = currentUser['id'];
    final email = currentUser['email'];
    if (userId != null && email != null) {
      final result = await _supabaseService.saveUserProfile(
        userId: userId,
        email: email,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        birthDate: tanggalTerpilih,
        phoneNumber: _phoneController.text.trim(),
      );
      if (result['success']) {
        _showSnackBar('Profil berhasil disimpan!', isError: false);
        await _loadUserProfile(); // Refresh data profil
      } else {
        _showSnackBar('Gagal menyimpan profil: ${result['message']}', isError: true);
      }
    } else {
      _showSnackBar('Pengguna tidak ditemukan.', isError: true);
    }
  }

  // Fungsi logout
  Future<void> _logout() async {
    try {
      await _supabaseService.logoutUser();
      if (mounted) {
        _showSnackBar('Logout berhasil.', isError: false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Kesalahan saat logout: $e', isError: true);
      }
    }
  }

  // Show SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String get formatTanggal {
    if (tanggalTerpilih == null) return 'Pilih tanggal lahir';
    return DateFormat('dd MMMM yyyy').format(tanggalTerpilih!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian atas (judul + profil)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA0D7C8),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Profil',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF584A4A),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  size: 70,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                userProfile?['name'] ?? 'Pengguna',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF584A4A),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _showEditProfileModal(),
                                child: Text(
                                  'Edit Profil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF584A4A),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Bio Saya",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nama",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildProfileField(
                          icon: Icons.person_2_outlined,
                          text: userProfile?['name'] ?? '',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Bio",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildProfileField(
                          icon: Icons.description_outlined,
                          text: userProfile?['bio'] ?? '',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tanggal Lahir",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildProfileField(
                          icon: Icons.calendar_month_outlined,
                          text: formatTanggal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nomor Telepon",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildProfileField(
                          icon: Icons.smartphone_outlined,
                          text: userProfile?['phone_number'] ?? '',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Log Out",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: Text(
                              "Apakah Anda yakin ingin logout?",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "Batal",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _logout();
                                },
                                child: Text(
                                  "Log Out",
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "Log Out",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Widget untuk menampilkan field profil
  Widget _buildProfileField({required IconData icon, required String text}) {
    return Container(
      width: 400,
      height: 50,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Color(0xFFA0D7C8).withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF584141),
            size: 25,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF584A4A),
            ),
          ),
        ],
      ),
    );
  }

  // Modal untuk edit profil
  void _showEditProfileModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 250,
            height: 450,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFFA0D7C8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Edit Profil",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: "Masukkan nama",
                    hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    labelText: "Nama",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: "Masukkan bio",
                    hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    labelText: "Bio",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: formatTanggal),
                    onTap: () async {
                      final DateTime? terpilih = await showDatePicker(
                        context: context,
                        initialDate: tanggalTerpilih ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (terpilih != null) {
                        setState(() {
                          tanggalTerpilih = terpilih;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "Pilih tanggal lahir",
                      hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                      labelText: "Tanggal Lahir",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: "Masukkan nomor telepon",
                    hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    labelText: "Nomor Telepon",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _saveProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: Text(
                    "Simpan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}