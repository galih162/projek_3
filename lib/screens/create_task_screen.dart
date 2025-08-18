import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();

  final List<String> listKategori = [
    'Religius',
    'Personal',
    'Healthy',
    'Shopping',
    'Work',
    'Other'
  ];
  final List<String> listPrioritas = ['High', 'Mid', 'Low'];

  String? kategoriTerpilih;
  String? prioritasTerpilih;
  DateTime? tanggalTerpilih;
  TimeOfDay? waktuTerpilih;

  final supabase = Supabase.instance.client;

  String get formatTanggal {
    if (tanggalTerpilih == null) return '';
    return DateFormat('MMMM d, yyyy').format(tanggalTerpilih!);
  }

  String get formatWaktu {
    if (waktuTerpilih == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, waktuTerpilih!.hour,
        waktuTerpilih!.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> simpanData() async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User belum login!');
      }

      final userId = supabase.auth.currentUser!.id;

      // Insert data ke Supabase
      await supabase.from('tasks').insert({
        'title': titleController.text,
        'category': kategoriTerpilih,
        'priority': prioritasTerpilih,
        'date': formatTanggal,
        'time': formatWaktu,
        'notes': notesController.text,
        'user_id': userId,
      });

      titleController.clear();
      notesController.clear();
      setState(() {
        kategoriTerpilih = null;
        prioritasTerpilih = null;
        tanggalTerpilih = null;
        waktuTerpilih = null;
      });

      showTopSnackBar(context, '✅ Task Saved Successfully');
    } catch (e) {
      showTopSnackBar(context, '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Add New Task',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF584A4A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text("Task Title",
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF584A4A))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        style: GoogleFonts.poppins(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: "Input your task title",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 18, color: const Color(0xFF584A4A)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: const Color(0xFFA0D7C8),
                          filled: true,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),

                      // CATEGORY
                      Text("Category",
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF584A4A))),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: kategoriTerpilih,
                        hint: Text("Select Category",
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: const Color(0xFF584A4A))),
                        items: listKategori
                            .map((String kategori) => DropdownMenuItem(
                                  value: kategori,
                                  child: Text(kategori,
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => kategoriTerpilih = value),
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFA0D7C8),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PRIORITY
                      Text("Priority",
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF584A4A))),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: prioritasTerpilih,
                        hint: Text("Select Priority",
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: const Color(0xFF584A4A))),
                        items: listPrioritas
                            .map((String prioritas) => DropdownMenuItem(
                                  value: prioritas,
                                  child: Text(prioritas,
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => prioritasTerpilih = value),
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFA0D7C8),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // DATE + TIME
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date",
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF584A4A))),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: formatTanggal),
                                  decoration: InputDecoration(
                                    fillColor: const Color(0xFFA0D7C8),
                                    filled: true,
                                    suffixIcon:
                                        const Icon(Icons.calendar_month),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onTap: () async {
                                    final DateTime? terpilih =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          tanggalTerpilih ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (terpilih != null) {
                                      setState(() {
                                        tanggalTerpilih = terpilih;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Time",
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF584A4A))),
                                TextField(
                                  readOnly: true,
                                  controller:
                                      TextEditingController(text: formatWaktu),
                                  decoration: InputDecoration(
                                    fillColor: const Color(0xFFA0D7C8),
                                    filled: true,
                                    suffixIcon: const Icon(Icons.access_time),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? terpilih =
                                        await showTimePicker(
                                      context: context,
                                      initialTime:
                                          waktuTerpilih ?? TimeOfDay.now(),
                                    );
                                    if (terpilih != null) {
                                      setState(() {
                                        waktuTerpilih = terpilih;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // NOTES
                      Text("Notes",
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF584A4A))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesController,
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: const Color(0xFF584A4A)),
                        decoration: InputDecoration(
                          hintText: "Input your notes (optional)",
                          hintStyle: GoogleFonts.poppins(fontSize: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: const Color(0xFFA0D7C8),
                          filled: true,
                        ),
                        maxLines: 6,
                      ),
                      const SizedBox(height: 35),

                      // SAVE BUTTON
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await simpanData();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF584A4A),
                            backgroundColor: const Color(0xFFA0D7C8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text("Save",
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF584A4A))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showTopSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Material(
        elevation: 10,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF5DEE4F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF15FF00), width: 4),
          ),
          child: Center(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
