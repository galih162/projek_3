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
        _showSnackBar(
          'Gagal memuat profil: ${result['message']}',
          isError: true,
        );
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
              fontSize:
                  MediaQuery.of(context).size.width *
                  0.04, // Responsive font size
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Profil
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.075, // 30/400 ~ 7.5%
                        vertical: screenHeight * 0.05, // 40/800 ~ 5%
                      ),
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
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
                            width: screenWidth * 0.2, // 80/400 ~ 20%
                            height: screenWidth * 0.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_circle_outlined,
                              size: screenWidth * 0.175, // 70/400 ~ 17.5%
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.025), // 10/400 ~ 2.5%
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello,',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: screenWidth * 0.06, // 24/400 ~ 6%
                                  color: const Color(0xFF584A4A),
                                ),
                              ),
                              Text(
                                userProfile?['name'] ?? 'Pengguna',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: screenWidth * 0.06,
                                  color: const Color(0xFF584A4A),
                                ),
                              ),
                              Text(
                                userProfile?['bio'] ?? 'Bio belum diatur',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      screenWidth * 0.0375, // 15/400 ~ 3.75%
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF584A4A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025), // 20/800 ~ 2.5%
                    // My Task & Calendar
                    Padding(
                      padding: EdgeInsets.all(
                        screenWidth * 0.075,
                      ), // 30/400 ~ 7.5%
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Task',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.06, // 24/400 ~ 6%
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF584A4A),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.0125,
                          ), // 10/800 ~ 1.25%
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TaskTodoScreen(),
                                ),
                              ).then((_) => _refreshHome());
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                screenWidth * 0.05,
                              ), // 20/400 ~ 5%
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0D7C8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        screenWidth * 0.175, // 70/400 ~ 17.5%
                                    height: screenWidth * 0.175,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.schedule,
                                      size: screenWidth * 0.15, // 60/400 ~ 15%
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.03,
                                  ), // 12/400 ~ 3%
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To Do',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              screenWidth * 0.05, // 20/400 ~ 5%
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF584A4A),
                                        ),
                                      ),
                                      Text(
                                        '$todoCount Task Now',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              screenWidth *
                                              0.0375, // 15/400 ~ 3.75%
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF584A4A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ), // 20/800 ~ 2.5%
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TaskDoneScreen(),
                                ),
                              ).then((_) => _refreshHome());
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                screenWidth * 0.05,
                              ), // 20/400 ~ 5%
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0D7C8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        screenWidth * 0.175, // 70/400 ~ 17.5%
                                    height: screenWidth * 0.175,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: screenWidth * 0.15, // 60/400 ~ 15%
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.03,
                                  ), // 12/400 ~ 3%
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Done',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              screenWidth * 0.05, // 20/400 ~ 5%
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF584A4A),
                                        ),
                                      ),
                                      Text(
                                        '$todoCount Task Now | $doneCount Task Done',
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              screenWidth *
                                              0.0375, // 15/400 ~ 3.75%
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF584A4A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ), // 20/800 ~ 2.5%
                          // Calendar Appointment Card
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CalenderScreen(userProfile: userProfile),
                                ),
                              ).then((_) => _refreshHome());
                            },
                            child: _taskCard(
                              icon: Icons.calendar_month,
                              title: "Calendar Appointment",
                              style: GoogleFonts.poppins(
                                fontSize:
                                    screenWidth *
                                    0.0375, // Responsive font size (15px for 400px screen)
                                fontWeight: FontWeight.w600,
                                color: Colors
                                    .black, // Added explicit color for consistency
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ), // 20/800 ~ 2.5%
                          // Thank You Card
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(
                                screenWidth * 0.03,
                              ), // 12/400 ~ 3%
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0D7C8),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Terima Kasih sudah menjadi manusia \nbertanggung jawab\nKlik tombol '+' di bawah untuk tambah tugas",
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      screenWidth * 0.0375, // 15/400 ~ 3.75%
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      // Floating Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: screenWidth * 0.2, // 80/400 ~ 20%
        width: screenWidth * 0.2,
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
          child: Icon(
            Icons.add,
            size: screenWidth * 0.1, // 40/400 ~ 10%
            color: Colors.black,
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color(0xFFA0D7C8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _refreshHome,
              icon: Icon(
                Icons.home,
                color: const Color(0xFF584A4A),
                size: screenWidth * 0.1125, // 45/400 ~ 11.25%
              ),
            ),
            SizedBox(width: screenWidth * 0.3), // 120/400 ~ 30%
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProfileScreen()),
                ).then((_) => _refreshHome());
              },
              icon: Icon(
                Icons.person,
                color: const Color(0xFF584A4A),
                size: screenWidth * 0.1125, // 45/400 ~ 11.25%
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable card widget
  Widget _taskCard({
    required IconData icon,
    required String title,
    TextStyle? style,
    String? subtitle,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05), // 20/400 ~ 5%
      decoration: BoxDecoration(
        color: const Color(0xFFA0D7C8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.175, // 70/400 ~ 17.5%
            height: screenWidth * 0.175,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              icon,
              size: screenWidth * 0.15, // 60/400 ~ 15%
            ),
          ),
          SizedBox(width: screenWidth * 0.03), // 12/400 ~ 3%
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.05, // 20/400 ~ 5%
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF584A4A),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.0375, // 15/400 ~ 3.75%
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF584A4A),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
