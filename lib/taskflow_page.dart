import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'header_card.dart';
import 'priority_chip.dart';
import 'quote_card.dart';
import 'section_header.dart';
import 'task.dart';
import 'task_provider.dart';
import 'top_bar.dart';

class TaskflowPage extends ConsumerWidget {
  const TaskflowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final progress = ref.watch(taskProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'TaskFlow', avatarLetter: 'J'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  HeaderCard(
                    greeting: '¡Hola, Jose!',
                    date: 'Sábado, 3 de Octubre',
                    subtitle: '${tasks.where((t) => t.isCompleted).length} de ${tasks.length} completadas',
                    progress: progress,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Tareas pendientes',
                    actionLabel: '+ Nueva',
                    onAction: () => _showAddTaskDialog(context, ref),
                  ),
                  const SizedBox(height: AppDimensions.gap),
                  if (tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppDimensions.margin),
                      child: Center(
                        child: Text(
                          'No hay tareas pendientes',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...tasks.map((task) => _TaskItemTile(task: task)),
                  const SizedBox(height: 20),
                  const QuoteCard(
                    quote: 'La simplicidad es el requisito previo para la fiabilidad.',
                    author: 'Edsger W. Dijkstra',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        destinations: const [
          BottomDestination(icon: Icons.check_circle_outline, label: 'Tareas'),
          BottomDestination(icon: Icons.bar_chart_outlined, label: 'Métricas'),
          BottomDestination(icon: Icons.person_outline, label: 'Perfil'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref.read(taskListProvider.notifier).addTask(
                      titleController.text.trim(),
                      categoryController.text.trim().isEmpty
                          ? 'General'
                          : categoryController.text.trim(),
                      Priority.media,
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _TaskItemTile extends ConsumerWidget {
  final Task task;

  const _TaskItemTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.margin,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.taskCardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.taskCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: AppColors.gold,
              onChanged: (_) {
                ref.read(taskListProvider.notifier).toggleTask(task.id);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? AppColors.textMuted
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            PriorityChip(priority: task.priority),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              onPressed: () {
                ref.read(taskListProvider.notifier).deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}