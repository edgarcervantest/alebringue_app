import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

class LessonLocalRepository {
  // El controller se instancia de forma lazy para evitar MissingPluginException
  // si el código se importa en un contexto donde el plugin no está registrado.
  WhisperController? _controller;

  String? _modelPath;
  bool _isInitialized = false;

  // Sincronizamos llamadas concurrentes a init() para evitar doble copia.
  Completer<void>? _initCompleter;

  static const String _assetPath = 'assets/models/ggml-small.bin';
  static const String _modelFileName = 'ggml-small.bin';

  // ──────────────────────────────────────────────────────────────────────────
  // INICIALIZACIÓN
  // ──────────────────────────────────────────────────────────────────────────

  /// Copia el modelo a la carpeta de documentos la primera vez y lo deja listo.
  /// Las llamadas concurrentes esperan a la misma operación (no duplican copia).
  Future<void> init() async {
    // ── Guardia Web ────────────────────────────────────────────────────────
    if (kIsWeb) {
      throw UnsupportedError(
        'whisper_ggml no es compatible con Flutter Web. '
        'Usa el backend remoto en esta plataforma.',
      );
    }

    // Ya inicializado: regresa inmediatamente.
    if (_isInitialized) return;

    // Si hay una init en curso, espera a que termine (evita doble trabajo).
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _controller = WhisperController();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/$_modelFileName';
      final File localFile = File(localPath);

      if (!await localFile.exists()) {
        debugPrint('[LocalRepo] Copiando modelo desde assets → $localPath');
        final byteData = await rootBundle.load(_assetPath);
        await localFile.writeAsBytes(byteData.buffer.asUint8List());
      } else {
        debugPrint('[LocalRepo] Modelo ya existe en: $localPath');
      }

      _modelPath = localPath;
      _isInitialized = true;
      _initCompleter!.complete();
    } catch (e) {
      final error = Exception('Error al cargar el modelo local: $e');
      _initCompleter!.completeError(error);
      // Reseteamos para que el próximo intento vuelva a intentar.
      _initCompleter = null;
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TRANSCRIPCIÓN
  // ──────────────────────────────────────────────────────────────────────────

  /// Transcribe el archivo de audio usando el modelo Whisper local.
  Future<String> transcribeLocally(File audioFile) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'La transcripción local no está disponible en Flutter Web.',
      );
    }

    if (!_isInitialized) {
      await init();
    }

    debugPrint('[LocalRepo] Transcribiendo: ${audioFile.path}');

    final result = await _controller!.transcribe(
      model: WhisperModel.small,
      audioPath: audioFile.path,
      lang: 'es',
    );

    if (result == null || result.transcription.text.trim().isEmpty) {
      throw Exception(
        'Whisper no produjo transcripción. '
        'Verifica que el audio tenga contenido de voz claro.',
      );
    }

    return result.transcription.text.trim();
  }
}