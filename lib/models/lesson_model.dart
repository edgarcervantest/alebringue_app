// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LessonModel {
  final int id;
  final String title;
  final String description;
  final int levelId;
  final String levelName;
  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.levelId,
    required this.levelName,
  });

  LessonModel copyWith({
    int? id,
    String? title,
    String? description,
    int? levelId,
    String? levelName,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      levelId: levelId ?? this.levelId,
      levelName: levelName ?? this.levelName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'levelId': levelId,
      'levelName': levelName,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      levelId: map['levelId'] as int,
      levelName: map['levelName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LessonModel.fromJson(String source) => LessonModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LessonModel(id: $id, title: $title, description: $description, levelId: $levelId, levelName: $levelName)';
  }

  @override
  bool operator ==(covariant LessonModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.levelId == levelId &&
      other.levelName == levelName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      levelId.hashCode ^
      levelName.hashCode;
  }
}
