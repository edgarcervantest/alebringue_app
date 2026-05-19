import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

class LessonLocalRepository {
  final WhisperController _controller = WhisperController();
  String? _modelPath;
  bool _isInitialized = false;

  // Ruta exacta dentro de tus assets
  final String _assetPath = 'assets/models/ggml-small.bin';

  /// 1. Inicializa el modelo copiándolo a memoria interna
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/ggml-small.bin';
      final File localFile = File(localPath);

      // Si el archivo ya existe, no lo volvemos a copiar (ahorra tiempo)
      if (!await localFile.exists()) {
        final byteData = await rootBundle.load(_assetPath);
        await localFile.writeAsBytes(byteData.buffer.asUint8List());
      }
      
      _modelPath = localPath;
      _isInitialized = true;
      debugPrint("Modelo inicializado correctamente en: $_modelPath");
    } catch (e) {
      throw Exception("Error al cargar el modelo local: $e");
    }
  }

  /// 2. Transcribe el audio localmente
  Future<String> transcribeLocally(File audioFile) async {
    if (!_isInitialized) {
      await init();
    }

    // Nota: whisper_ggml suele pedir un Enum para identificar el modelo,
    // pero si estás usando un custom bin, verifica si tu librería permite
    // pasar el path directamente. Si la librería te obliga a usar 'WhisperModel',
    // asegúrate de que el nombre del asset coincida con lo que el controller espera.
    
    // Asumiendo que la librería permite la transcripción con el modelo cargado:
    final result = await _controller.transcribe(
      model: WhisperModel.small, // Asegúrate de que esto coincida con tu bin
      audioPath: audioFile.path,
      lang: 'es', // Lenguaje principal para tu modelo
    );

    if (result == null || result.transcription.text.isEmpty) {
      throw Exception("No se pudo obtener transcripción");
    }

    return result.transcription.text;
  }
}