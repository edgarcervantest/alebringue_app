import 'dart:convert';
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
import 'package:flutter_svg/flutter_svg.dart'; // Importante para renderizar los vectores de la mascota
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Almacena el desglose analítico de la pronunciación del alumno
class PronunciationEvaluation {
  final String recognizedText;
  final double accuracyScore;
  final String diagnosticFeedback;
  final bool isPerfect;

  const PronunciationEvaluation({
    required this.recognizedText,
    required this.accuracyScore,
    required this.diagnosticFeedback,
    required this.isPerfect,
  });
}

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
  // ── Servicios ──────────────────────────────────────────────────────────────
  final LessonRepository _remoteRepository = LessonRepository();
  late final LessonTranscriptionService _transcriptionService;

  // ── Datos ──────────────────────────────────────────────────────────────────
  late Future<List<WordModel>> _wordsFuture;

  // ── Audio ──────────────────────────────────────────────────────────────────
  late AudioPlayer _audioPlayer;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // ── Estado de grabación / procesamiento / evaluación ───────────────────────
  int? _recordingWordIndex;
  int? _processingWordIndex;

  final Map<int, String> _transcriptions = {};
  final Map<int, TranscriptionSource> _transcriptionSources = {};
  final Map<int, PronunciationEvaluation> _evaluations = {};

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

    _transcriptionService.preWarmLocalModel();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose(); 
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REPRODUCCIÓN DE AUDIO REFERENCIA
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
  // GRABACIÓN — INICIAR
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _startRecording(int wordIndex) async {
    if (kIsWeb) {
      _showWebUnsupportedSnackbar();
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!mounted) return;

    if (!hasPermission) {
      _showErrorSnackbar('Sin permiso de micrófono. Actívalo en los ajustes.');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_word_$wordIndex.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, 
          sampleRate: 16000,         
          numChannels: 1, 
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.voiceRecognition,
          ),
        ),
        path: path,
      );

      if (!mounted) return;

      setState(() {
        _recordingWordIndex = wordIndex;
        _transcriptions.remove(wordIndex);      
        _transcriptionSources.remove(wordIndex);
        _evaluations.remove(wordIndex); 
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('No se pudo iniciar la grabación: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GRABACIÓN — DETENER Y ANALIZAR MULTINIVEL
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _stopAndSendRecording(int wordIndex, WordModel word) async {
    try {
      final String? path = await _audioRecorder.stop();
      if (!mounted) return; 

      if (path == null) {
        throw Exception('El archivo de audio no pudo ser creado de forma nativa.');
      }

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        throw Exception('El descriptor de archivo de audio está bloqueado o ausente.');
      }

      if (!mounted) return;

      setState(() {
        _recordingWordIndex = null;
        _processingWordIndex = wordIndex;
      });

      final result = await _transcriptionService.transcribe(audioFile, word.lessonId);
      if (!mounted) return; 

      String textResult = '';
      double confidenceScore = 1.0;
      List<dynamic> wordsMeta = [];

      if (result.source == TranscriptionSource.local && result.text.trim().startsWith('{')) {
        try {
          final Map<String, dynamic> parsedJson = jsonDecode(result.text);
          textResult = (parsedJson['text'] as String? ?? '').trim();
          
          if (parsedJson.containsKey('result') && parsedJson['result'] is List) {
            wordsMeta = parsedJson['result'];
            if (wordsMeta.isNotEmpty) {
              final totalConf = wordsMeta.fold<double>(0.0, (sum, w) => sum + (w['conf'] as num).toDouble());
              confidenceScore = totalConf / wordsMeta.length;
            }
          }
        } catch (e) {
          textResult = result.text;
        }
      } else {
        textResult = result.text.trim();
      }

      final String targetLower = word.word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final String recognizedLower = textResult.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

      double accuracyPercentage = 0.0;
      String feedbackString = '';
      bool isPerfectMatch = false;

      if (recognizedLower == targetLower) {
        isPerfectMatch = true;
        accuracyPercentage = confidenceScore * 100;
        
        if (accuracyPercentage >= 85) {
          feedbackString = '¡Excelente pronunciación! Fluidez y acento nativos impecables.';
        } else {
          feedbackString = '¡Se entendió bien! Sin embargo, intenta vocalizar con mayor potencia de aire.';
        }
      } else if (recognizedLower.isEmpty) {
        accuracyPercentage = 0.0;
        feedbackString = 'No detectamos tu voz. Acércate un poco más al micrófono e inténtalo de nuevo.';
      } else {
        accuracyPercentage = 35.0; 

        if (targetLower.startsWith('s') && recognizedLower.startsWith('es')) {
          feedbackString = 'Evita agregar el sonido "E" fantasma al inicio. En inglés, palabras como "${word.word}" empiezan con silbido de "S" directo, no es "es...".';
        } else if (targetLower.contains('v') && recognizedLower.contains('b')) {
          feedbackString = 'Cuidado con el sonido "V". Recuerda que es labiodental: muerde suavemente tu labio inferior con los dientes superiores, no uses los dos labios como con la "B". 👄';
        } else if (targetLower.contains('sh') && recognizedLower.contains('ch')) {
          feedbackString = 'Ajusta el aire: el sonido "SH" debe ser liso y suave como pidiendo silencio ("shhh"), evita marcarlo seco como la "CH" en español.';
        } else if (targetLower.startsWith('h') && recognizedLower.startsWith('j')) {
          feedbackString = 'La "H" en inglés suena como un suspiro suave exhalando aire desde la garganta, no es tan rasposa ni fuerte como nuestra "J".';
        } else {
          feedbackString = 'Pronunciaste algo similar a "$textResult". Escucha la referencia nativa de arriba y fíjate en el movimiento de la boca.';
        }
      }

      setState(() {
        _transcriptions[wordIndex] = textResult;
        _transcriptionSources[wordIndex] = result.source;
        _processingWordIndex = null;
        
        _evaluations[wordIndex] = PronunciationEvaluation(
          recognizedText: textResult,
          accuracyScore: accuracyPercentage,
          diagnosticFeedback: feedbackString,
          isPerfect: isPerfectMatch,
        );
      });

    } on UnsupportedError catch (e) {
      if (!mounted) return;
      _resetRecordingState(); 
      _showErrorSnackbar(e.message ?? 'Función no disponible en esta plataforma.');
    } catch (e) {
      if (!mounted) return;
      _resetRecordingState(); 
      _showErrorSnackbar('Error al procesar el audio: $e');
    }
  }

  void _resetRecordingState() {
    setState(() {
      _recordingWordIndex = null;
      _processingWordIndex = null;
    });
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
        content: Text('🌐 La grabación de audio no está disponible en la versión Web.'),
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
    final bool isRecordingThis = _recordingWordIndex == wordIndex;
    final bool isProcessingThis = _processingWordIndex == wordIndex;
    final String? transcription = _transcriptions[wordIndex];
    final TranscriptionSource? source = _transcriptionSources[wordIndex];
    final PronunciationEvaluation? evaluation = _evaluations[wordIndex];

    final bool canInteract = !isProcessingThis &&
        (_recordingWordIndex == null || isRecordingThis) &&
        _processingWordIndex == null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              'Palabra $current de $total',
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Solución de Overflowing y centrado absoluto para palabras compuestas
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                word.word,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36, // Un toque más compacto para prevenir saltos de línea bruscos
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.pronunciation,
                      style: const TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 48, color: Color(0xFF00C8E8)),
                      onPressed: () => _playReferenceAudio(word.audioPath),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Renderizado de la mascota con su respectiva emoción activa
            _buildMascotDisplay(isProcessing: isProcessingThis, isRecording: isRecordingThis, evaluation: evaluation),

            const SizedBox(height: 20),

            // Bloque de feedback sin opacidad
            _buildTranscriptionFeedback(
              isProcessing: isProcessingThis,
              transcription: transcription,
              source: source,
              evaluation: evaluation,
            ),

            const SizedBox(height: 24),

            _buildRecordButton(
              wordIndex: wordIndex,
              word: word,
              isRecordingThis: isRecordingThis,
              canInteract: canInteract,
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MANEJADOR DINÁMICO DE EMOCIONES DE LA MASCOTA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMascotDisplay({
    required bool isProcessing,
    required bool isRecording,
    required PronunciationEvaluation? evaluation,
  }) {
    String mascotAsset = 'assets/images/mascot/alegre.svg'; // Estado por defecto / pasivo

    if (isRecording) {
      mascotAsset = 'assets/images/mascot/sorprendido.svg'; // Escuchando atentamente
    } else if (isProcessing) {
      mascotAsset = 'assets/images/mascot/pensativo.svg'; // Analizando fonemas
    } else if (evaluation != null) {
      if (evaluation.isPerfect && evaluation.accuracyScore >= 85) {
        mascotAsset = 'assets/images/mascot/alegre.svg'; // ¡Perfecto!
      } else if (evaluation.accuracyScore >= 60) {
        mascotAsset = 'assets/images/mascot/pensativo.svg'; // Aceptable pero con detalles
      } else if (evaluation.accuracyScore == 0.0) {
        mascotAsset = 'assets/images/mascot/enojado.svg'; // No se escuchó nada (Micrófono vacío)
      } else {
        mascotAsset = 'assets/images/mascot/triste.svg'; // Error de transferencia lingüística
      }
    }

    return SizedBox(
      height: 110,
      child: SvgPicture.asset(
        mascotAsset,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // COMPONENTE DE RETROALIMENTACIÓN MULTINIVEL (SÓLIDO EXCLUSIVO)
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildTranscriptionFeedback({
    required bool isProcessing,
    required String? transcription,
    required TranscriptionSource? source,
    required PronunciationEvaluation? evaluation,
  }) {
    if (isProcessing) {
      return const Column(
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF))),
          SizedBox(height: 12),
          Text(
            'Escaneando fonemas locales...',
            style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF373737)),
          ),
        ],
      );
    }

    if (evaluation != null) {
      // Determinación estricta de colores sólidos basados en tu paleta estable de código
      Color boxBackgroundColor = Colors.transparent; // Fondo claro plano de seguridad
      Color scoreColor = const Color(0xFFE0007C); // Magenta Alebrijes básico por defecto

      if (evaluation.isPerfect) {
        if (evaluation.accuracyScore >= 85) {
          scoreColor = const Color(0xFF00E5FF); // Cyan brillante
          boxBackgroundColor = const Color(0xFF131313); // Contraste oscuro sólido para lecturas perfectas
        } else {
          scoreColor = Colors.amber;
          boxBackgroundColor = const Color(0xFFFAF9F6);
        }
      }

      // Si el puntaje es muy bajo y hay errores de acento, usamos el fondo gris/rojo sólido sin opacidades
      final Color textColor = boxBackgroundColor == const Color(0xFF131313) ? Colors.white : const Color(0xFF131313);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: boxBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF373737), width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIVEL 1: TEXTO ESCUCHADO Y CONTENEDOR DE SCORE SÓLIDO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Escuché: ',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: evaluation.recognizedText.isEmpty ? '[Silencio]' : '"${evaluation.recognizedText}"',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: scoreColor,
                            fontStyle: FontStyle.italic
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${evaluation.accuracyScore.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFF373737), thickness: 0.6),
            ),
            
            // NIVEL 2 Y 3: DIAGNÓSTICO FONÉTICO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  evaluation.isPerfect ? Icons.check_circle_outline : Icons.wb_twilight_outlined, 
                  color: scoreColor, 
                  size: 24
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    evaluation.diagnosticFeedback,
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.white, 
                      height: 1.4,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            if (source != null) Center(child: _buildSourceBadge(source)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSourceBadge(TranscriptionSource source) {
    final bool isRemote = source == TranscriptionSource.remote;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRemote ? Icons.cloud_done_outlined : Icons.offline_bolt_outlined,
          size: 13,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isRemote ? 'Procesado en servidor' : 'Motor local (Whisper Offline)',
          style: const TextStyle(fontSize: 11, color: Color(0xFF373737)),
        ),
      ],
    );
  }

  Widget _buildRecordButton({
    required int wordIndex,
    required WordModel word,
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
                  ? _stopAndSendRecording(wordIndex, word)
                  : _startRecording(wordIndex);
            }
          : null, 
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecordingThis ? const Color(0xFFE0007C) : const Color(0xFF00E5FF),
        foregroundColor: isRecordingThis ? const Color(0xFFFAF9F6) : const Color(0xFF131313),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isRecordingThis ? 6 : 2,
      ),
      icon: Icon(
        isRecordingThis ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
        size: 24,
      ),
      label: Text(
        kIsWeb
            ? 'No disponible en Web'
            : isRecordingThis
                ? 'Detener grabación'
                : 'Grabar respuesta',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3),
      ),
    );
  }
}