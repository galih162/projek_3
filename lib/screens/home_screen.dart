import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek2_aplikasi_todolist/screens/calendar_screen.dart';
import 'package:projek2_aplikasi_todolist/screens/task_todo_screen.dart';
import 'package:projek2_aplikasi_todolist/screens/task_done_screen.dart';
import 'package:projek2_aplikasi_todolist/screens/my_profile_screen.dart';
import 'package:projek2_aplikasi_todolist/screens/create_task_screen.dart';
import 'package:projek2_aplikasi_todolist/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  int todoCount = 0;
  int doneCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadTaskCounts();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    final currentUser = await _supabaseService.getCurrentUser();
    final userId = currentUser['id'];
    if (userId != null) {
      final result = await _supabaseService.getUserProfile(userId);
      if (result['success']) {
        setState(() {
          userProfile = result['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Gagal memuat profil: ${result['message']}',
            isError: true);
      }
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Pengguna tidak ditemukan.', isError: true);
    }
  }

  Future<void> _loadTaskCounts() async {
    try {
      final currentUser = await _supabaseService.getCurrentUser();
      final userId = currentUser['id'];
      if (userId != null) {
        final result = await _supabaseService.getUserTasks(userId);
        if (result['success']) {
          final tasks = result['data'] as List<dynamic>;
          setState(() {
            todoCount = tasks.where((t) => t['done'] == false).length;
            doneCount = tasks.where((t) => t['done'] == true).length;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Gagal load task count: $e', isError: true);
    }
  }

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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _refreshHome() async {
    await _loadUserProfile();
    await _loadTaskCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Profil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 40),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4)),
                      ],
                      gradient: LinearGradient(
                        colors: [Color(0xFFA0D7C8), Color(0xFFA0C7D7)],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.account_circle_outlined,
                              size: 70),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                color: Color(0xFF584A4A),
                              ),
                            ),
                            Text(
                              userProfile?['name'] ?? 'Pengguna',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                color: Color(0xFF584A4A),
                              ),
                            ),
                            Text(
                              userProfile?['bio'] ?? 'Bio belum diatur',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF584A4A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // My Task & Calendar
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Task',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TaskTodoScreen()),
                            ).then((_) => _refreshHome());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA0D7C8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(Icons.schedule, size: 60),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To Do',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF584A4A),
                                      ),
                                    ),
                                    Text(
                                      '$todoCount Task Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF584A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TaskDoneScreen()),
                            ).then((_) => _refreshHome());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA0D7C8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(Icons.check_circle_outline,
                                      size: 60),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Done',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF584A4A),
                                      ),
                                    ),
                                    Text(
                                      '$todoCount Task Now | $doneCount Task Done',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF584A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Calendar Appointment Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA0D7C8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CalenderScreen(
                                          userProfile: userProfile),
                                    ),
                                  ).then((_) => _refreshHome());
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(Icons.calendar_month,
                                          size: 60),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Calendar Appointment',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF584A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Thank You Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA0D7C8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Text(
                        "Terima Kasih sudah menjadi manusia \nbertanggung jawab\nKlik tombol '+' di bawah untuk tambah tugas",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      // Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFA0D7C8),
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
            ).then((_) => _refreshHome());
          },
          child: const Icon(Icons.add, size: 40, color: Colors.black),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color(0xFFA0D7C8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _refreshHome,
              icon: const Icon(Icons.home, color: Color(0xFF584A4A), size: 45),
            ),
            const SizedBox(width: 120),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProfileScreen()),
                ).then((_) => _refreshHome());
              },
              icon:
                  const Icon(Icons.person, color: Color(0xFF584A4A), size: 45),
            ),
          ],
        ),
      ),
    );
  }
}
