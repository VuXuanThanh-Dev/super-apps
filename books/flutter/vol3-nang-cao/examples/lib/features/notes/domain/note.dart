import 'package:flutter/foundation.dart';

@immutable
class Note {
  const Note({required this.id, required this.title, required this.body, required this.updatedAt});

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {'id': id, 'title': title, 'body': body, 'updatedAt': updatedAt.toIso8601String()};

  factory Note.fromJson(Map<String, Object?> json) => Note(
    id: json['id']! as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    updatedAt: DateTime.parse(json['updatedAt']! as String),
  );

  Note copyWith({String? title, String? body, DateTime? updatedAt}) =>
      Note(id: id, title: title ?? this.title, body: body ?? this.body, updatedAt: updatedAt ?? this.updatedAt);

  @override
  bool operator ==(Object other) =>
      other is Note && other.id == id && other.title == title && other.body == body && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, title, body, updatedAt);
}
