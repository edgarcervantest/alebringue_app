// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WordModel {
  final int lessonId;
  final int wordId;
  final String word;
  final String translation;
  final String pronunciation;
  final String audioPath;
  final int categoryId;
  WordModel({
    required this.lessonId,
    required this.wordId,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.audioPath,
    required this.categoryId,
  });

  WordModel copyWith({
    int? lessonId,
    int? wordId,
    String? word,
    String? translation,
    String? pronunciation,
    String? audioPath,
    int? categoryId,
  }) {
    return WordModel(
      lessonId: lessonId ?? this.lessonId,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      audioPath: audioPath ?? this.audioPath,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lessonId': lessonId,
      'wordId': wordId,
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'audioPath': audioPath,
      'categoryId': categoryId,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      lessonId: map['lessonId'] as int,
      wordId: map['wordId'] as int,
      word: map['word'] as String,
      translation: map['translation'] as String,
      pronunciation: map['pronunciation'] as String,
      audioPath: map['audioPath'] ?? '',
      categoryId: map['categoryId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory WordModel.fromJson(String source) => WordModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WordModel(lessonId: $lessonId, wordId: $wordId, word: $word, translation: $translation, pronunciation: $pronunciation, audioPath: $audioPath, categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant WordModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.lessonId == lessonId &&
      other.wordId == wordId &&
      other.word == word &&
      other.translation == translation &&
      other.pronunciation == pronunciation &&
      other.audioPath == audioPath &&
      other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return lessonId.hashCode ^
      wordId.hashCode ^
      word.hashCode ^
      translation.hashCode ^
      pronunciation.hashCode ^
      audioPath.hashCode ^
      categoryId.hashCode;
  }
}
