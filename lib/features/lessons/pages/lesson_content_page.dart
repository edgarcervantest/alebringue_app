import 'dart:io';

import 'package:alebringue/core/constants/constants.dart';
import 'package:alebringue/features/lessons/repository/lesson_remote_repository.dart';
import 'package:alebringue/features/lessons/services/lesson_transcription_service.dart';
import 'package:alebringue/features/lessons/widgets/lesson_appbar.dart';
import 'package:alebringue/models/lesson_model.dart';
import 'package:alebringue/models/word_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class LessonContentPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route({required LessonModel lesson}) =>
      MaterialPageRoute(
        builder: (context) => LessonContentPage(lesson: lesson),
      );

  final LessonModel lesson;

  const LessonContentPage({super.key, required this.lesson});

  @override
  State<LessonContentPage> createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  // ── Repositorios / Servicios ───────────────────────────────────────────────
  final LessonRepository _remoteRepository = LessonRepository();
  late final LessonTranscriptionService _transcriptionService;

  // ── Datos ─────────────────────────────────────────────────────────────────
  late Future<List<WordModel>> _wordsFuture;

  // ── Audio ─────────────────────────────────────────────────────────────────
  late AudioPlayer _audioPlayer;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // ── Estado de grabación / procesamiento ───────────────────────────────────
  /// Índice de la palabra que está siendo grabada actualmente. Null si ninguna.
  int? _recordingWordIndex;

  /// Índice de la palabra que está siendo procesada (spinner). Null si ninguna.
  int? _processingWordIndex;

  /// Mapa de transcripciones por índice de palabra.
  /// Usar un mapa en lugar de un único String evita que el resultado de la
  /// palabra 0 se muestre en la tarjeta de la palabra 1 al hacer swipe.
  final Map<int, String> _transcriptions = {};

  /// Fuente del último resultado (para el badge online/offline).
  final Map<int, TranscriptionSource> _transcriptionSources = {};

  // ── Errores ───────────────────────────────────────────────────────────────
  String? _errorMessage;

  // ────────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _transcriptionService = LessonTranscriptionService(
      remoteRepo: _remoteRepository,
    );

    _wordsFuture = _remoteRepository.fetchWords(widget.lesson.id);
    _audioPlayer = AudioPlayer();

    // Pre-calienta el modelo local en segundo plano.
    // Si estamos en Web, el servicio ignora esta llamada de forma segura.
    _transcriptionService.preWarmLocalModel();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REPRODUCCIÓN DE AUDIO DE REFERENCIA
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _playReferenceAudio(String audioPath) async {
    try {
      final url = '${Constants.supabaseStorageUri}/$audioPath';
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('[ContentPage] Error reproduciendo audio: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GRABACIÓN
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _startRecording(int wordIndex) async {
    // Guardia Web: el plugin `record` puede lanzar MissingPluginException en web.
    if (kIsWeb) {
      _showWebUnsupportedSnackbar();
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      _showErrorSnackbar('Sin permiso de micrófono. Actívalo en los ajustes.');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_recording_$wordIndex.wav';

      await _audioRecorder.start(const RecordConfig(), path: path);

      // ── mounted check ── siempre después de un await ──────────────────────
      if (!mounted) return;

      setState(() {
        _recordingWordIndex = wordIndex;
        // Limpiamos la transcripción anterior de esta palabra al empezar
        // una nueva grabación para no confundir al usuario.
        _transcriptions.remove(wordIndex);
        _transcriptionSources.remove(wordIndex);
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('No se pudo iniciar la grabación: $e');
    }
  }

  Future<void> _stopAndSendRecording(int wordIndex, int lessonId) async {
    // ── Paso 1: Detener grabación ──────────────────────────────────────────
    final path = await _audioRecorder.stop();

    // ── mounted check ─────────────────────────────────────────────────────
    if (!mounted) return;

    setState(() {
      _recordingWordIndex = null;
      _processingWordIndex = wordIndex;
      _errorMessage = null;
    });

    // ── Paso 2: Enviar al servicio híbrido ────────────────────────────────
    if (path == null) {
      if (!mounted) return;
      setState(() => _processingWordIndex = null);
      _showErrorSnackbar('No se pudo acceder al archivo de audio grabado.');
      return;
    }

    try {
      final audioFile = File(path);
      final result = await _transcriptionService.transcribe(audioFile, lessonId);

      // ── mounted check ── CRÍTICO: la operación asíncrona puede tardar
      //    varios segundos; el widget puede haberse desmontado (back, etc.)
      if (!mounted) return;

      setState(() {
        _transcriptions[wordIndex] = result.text;
        _transcriptionSources[wordIndex] = result.source;
        _processingWordIndex = null;
      });
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      setState(() => _processingWordIndex = null);
      _showErrorSnackbar(e.message ?? 'Función no disponible en esta plataforma.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingWordIndex = null);
      _showErrorSnackbar('Error al procesar el audio: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS DE UI
  // ────────────────────────────────────────────────────────────────────────────

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWebUnsupportedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🌐 La grabación de audio no está disponible en la versión Web.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LessonAppbar(
        title: widget.lesson.title,
        englishLevel: widget.lesson.levelName,
      ),
      body: FutureBuilder<List<WordModel>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar palabras:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final words = snapshot.data!;
          return PageView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) => _buildWordCard(
              word: words[index],
              wordIndex: index,
              current: index + 1,
              total: words.length,
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TARJETA POR PALABRA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildWordCard({
    required WordModel word,
    required int wordIndex,
    required int current,
    required int total,
  }) {
    // Estado local de ESTA tarjeta (no del widget completo)
    final isRecordingThis = _recordingWordIndex == wordIndex;
    final isProcessingThis = _processingWordIndex == wordIndex;
    final transcription = _transcriptions[wordIndex];
    final source = _transcriptionSources[wordIndex];

    // El botón se deshabilita si esta u otra palabra está siendo procesada/grabada
    // (evita grabaciones simultáneas).
    final bool canInteract =
        !isProcessingThis &&
        (_recordingWordIndex == null || isRecordingThis) &&
        _processingWordIndex == null;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // ── Contador ────────────────────────────────────────────────────
          Text(
            'Palabra $current de $total',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // ── Tarjeta de la palabra ────────────────────────────────────────
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.pronunciation,
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 50),
                    onPressed: () => _playReferenceAudio(word.audioPath),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Feedback de transcripción ────────────────────────────────────
          _buildTranscriptionFeedback(
            isProcessing: isProcessingThis,
            transcription: transcription,
            source: source,
          ),

          const SizedBox(height: 24),

          // ── Botón de grabación ───────────────────────────────────────────
          _buildRecordButton(
            wordIndex: wordIndex,
            lessonId: word.lessonId,
            isRecordingThis: isRecordingThis,
            canInteract: canInteract,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Widget de feedback: spinner, resultado o vacío.
  Widget _buildTranscriptionFeedback({
    required bool isProcessing,
    required String? transcription,
    required TranscriptionSource? source,
  }) {
    if (isProcessing) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text('Analizando pronunciación...'),
        ],
      );
    }

    if (transcription != null && transcription.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              '"$transcription"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Color(0xFF00C8E8),
              ),
            ),
            const SizedBox(height: 6),
            // Badge que indica si vino del backend o del modelo local
            if (source != null) _buildSourceBadge(source),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Pequeño badge informativo: ☁ Remoto / 📱 Offline
  Widget _buildSourceBadge(TranscriptionSource source) {
    final isRemote = source == TranscriptionSource.remote;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRemote ? Icons.cloud_done_outlined : Icons.offline_bolt_outlined,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isRemote ? 'Procesado en servidor' : 'Procesado en dispositivo',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// Botón inteligente: Grabar / Detener / Deshabilitado.
  Widget _buildRecordButton({
    required int wordIndex,
    required int lessonId,
    required bool isRecordingThis,
    required bool canInteract,
  }) {
    return ElevatedButton.icon(
      onPressed: canInteract || isRecordingThis
          ? () {
              if (kIsWeb) {
                _showWebUnsupportedSnackbar();
                return;
              }
              isRecordingThis
                  ? _stopAndSendRecording(wordIndex, lessonId)
                  : _startRecording(wordIndex);
            }
          : null, // null deshabilita el botón visualmente
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecordingThis
            ? const Color(0xFFE0007C)
            : const Color(0xFF00E5FF),
        foregroundColor: isRecordingThis
            ? const Color(0xFFFAF9F6)
            : const Color(0xFF131313),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(
        isRecordingThis ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
      ),
      label: Text(
        kIsWeb
            ? 'No disponible en Web'
            : isRecordingThis
                ? 'Detener grabación'
                : 'Grabar respuesta',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}