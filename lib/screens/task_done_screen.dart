import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDoneScreen extends StatelessWidget {
  const TaskDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas (judul + tanggal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
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
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new_rounded)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Done To Do',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // const SizedBox(height: 20),

            // List tugas harian
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ListView(
                  children: [
                    Card(
                      color: Color(0xFFA0D7C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Icon(
                            Icons.cleaning_services,
                            size: 30,
                          ),
                        ),
                        title: Text('Mencuci piring'),
                        subtitle: Text('23 Juli 2025, 19:00'),
                        trailing: Checkbox(
                          value: true,
                          onChanged: null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      color: Color(0xFFA0D7C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Icon(
                            Icons.directions_run,
                            size: 30,
                          ),
                        ),
                        title: Text('Jogging'),
                        subtitle: Text('23 Juli 2025, 05:00'),
                        trailing: Checkbox(
                          value: true,
                          onChanged: null,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      color: Color(0xFFA0D7C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Icon(
                            Icons.group,
                            size: 30,
                          ),
                        ),
                        title: Text('Bermain bersama teman'),
                        subtitle: Text('23 Juli 2025, 19:00'),
                        trailing: Checkbox(
                          value: true,
                          onChanged: null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}