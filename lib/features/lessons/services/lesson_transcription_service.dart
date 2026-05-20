import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:alebringue/features/lessons/repository/lesson_local_repository.dart';
import 'package:alebringue/features/lessons/repository/lesson_remote_repository.dart';

/// Indica qué motor procesó el audio. Útil para mostrar feedback en la UI
/// (p.ej. un icono de nube vs un icono offline).
enum TranscriptionSource { remote, local }

/// Resultado de la transcripción con metadatos del origen.
class TranscriptionResult {
  final String text;
  final TranscriptionSource source;

  const TranscriptionResult({required this.text, required this.source});
}

class LessonTranscriptionService {
  final LessonRepository _remoteRepo;
  final LessonLocalRepository _localRepo;

  // Usamos una única instancia de Connectivity para no recrearla en cada llamada.
  final Connectivity _connectivity;

  LessonTranscriptionService({
    LessonRepository? remoteRepo,
    LessonLocalRepository? localRepo,
    Connectivity? connectivity,
  })  : _remoteRepo = remoteRepo ?? LessonRepository(),
        _localRepo = localRepo ?? LessonLocalRepository(),
        _connectivity = connectivity ?? Connectivity();

  // ──────────────────────────────────────────────────────────────────────────
  // API PÚBLICA
  // ──────────────────────────────────────────────────────────────────────────

  /// Precalienta el modelo local **en segundo plano** para que la primera
  /// transcripción offline no sufra el retraso de carga del bin (~2-5 s).
  ///
  /// Llama esto en [initState] de la página, no en el momento de grabar.
  void preWarmLocalModel() {
    if (kIsWeb) return; // Sin efecto en web; no lanza excepción.

    // unawaited intencional: no bloquea la UI.
    unawaited(
      _localRepo.init().catchError(
        (Object e) => debugPrint('[TranscriptionService] Pre-warm falló: $e'),
      ),
    );
  }

  /// Transcribe el audio con la estrategia adecuada según la conectividad.
  ///
  /// Lanza [UnsupportedError] si se llama desde Web.
  /// Lanza [Exception] si ambas rutas fallan.
  Future<TranscriptionResult> transcribe(
    File audioFile,
    int lessonId,
  ) async {
    // ── Guardia de plataforma ─────────────────────────────────────────────
    if (kIsWeb) {
      throw UnsupportedError(
        'La grabación y transcripción no están disponibles en la versión Web.',
      );
    }

    // ── Ruta ONLINE ────────────────────────────────────────────────────────
    if (await _isOnline()) {
      try {
        debugPrint('[TranscriptionService] Modo ONLINE → backend remoto');
        final text = await _remoteRepo.sendAudioForWhisper(audioFile, lessonId);
        return TranscriptionResult(
          text: text,
          source: TranscriptionSource.remote,
        );
      } catch (e) {
        // Fallback silencioso: si el backend falla, intentamos localmente
        // en lugar de mostrar un error al usuario.
        debugPrint(
          '[TranscriptionService] Remoto falló ($e), '
          'cayendo al modelo local...',
        );
      }
    }

    // ── Ruta OFFLINE (o fallback del remoto) ───────────────────────────────
    debugPrint('[TranscriptionService] Modo OFFLINE → Whisper local');
    final text = await _localRepo.transcribeLocally(audioFile);
    return TranscriptionResult(
      text: text,
      source: TranscriptionSource.local,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVADO
  // ──────────────────────────────────────────────────────────────────────────

  /// Devuelve `true` si existe al menos una interfaz de red activa.
  /// Nota: ConnectivityResult verifica la interfaz, no la reachability real.
  /// Para producción considera hacer un ping a tu backend si necesitas más certeza.
  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    // checkConnectivity() devuelve List<ConnectivityResult> en v6+
    return results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
  }
}