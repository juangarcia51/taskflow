import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'header_card.dart';
import 'nueva_tarea_screen.dart';
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
                    onAction: () => _navegarNuevaTarea(context, ref),
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        onPressed: () => _navegarNuevaTarea(context, ref),
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

  Future<void> _navegarNuevaTarea(BuildContext context, WidgetRef ref) async {
    final nueva = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const NuevaTareaScreen()),
    );

    if (nueva == null) return;

    ref.read(taskListProvider.notifier).addTaskObject(nueva);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarea "${nueva.title}" creada con éxito'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TaskItemTile extends ConsumerWidget {
  final Task task;

  const _TaskItemTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String fechaStr = task.dueDate != null
        ? '${task.dueDate!.day.toString().padLeft(2, '0')}/${task.dueDate!.month.toString().padLeft(2, '0')}/${task.dueDate!.year}'
        : '';
    final String descripcion = task.descText;

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
                  if (descripcion.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        task.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (fechaStr.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.event, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          fechaStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
