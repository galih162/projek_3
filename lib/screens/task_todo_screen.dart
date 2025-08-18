import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'task_done_screen.dart'; // pastikan ini ada

class TaskTodoScreen extends StatefulWidget {
  const TaskTodoScreen({super.key});

  @override
  State<TaskTodoScreen> createState() => _TaskTodoScreenState();
}

class _TaskTodoScreenState extends State<TaskTodoScreen> {
  List<Map<String, dynamic>> tasks = [];

  final supabase = Supabase.instance.client;

  final List<String> listKategori = [
    'Religius',
    'Personal',
    'Healthy',
    'Shopping',
    'Work',
    'Other'
  ];

  final List<String> listPrioritas = ['High', 'Mid', 'Low'];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "religius":
        return Icons.self_improvement;
      case "personal":
        return Icons.person;
      case "healthy":
        return Icons.fitness_center;
      case "shopping":
        return Icons.shopping_cart;
      case "work":
        return Icons.work;
      case "other":
      default:
        return Icons.task;
    }
  }

  Future<void> getTasks() async {
    final response = await supabase.from('tasks').select();
    List tasksFromDb = response;

    tasksFromDb.sort((a, b) {
      const order = {'High': 1, 'Mid': 2, 'Low': 3};
      return (order[a['priority']] ?? 99).compareTo(order[b['priority']] ?? 99);
    });

    final mappedTasks = tasksFromDb.map((task) {
      final category = (task['category'] ?? 'Other').toString();
      final date = DateTime.parse(task['date']);
      final String formattedDate = DateFormat('dd MMM yyyy').format(date);
      final priority = (task['priority'] ?? 'Low').toString();

      return {
        'id': task['id'],
        'title': task['title'],
        'subtitle': "$priority • $formattedDate",
        'done': task['done'] ?? false,
        'icon': getCategoryIcon(category),
        'description': task['notes'] ?? '',
        'category': category,
        'date': formattedDate,
        'time': task['time'] ?? '-',
        'priority': priority,
      };
    }).toList();

    setState(() {
      tasks = mappedTasks;
    });
  }

  void showDeleteDialog(String id) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: "Confirm Delete Data",
      desc: "Are You Sure You Want To Delete Data?",
      showCloseIcon: true,
      btnOkOnPress: () async {
        await supabase.from('tasks').delete().eq('id', id);
        setState(() {
          tasks.removeWhere((task) => task['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Sudah Terhapus"),
            backgroundColor: Color(0xFF15FF00),
            duration: Duration(seconds: 2),
          ),
        );
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void showEditBottomSheet(Map<String, dynamic> task, int index) {
    final titleController = TextEditingController(text: task['title']);
    final notesController = TextEditingController(text: task['description']);
    String kategoriTerpilih = task['category'];
    String prioritasTerpilih = task['priority'];

    // Parsing date
    DateTime tanggalTerpilih = DateFormat('dd MMM yyyy').parse(task['date']);
    // Parsing time
    TimeOfDay waktuTerpilih = task['time'] != '-'
        ? TimeOfDay(
            hour: int.parse(task['time'].split(":")[0]),
            minute: int.parse(task['time'].split(":")[1]),
          )
        : TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20),
        child: StatefulBuilder(
          builder: (context, setStateModal) => SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: kategoriTerpilih,
                  items: listKategori
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setStateModal(() => kategoriTerpilih = val!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: prioritasTerpilih,
                  items: listPrioritas
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setStateModal(() => prioritasTerpilih = val!),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 10),
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(tanggalTerpilih)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalTerpilih,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setStateModal(() => tanggalTerpilih = picked);
                    }
                  },
                ),
                // Time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Time: ${waktuTerpilih.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: waktuTerpilih,
                    );
                    if (picked != null) {
                      setStateModal(() => waktuTerpilih = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final formattedDate =
                        DateFormat('dd MMM yyyy').format(tanggalTerpilih);
                    final formattedTime =
                        '${waktuTerpilih.hour.toString().padLeft(2, '0')}:${waktuTerpilih.minute.toString().padLeft(2, '0')}';

                    await supabase.from('tasks').update({
                      'title': titleController.text,
                      'category': kategoriTerpilih,
                      'priority': prioritasTerpilih,
                      'notes': notesController.text,
                      'date': formattedDate,
                      'time': formattedTime,
                    }).eq('id', task['id']);

                    setState(() {
                      tasks[index]['title'] = titleController.text;
                      tasks[index]['category'] = kategoriTerpilih;
                      tasks[index]['priority'] = prioritasTerpilih;
                      tasks[index]['description'] = notesController.text;
                      tasks[index]['icon'] = getCategoryIcon(kategoriTerpilih);
                      tasks[index]['date'] = formattedDate;
                      tasks[index]['time'] = formattedTime;
                      tasks[index]['subtitle'] =
                          "$prioritasTerpilih • $formattedDate";
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Update Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                  Expanded(
                    child: Text(
                      'To Do Day',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF584A4A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // TASK LIST
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Column(
                      children: [
                        Slidable(
                          key: ValueKey(task['id']),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => showDeleteDialog(task['id']),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                              SlidableAction(
                                onPressed: (_) =>
                                    showEditBottomSheet(task, index),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                            ],
                          ),
                          child: Card(
                            color: const Color(0xFFA0D7C8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ExpansionTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(task['icon'], size: 30),
                              ),
                              title: Text(
                                task['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF584A4A)),
                              ),
                              subtitle: Text(task['subtitle']),
                              trailing: Checkbox(
                                value: task['done'],
                                onChanged: (bool? value) async {
                                  final newValue = value ?? false;

                                  // Update database
                                  try {
                                    await supabase
                                        .from('tasks')
                                        .update({'done': newValue}).eq(
                                            'id', task['id']);
                                  } catch (e) {
                                    // kalo error rollback UI
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Gagal update status: $e")),
                                    );
                                    return;
                                  }

                                  // Update UI
                                  setState(() {
                                    tasks[index]['done'] = newValue;
                                  });

                                  // Kalau sudah done, navigasi ke TaskDoneScreen
                                  if (newValue) {
                                    // Delay dikit supaya setState dulu jalan
                                    Future.microtask(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TaskDoneScreen()),
                                      );
                                    });
                                  }
                                },
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "📝 Deskripsi: ${task['description']}"),
                                      Text("📂 Kategori: ${task['category']}"),
                                      Text("📅 Date: ${task['date']}"),
                                      Text("⏰ Time: ${task['time']}"),
                                      Text("⭐ Prioritas: ${task['priority']}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
