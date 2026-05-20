// lib/features/lessons/repository/lesson_local_repository.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:vosk_flutter_service/vosk_flutter.dart';

class LessonLocalRepository {
  // Instancia única del plugin de Vosk
  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  
  Model? _model;
  Recognizer? _recognizer;
  bool _isInitialized = false;

  // Sincronizamos llamadas concurrentes a init()
  Completer<void>? _initCompleter;

  // RECUERDA: Vosk maneja los modelos como archivos comprimidos .zip en assets
  static const String _assetPath = 'assets/models/vosk-model-small-en-us-0.15.zip';
  static const int _sampleRate = 16000; // Frecuencia estándar recomendada para Vosk

  // ──────────────────────────────────────────────────────────────────────────
  // INICIALIZACIÓN
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    try {
      debugPrint('[LocalRepo] Desempaquetando e inicializando modelo Vosk...');
      
      // 1. ModelLoader extrae automáticamente el zip de assets al almacenamiento local
      final modelPath = await ModelLoader().loadFromAssets(_assetPath);
      
      // 2. Cargamos el modelo en memoria utilizando la ruta extraída
      _model = await _vosk.createModel(modelPath);
      
      // 3. Creamos el reconocedor configurando la tasa de muestreo del audio
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: _sampleRate,
      );

      // 4. Habilitamos el reconocimiento de palabras
      await _recognizer!.setWords(words: true);

      _isInitialized = true;
      _initCompleter!.complete();
      debugPrint('[LocalRepo] Vosk inicializado con éxito.');
    } catch (e) {
      final error = Exception('Error al cargar el modelo local de Vosk: $e');
      _initCompleter!.completeError(error);
      _initCompleter = null;
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TRANSCRIPCIÓN
  // ──────────────────────────────────────────────────────────────────────────

/// Transcribe el archivo de audio usando el modelo Vosk local.
  Future<String> transcribeLocally(File audioFile) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'La transcripción local no está disponible en Flutter Web.',
      );
    }

    if (!_isInitialized) {
      await init();
    }

    if (_recognizer == null) {
      throw Exception('El Recognizer de Vosk no está disponible.');
    }

    try {
      // 1. DEFENSA DE HARDWARE: Pausa de sincronización de archivos (300ms)
      // Da tiempo al sistema operativo para liberar y cerrar el archivo .wav en disco
      await Future.delayed(const Duration(milliseconds: 300));

      if (!await audioFile.exists()) {
        throw Exception('El archivo de audio no existe en la ruta: ${audioFile.path}');
      }

      debugPrint('[LocalRepo] Leyendo bytes del archivo...');
      final Uint8List fileBytes = await audioFile.readAsBytes();
      
      if (fileBytes.length <= 44) {
        throw Exception('El archivo de audio está vacío o corrupto.');
      }
      
      // Omitimos los 44 bytes del encabezado WAV para enviar PCM puro
      final Uint8List pcmBytes = fileBytes.sublist(44);
      
      // 2. PROCESAMIENTO SEGURO POR CHUNKS (Tamaño óptimo: 8192 bytes)
      const int chunkSize = 8192; 
      int offset = 0;
      
      debugPrint('[LocalRepo] Transmitiendo ${pcmBytes.length} bytes a la capa C++...');
      while (offset < pcmBytes.length) {
        int end = offset + chunkSize;
        if (end > pcmBytes.length) {
          end = pcmBytes.length;
        }
        
        final Uint8List chunk = pcmBytes.sublist(offset, end);
        
        // Enviamos el fragmento al motor de Vosk
        await _recognizer!.acceptWaveformBytes(chunk);
        
        // DEFENSA DE HARDWARE: Pausa de alivio para el puente JNI (5ms)
        // Evita que el hilo nativo de Android se congele y colapse la Activity
        await Future.delayed(const Duration(milliseconds: 5));
        
        offset = end;
      }
      
      // 3. Solicitar el cierre y decodificación final del texto
      final String jsonResult = await _recognizer!.getFinalResult();
      
      // final Map<String, dynamic> parsedJson = jsonDecode(jsonResult);
      // final String text = (parsedJson['text'] as String? ?? '').trim();

      debugPrint('[LocalRepo] Transcripción local finalizada con éxito: "$jsonResult"');
      return jsonResult;
    } catch (e) {
      debugPrint('[LocalRepo] Error crítico en transcripción local: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LIMPIEZA DE RECURSOS
  // ──────────────────────────────────────────────────────────────────────────

  /// Libera de forma explícita la memoria ocupada por el Recognizer nativo
  void dispose() {
    _recognizer?.dispose();
    _recognizer = null;
  }
}