import 'dart:convert';

enum Priority { low, medium, high }

class Task {
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  Priority priority;

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.priority = Priority.low,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority.index,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    title: map['title'],
    description: map['description'],
    isCompleted: map['isCompleted'],
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    priority: Priority.values[map['priority']],
  );

  static String encode(List<Task> tasks) =>
      json.encode(tasks.map((t) => t.toMap()).toList());

  static List<Task> decode(String tasks) =>
      (json.decode(tasks) as List).map((t) => Task.fromMap(t)).toList();
}
