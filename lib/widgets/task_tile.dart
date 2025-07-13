import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
          task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description.isNotEmpty) Text(task.description),
          if (task.dueDate != null)
            Text("Due: ${DateFormat.yMMMd().format(task.dueDate!)}"),
          Text("Priority: ${task.priority.name.toUpperCase()}"),
        ],
      ),
      leading: Checkbox(value: task.isCompleted, onChanged: (_) => onTap()),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ]),
    );
  }
}
