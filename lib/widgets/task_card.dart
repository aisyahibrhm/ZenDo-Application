import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String category;
  final String priority;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.title,
    required this.category,
    required this.priority,
    required this.completed,
    required this.onToggle,
    this.onEdit,
  });

  Color getPriorityColor() {
    switch (priority) {
      case "High": return Colors.red.shade100;
      case "Medium": return Colors.orange.shade100;
      case "Low": return Colors.green.shade100;
      default: return Colors.grey.shade200;
    }
  }

  Color getPriorityBorderColor() {
    switch (priority) {
      case "High": return const Color(0xFFD32F2F);
      case "Medium": return const Color(0xFFF57C00);
      case "Low": return const Color(0xFF388E3C);
      default: return Colors.grey;
    }
  }

  IconData getCategoryIcon() {
    switch (category) {
      case 'Study': return Icons.school;
      case 'Personal': return Icons.person;
      case 'Work': return Icons.work;
      case 'Health': return Icons.favorite;
      case 'Finance': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: getPriorityColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? Colors.green : getPriorityBorderColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? Colors.green : Colors.white,
                    border: Border.all(color: completed ? Colors.green : Colors.grey, width: 2),
                  ),
                  child: completed ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: completed ? TextDecoration.lineThrough : null,
                        color: completed ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(getCategoryIcon(), size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(category, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: getPriorityBorderColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: getPriorityBorderColor()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (onEdit != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Color(0xFF1976D2)),
                    onPressed: onEdit,
                    tooltip: 'Edit task',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}