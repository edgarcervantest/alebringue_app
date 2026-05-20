import 'dart:convert';
import 'dart:io';

import 'package:alebringue/core/constants/constants.dart';
import 'package:alebringue/features/auth/repository/auth_local_repository.dart';
import 'package:alebringue/models/lesson_model.dart';
import 'package:alebringue/models/word_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LessonRepository {
  final AuthLocalRepository _authLocalRepository = AuthLocalRepository();

  // Timeout para peticiones HTTP — evita que la UI se quede esperando indefinidamente.
  static const Duration _kTimeout = Duration(seconds: 15);

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS PRIVADOS
  // ──────────────────────────────────────────────────────────────────────────

  Future<String> _getToken() async {
    final user = await _authLocalRepository.getUser();
    final token = user?.token;
    if (token == null || token.isEmpty) {
      throw 'No se encontró una sesión activa. Por favor, inicia sesión nuevamente.';
    }
    return token;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LECCIONES
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<LessonModel>> fetchLessons() async {
    try {
      final token = await _getToken();

      final res = await http
          .get(
            Uri.parse('${Constants.backendUri}/lesson'),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': token,
            },
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((item) => LessonModel.fromMap(item)).toList();
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw body['amsg'] ?? body['error'] ?? 'Error al obtener lecciones';
    } catch (e) {
      throw e.toString();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PALABRAS
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<WordModel>> fetchWords(int lessonId) async {
    try {
      final token = await _getToken();

      final response = await http
          .get(
            Uri.parse('${Constants.backendUri}/lesson/$lessonId/words'),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': token,
            },
          )
          .timeout(_kTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => WordModel.fromMap(item)).toList();
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw body['amsg'] ?? 'Error al cargar palabras';
    } catch (e) {
      throw e.toString();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TRANSCRIPCIÓN REMOTA
  // ──────────────────────────────────────────────────────────────────────────

  Future<String> sendAudioForWhisper(File audioFile, int lessonId) async {
    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.backendUri}/lesson/$lessonId/transcribe'),
    );
    request.headers['x-auth-token'] = token;
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFile.path),
    );

    // Timeout manual para MultipartRequest (no soporta .timeout() directo).
    final streamedResponse = await request.send().timeout(_kTimeout);

    if (streamedResponse.statusCode == 200) {
      final respStr = await streamedResponse.stream.bytesToString();
      final json = jsonDecode(respStr) as Map<String, dynamic>;
      final transcription = json['transcription'] as String?;

      if (transcription == null || transcription.trim().isEmpty) {
        throw Exception('El backend devolvió una transcripción vacía.');
      }
      return transcription.trim();
    }

    // Intenta leer el cuerpo del error para dar un mensaje descriptivo.
    final errStr = await streamedResponse.stream.bytesToString();
    debugPrint('[RemoteRepo] Error ${streamedResponse.statusCode}: $errStr');
    throw Exception(
      'Error al procesar audio (HTTP ${streamedResponse.statusCode})',
    );
  }
}