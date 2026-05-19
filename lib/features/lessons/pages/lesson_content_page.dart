import 'dart:io';
import 'package:alebringue/core/constants/constants.dart';
import 'package:alebringue/features/lessons/repository/lesson_remote_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:alebringue/models/lesson_model.dart';
import 'package:alebringue/models/word_model.dart';
import 'package:alebringue/features/lessons/widgets/lesson_appbar.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

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
  // Instanciamos el repo aquí
  final LessonRepository _repository = LessonRepository();
  late Future<List<WordModel>> _wordsFuture;
  late AudioPlayer _audioPlayer;
  final _audioRecorder = AudioRecorder();

  // NUEVOS ESTADOS
  bool _isRecording = false;
  bool _isProcessing = false; // Para el spinner de carga
  String _transcription = ''; // Para mostrar el resultado

  @override
  void initState() {
    super.initState();
    _wordsFuture = _repository.fetchWords(widget.lesson.id);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Lógica para reproducir
  Future<void> _playReferenceAudio(String audioPath) async {
    try {
      final url = '${Constants.supabaseStorageUri}/$audioPath';
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Error reproduciendo audio: $e");
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_recording.wav';

      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
        _transcription = ''; // Limpiar resultado anterior al empezar
      });
    }
  }

  Future<void> _stopAndSendRecording(int lessonId) async {
    setState(() {
      _isRecording = false;
      _isProcessing = true; // Mostrar que está trabajando
    });

    final path = await _audioRecorder.stop();

    if (path != null) {
      try {
        File audioFile = File(path);
        // Aquí llamas a tu repo. Si usas modo local, usarás tu LessonLocalRepository
        final result = await _repository.sendAudioForWhisper(
          audioFile,
          lessonId,
        );

        setState(() {
          _transcription = result;
          _isProcessing = false;
        });
      } catch (e) {
        setState(() => _isProcessing = false);
        debugPrint("Error: $e");
      }
    } else {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: LessonAppbar(
        title: widget.lesson.title,
        englishLevel: widget.lesson.levelName,
      ),
      body: FutureBuilder<List<WordModel>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          // ... tu lógica de estados de carga y error (sigue igual)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final words = snapshot.data!;
          return PageView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) =>
                _buildWordCard(words[index], index + 1, words.length),
          );
        },
      ),
    );
  }

  // UI para mostrar la palabra individualmente
  Widget _buildWordCard(WordModel word, int current, int total) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Palabra $current de $total',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  word.pronunciation,
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 50),
                  onPressed: () {
                    _playReferenceAudio(word.audioPath);
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        // MOSTRAR RESULTADOS O CARGA
        if (_isProcessing)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Analizando pronunciación..."),
            ],
          )
        else if (_transcription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Dijiste: \"$_transcription\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.blue,
              ),
            ),
          ),

        const SizedBox(height: 20),

        // BOTÓN INTELIGENTE
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : (_isRecording
                    ? () => _stopAndSendRecording(word.lessonId)
                    : _startRecording),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Color(0xFFE0007C) : Color(0xFF00E5FF),
            foregroundColor:_isRecording ? Color(0xFFFAF9F6) : Color(0xFF131313),
          ),
          child: Text(_isRecording ? 'Detener grabación' : 'Grabar respuesta'),
        ),
      ],
    );
  }
}
