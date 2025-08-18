import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TaskDoneScreen extends StatefulWidget {
  const TaskDoneScreen({super.key});

  @override
  State<TaskDoneScreen> createState() => _TaskDoneScreenState();
}

class _TaskDoneScreenState extends State<TaskDoneScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> doneTasks = [];

  @override
  void initState() {
    super.initState();
    fetchDoneTasks();
  }

  Future<void> fetchDoneTasks() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .eq('done', true);

      setState(() {
        doneTasks = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil task done: $e')),
      );
    }
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

  void showDeleteDialog(Map<String, dynamic> task, int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: "Confirm Delete Task",
      desc: "Are you sure you want to delete this task?",
      btnOkOnPress: () async {
        try {
          await supabase.from('tasks').delete().eq('id', task['id']);
          setState(() {
            doneTasks.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task deleted")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal hapus task: $e")),
          );
        }
      },
      btnCancelOnPress: () {},
      showCloseIcon: true,
    ).show();
  }

  Future<void> uncheckTask(Map<String, dynamic> task, int index) async {
    try {
      await supabase.from('tasks').update({'done': false}).eq('id', task['id']);
      setState(() {
        doneTasks.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update task: $e")),
      );
    }
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
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // LIST DONE TASK
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: ListView.builder(
                  itemCount: doneTasks.length,
                  itemBuilder: (context, index) {
                    final task = doneTasks[index];
                    final date = DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(task['date']));
                    final time = task['time'] ?? '-';
                    final category = task['category'] ?? 'Other';

                    return Column(
                      children: [
                        Slidable(
                          key: ValueKey(task['id']),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => showDeleteDialog(task, index),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            color: const Color(0xFFA0D7C8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child:
                                    Icon(getCategoryIcon(category), size: 30),
                              ),
                              title: Text(task['title']),
                              subtitle: Text('$date, $time'),
                              trailing: Checkbox(
                                value: true,
                                onChanged: (bool? value) {
                                  if (value == false) uncheckTask(task, index);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
