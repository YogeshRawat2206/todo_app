import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tasks');
    if (saved != null) {
      setState(() {
        tasks = Task.decode(saved);
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', Task.encode(tasks));
  }

  void addOrEditTask({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    DateTime? selectedDate = task?.dueDate;
    Priority priority = task?.priority ?? Priority.low;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        DropdownButton<Priority>(
                          value: priority,
                          items: Priority.values
                              .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setModalState(() => priority = val!);
                          },
                        ),
                        const SizedBox(width: 20),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate != null
                                ? DateFormat.yMd().format(selectedDate!)
                                : "No date selected",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final newTask = Task(
                          title: titleController.text,
                          description: descController.text,
                          dueDate: selectedDate,
                          priority: priority,
                        );
                        setState(() {
                          if (task == null) {
                            tasks.add(newTask);
                          } else {
                            tasks[index!] = newTask;
                          }
                        });
                        saveTasks();
                        Navigator.pop(context);
                      },
                      child: Text(task == null ? "Add Task" : "Update Task"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void toggleCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Toggle Dark Mode',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, i) {
          final task = tasks[i];
          return TaskTile(
            task: task,
            onTap: () => toggleCompletion(i),
            onEdit: () => addOrEditTask(task: task, index: i),
            onDelete: () => deleteTask(i),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
