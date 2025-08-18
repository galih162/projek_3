import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalenderScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile; // Ambil data user dari HomeScreen

  const CalenderScreen({super.key, this.userProfile});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> tasks = [];
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    getTasksForDate(selectedDate);
  }

  Future<void> getTasksForDate(String date) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('date', date);

      setState(() {
        tasks = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal ambil task: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userProfile?['name'] ?? 'Pengguna';

    // generate 7 hari sekitar sekarang
    final days = List.generate(7, (i) {
      final date = DateTime.now().add(Duration(days: i - 2));
      return DateFormat('yyyy-MM-dd').format(date);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Today',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF584A4A)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF584A4A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Productive Day, $userName',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF584A4A)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF584A4A)),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final dayNum = int.parse(date.split('-')[2]);
                final isSelected = date == selectedDate;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    getTasksForDate(date);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    width: 45,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFA0D7C8) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks today!',
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xFFA0D7C8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                task['time'] ?? '-',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, color: Color(0xFF584A4A)),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  task['title'] ?? '-',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600, color: Color(0xFF584A4A)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
