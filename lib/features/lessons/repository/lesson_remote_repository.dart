import 'dart:convert';
import 'dart:io';
import 'package:alebringue/models/word_model.dart';
import 'package:http/http.dart' as http;
import 'package:alebringue/core/constants/constants.dart';
import 'package:alebringue/features/auth/repository/auth_local_repository.dart'; // Tu repositorio Sqflite
import 'package:alebringue/models/lesson_model.dart';

class LessonRepository {
  // Instanciamos el repositorio local de Sqflite
  final AuthLocalRepository _authLocalRepository = AuthLocalRepository();

  // Ya no necesitamos pedir el token por parámetro en la función:
  Future<List<LessonModel>> fetchLessons() async {
    try {
      // 1. Obtener de forma asíncrona el usuario guardado en Sqflite
      final user = await _authLocalRepository.getUser();
      final String? token = user?.token;

      // Si no hay usuario o token en la BD local, detenemos la petición
      if (token == null || token.isEmpty) {
        throw 'No se encontró una sesión activa. Por favor, inicia sesión nuevamente.';
      }

      // 2. Realizar la petición HTTP usando el token recuperado de Sqflite
      final res = await http.get(
        Uri.parse('${Constants.backendUri}/lesson'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token':
              token, // Usamos la cabecera que espera tu middleware de Express
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        return list.map((item) => LessonModel.fromMap(item)).toList();
      } else {
        final body = jsonDecode(res.body);
        throw body['amsg'] ?? body['error'] ?? 'Error al obtener lecciones';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Función para llamar a tu backend
  Future<List<WordModel>> fetchWords(int lessonId) async {
    try {
      // 1. Obtener token siempre para asegurar consistencia
      final user = await _authLocalRepository.getUser();
      final String? token = user?.token;

      if (token == null || token.isEmpty) {
        throw 'Sesión no activa.';
      }

      // 2. Petición HTTP
      final response = await http.get(
        Uri.parse('${Constants.backendUri}/lesson/$lessonId/words'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      // 3. Manejo de respuesta
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => WordModel.fromMap(item)).toList();
      } else {
        final body = jsonDecode(response.body);
        throw body['amsg'] ?? 'Error al cargar palabras';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> sendAudioForWhisper(File audioFile, int lessonId) async {
    final user = await _authLocalRepository.getUser();
    final token = user?.token;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.backendUri}/lesson/$lessonId/transcribe'),
    );

    request.headers['x-auth-token'] = token!;

    // Adjuntamos el archivo
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFile.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(
        respStr,
      )['transcription']; // El texto que devuelve Whisper
    } else {
      throw Exception('Error al procesar audio');
    }
  }
}
