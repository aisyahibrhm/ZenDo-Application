import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database_helper.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late String _category, _priority;
  late bool _isCompleted;
  bool _isSaving = false;

  final _categories = ["Study", "Personal", "Work", "Health", "Finance"];
  final _priorities = ["High", "Medium", "Low"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _category = widget.task.category;
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() { _titleController.dispose(); super.dispose(); }

  Color _priorityColor(String p) => p == "High" ? const Color(0xFFD32F2F) : p == "Medium" ? const Color(0xFFF57C00) : const Color(0xFF388E3C);

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title cannot be empty'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSaving = true);
    widget.task.title = _titleController.text.trim();
    widget.task.category = _category;
    widget.task.priority = _priority;
    widget.task.isCompleted = _isCompleted;
    await DatabaseHelper.instance.updateTask(widget.task.id!, widget.task.toMap());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text('Task updated!')]),
        backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context, "update");
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange), SizedBox(width: 10), Text('Delete Task')]),
        content: Text('Delete "${widget.task.title}"?\n\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && widget.task.id != null) {
      await DatabaseHelper.instance.deleteTask(widget.task.id!);
      if (mounted) Navigator.pop(context, "delete");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text('Created: ${DateFormat('MMM dd, yyyy  h:mm a').format(widget.task.createdAt)}',
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
            ]),
          )),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.edit, color: Color(0xFF1976D2)), SizedBox(width: 8),
                Text('Edit Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title', prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.grey.shade50),
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Category', prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.grey.shade50),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Priority', prefixIcon: const Icon(Icons.priority_high),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.grey.shade50),
                items: _priorities.map((p) => DropdownMenuItem(value: p, child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: _priorityColor(p), shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(p, style: TextStyle(color: _priorityColor(p), fontWeight: FontWeight.w600)),
                ]))).toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: _isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('Mark as completed', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_isCompleted ? 'Completed ✓' : 'Pending',
                      style: TextStyle(color: _isCompleted ? Colors.green.shade700 : Colors.orange.shade700)),
                  value: _isCompleted,
                  onChanged: (v) => setState(() => _isCompleted = v),
                  activeColor: Colors.green,
                ),
              ),
            ]),
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save), SizedBox(width: 8), Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
          ),
        ]),
      ),
    );
  }
}