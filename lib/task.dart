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
  int? serverId; // Identificador en el servidor REST (null si es local o no asignado)
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String category;
  final Priority priority;
  final bool isCompleted;

  Task({
    required this.id,
    this.serverId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.category = 'General',
    this.priority = Priority.media,
    this.isCompleted = false,
  });

  /// Getter seguro para evitar errores en Flutter Web si hay valores residuales
  String get descText => description ?? '';

  /// Construye una Task a partir del JSON de la API REST (JSONPlaceholder).
  /// Lanza FormatException si el título no es utilizable.
  factory Task.fromJson(Map<String, dynamic> json) {
    final titleRaw = json['title'];
    if (titleRaw is! String || titleRaw.trim().isEmpty) {
      throw const FormatException('La tarea recibida no tiene un título válido.');
    }
    final rawId = json['id'];
    final parsedServerId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    return Task(
      id: parsedServerId != null ? 'remote_$parsedServerId' : DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: parsedServerId,
      title: titleRaw.trim(),
      // La API no envía fecha ni descripción: aplicamos valores predeterminados defensivos
      dueDate: DateTime.now().add(const Duration(days: 7)),
      description: 'Tarea sincronizada desde la nube',
      category: 'General',
      priority: Priority.media,
      isCompleted: json['completed'] == true,
    );
  }

  /// Convierte la Task al formato esperado por la API REST
  Map<String, dynamic> toJson() => {
    'title': title,
    'completed': isCompleted,
    'userId': 1,
  };

  Task copyWith({
    String? id,
    int? serverId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
