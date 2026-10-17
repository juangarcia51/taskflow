import 'package:flutter/material.dart';

enum Priority {
  alta(
    label: 'Alta',
    foreground: Color(0xFFEF4444),
    background: Color(0xFFFEE2E2),
  ),
  media(
    label: 'Media',
    foreground: Color(0xFFF59E0B),
    background: Color(0xFFFEF3C7),
  ),
  baja(
    label: 'Baja',
    foreground: Color(0xFF10B981),
    background: Color(0xFFD1FAE5),
  );

  final String label;
  final Color foreground;
  final Color background;

  const Priority({
    required this.label,
    required this.foreground,
    required this.background,
  });
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String category;
  final Priority priority;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });

  /// Getter seguro para evitar errores de tipo en Flutter Web si hay estado residual
  String get descText => description ?? '';

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
