// lib/features/bringui/pages/bringui_page.dart
//
// ─── PÁGINA: CONVERSACIÓN CON BRINGUI ─────────────────────────────────────
//
// Pantalla de conversación en tiempo real con la mascota IA "Bringui".
//
// ─── ARQUITECTURA DE ESTADOS ─────────────────────────────────────────────
//   BringuiState.idle      → Botón de mic inactivo. Barras de onda en reposo.
//   BringuiState.listening → Mic activo. Onda animada. Mascota: sorprendido.
//   BringuiState.thinking  → Procesando. Spinner. Mascota: pensativo.
//   BringuiState.speaking  → Bringui responde. Onda animada. Mascota: alegre.
//
// ─── REGLAS DE DISEÑO APLICADAS ─────────────────────────────────────────────
//   [COLOR]  Sin .withOpacity() en ningún lugar. Solo const Color(0xFF...).
//   [TEXTO]  Text dinámico (estado) con maxLines + TextOverflow.ellipsis.
//   [ANIMS]  Dos AnimationController independientes:
//              · _waveCtrl  — Ondas de audio (loop mientras activo).
//              · _pulseCtrl — Pulso suave del avatar (loop continuo).
//   [WEB]    kIsWeb no aplica aquí porque esta página no usa plugins nativos;
//            la interacción es puramente UI/simulación.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── TOKENS DE DISEÑO ──────────────────────────────────────────────────────────
const _kBone = Color(0xFFFAF9F6);
const _kCarbon = Color(0xFF131313);
const _kMagenta = Color(0xFFE0007C);
const _kCyan = Color(0xFF00E5FF);
const _kAmber = Color(0xFFFFC107);
const _kSurface = Color(0xFF1C1C1C);
const _kSurface2 = Color(0xFF262626);
const _kBorderDim = Color(0xFF373737);
const _kTextDim = Color(0xFF888888);

// ── MÁQUINA DE ESTADOS ────────────────────────────────────────────────────────

enum BringuiState { idle, listening, thinking, speaking }

// ─────────────────────────────────────────────────────────────────────────────

class BringuiPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const BringuiPage());

  const BringuiPage({super.key});

  @override
  State<BringuiPage> createState() => _BringuiPageState();
}

class _BringuiPageState extends State<BringuiPage>
    with TickerProviderStateMixin {
  // ── Estado de la conversación ──────────────────────────────────────────────
  BringuiState _state = BringuiState.idle;
  bool _isMicActive = false;

  // ── Animación de ondas de audio ────────────────────────────────────────────
  // Rango 0.0 → 1.0, repeat(reverse: true) para el efecto de "respiración".
  late final AnimationController _waveCtrl;
  late final Animation<double> _waveAnim;

  // ── Animación de pulso del avatar ──────────────────────────────────────────
  // Scale 0.96 → 1.04. Siempre activo cuando Bringui no está en reposo.
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Alturas base de las 22 barras de onda (valores normalizados 0.1–1.0).
  // Son fijas; la animación modifica su escala verticalmente con seno.
  static const List<double> _kBarHeights = [
    0.30, 0.65, 0.90, 0.50, 0.80, 0.40, 1.00, 0.60,
    0.35, 0.75, 0.55, 0.95, 0.45, 0.70, 0.30, 0.85,
    0.55, 1.00, 0.40, 0.65, 0.25, 0.80,
  ];

  // ────────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _waveAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // LÓGICA DE ESTADOS (DEMO / SIMULACIÓN)
  // ────────────────────────────────────────────────────────────────────────────

  void _onMicTap() {
    if (_isMicActive) {
      // Silenciar: volver a idle inmediatamente.
      _waveCtrl.stop();
      _waveCtrl.reset();
      setState(() {
        _isMicActive = false;
        _state = BringuiState.idle;
      });
      return;
    }

    // Activar: iniciar el ciclo listening → thinking → speaking → idle.
    setState(() {
      _isMicActive = true;
      _state = BringuiState.listening;
    });
    _waveCtrl.repeat(reverse: true);

    // Bringui comienza a procesar (para la onda durante el pensamiento).
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !_isMicActive) return;
      setState(() => _state = BringuiState.thinking);
      _waveCtrl.stop();
    });

    // Bringui responde: reanuda la animación de onda.
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !_isMicActive) return;
      setState(() => _state = BringuiState.speaking);
      _waveCtrl.repeat(reverse: true);
    });

    // Ciclo completo: vuelve a idle tras la respuesta.
    Future.delayed(const Duration(seconds: 9), () {
      if (!mounted || !_isMicActive) return;
      _waveCtrl.stop();
      _waveCtrl.reset();
      setState(() {
        _isMicActive = false;
        _state = BringuiState.idle;
      });
    });
  }

  // ── GETTERS DE ESTADO ──────────────────────────────────────────────────────

  /// Texto del indicador de estado que se muestra bajo el avatar.
  String get _statusLabel {
    switch (_state) {
      case BringuiState.idle:
        return 'Presiona para hablar';
      case BringuiState.listening:
        return 'Bringui escuchando...';
      case BringuiState.thinking:
        return 'Bringui pensando...';
      case BringuiState.speaking:
        return 'Bringui hablando...';
    }
  }

  /// Color sólido del indicador según el estado activo.
  // [COLOR] Cada estado tiene su acento Alebrije puro, sin opacidad.
  Color get _statusColor {
    switch (_state) {
      case BringuiState.idle:
        return _kTextDim;
      case BringuiState.listening:
        return _kCyan;
      case BringuiState.thinking:
        return _kAmber;
      case BringuiState.speaking:
        return _kMagenta;
    }
  }

  /// Ruta del SVG de la mascota según el estado emocional de Bringui.
  String get _mascotAsset {
    switch (_state) {
      case BringuiState.idle:
        return 'assets/images/mascot/alegre.svg';
      case BringuiState.listening:
        return 'assets/images/mascot/sorprendido.svg';
      case BringuiState.thinking:
        return 'assets/images/mascot/pensativo.svg';
      case BringuiState.speaking:
        return 'assets/images/mascot/alegre.svg';
    }
  }

  /// Las barras están activas (animadas) cuando Bringui escucha o habla.
  bool get _isWaveActive =>
      _state == BringuiState.listening || _state == BringuiState.speaking;

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCarbon,

      

      // // ── APPBAR MINIMALISTA ─────────────────────────────────────────────────
      // appBar: AppBar(
      //   backgroundColor: _kCarbon,
      //   elevation: 0,
      //   surfaceTintColor: Colors.transparent,
      //   leading: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back_ios_new_rounded,
      //       color: _kBone,
      //       size: 20,
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Row(
      //     children: [
      //       // Mini-avatar circular en el AppBar para mantener identidad.
      //       Container(
      //         width: 30,
      //         height: 30,
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           color: _kMagenta,
      //           border: Border.all(color: _kBone, width: 1.5),
      //         ),
      //         child: const Center(
      //           child: Text(
      //             'B',
      //             style: TextStyle(
      //               fontFamily: 'Bungee',
      //               fontSize: 14,
      //               color: _kBone,
      //             ),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       const Text(
      //         'Bringui',
      //         style: TextStyle(
      //           fontFamily: 'Bungee',
      //           fontSize: 20,
      //           color: _kBone,
      //           letterSpacing: 0.5,
      //         ),
      //       ),
      //     ],
      //   ),
      //   // Botón de modo texto como acción secundaria.
      //   actions: [
      //     IconButton(
      //       icon: const Icon(
      //         Icons.chat_bubble_outline_rounded,
      //         color: _kTextDim,
      //         size: 22,
      //       ),
      //       onPressed: () {},
      //       tooltip: 'Cambiar a modo texto',
      //     ),
      //     const SizedBox(width: 4),
      //   ],
      // ),

      body: Column(
        children: [
          const SizedBox(height: 28),
          // ── ÁREA PRINCIPAL (flexible) ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── AVATAR ─────────────────────────────────────────────────
                  _buildAvatar(),
                  const SizedBox(height: 32),

                  // ── INDICADOR DE ESTADO ────────────────────────────────────
                  _buildStatusBadge(),
                  const SizedBox(height: 44),

                  // ── ONDAS DE VOZ ───────────────────────────────────────────
                  _buildVoiceWaves(),
                ],
              ),
            ),
          ),

          // ── BARRA DE CONTROLES ─────────────────────────────────────────────
          _buildControlBar(),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: AVATAR ANIMADO
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        // El pulso solo aplica cuando Bringui está activo.
        final double scale =
            _state != BringuiState.idle ? _pulseAnim.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo exterior: color cambia con el estado.
          // AnimatedContainer con duration para transición suave entre estados.
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // [COLOR] Borde del color del estado activo, sólido.
              border: Border.all(
                color: _state == BringuiState.idle
                    ? _kBorderDim
                    : _statusColor,
                width: 3.0,
              ),
              color: _kSurface,
            ),
          ),
          // Anillo interior decorativo (siempre neutro).
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kBorderDim, width: 1.0),
            ),
          ),
          // SVG emocional de la mascota.
          // AnimatedSwitcher da una transición de fade entre emociones.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              key: ValueKey(_mascotAsset), // ← Clave necesaria para el switcher
              width: 130,
              height: 130,
              child: SvgPicture.asset(
                _mascotAsset,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_kCyan),
                  ),
                ),
              ),
            ),
          ),

          // Overlay de spinner solo en estado "thinking".
          // [COLOR] Ámbar sólido para indicar procesamiento.
          if (_state == BringuiState.thinking)
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAmber,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_kCarbon),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: BADGE DE ESTADO
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildStatusBadge() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        // ValueKey necesario para que AnimatedSwitcher detecte el cambio.
        key: ValueKey(_state),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            // [COLOR] Borde del acento del estado, sólido.
            color: _state == BringuiState.idle
                ? _kBorderDim
                : _statusColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Punto indicador vivo cuando Bringui no está en reposo.
            if (_state != BringuiState.idle) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // [COLOR] Color sólido del estado actual.
                  color: _statusColor,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // [TEXTO] maxLines + ellipsis para el texto de estado dinámico.
            Text(
              _statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                // [COLOR] Color sólido del estado actual.
                color: _statusColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: VISUALIZADOR DE ONDAS DE VOZ
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildVoiceWaves() {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveAnim,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_kBarHeights.length, (i) {
              // Cada barra oscila desfasada usando seno con phase offset por índice.
              // Esto crea el efecto de "ola viajando" de izquierda a derecha.
              final double phase =
                  (i / _kBarHeights.length) * math.pi * 2.0;
              final double scale = _isWaveActive
                  ? 0.2 +
                      0.8 *
                          ((math.sin(
                                        _waveAnim.value * math.pi * 2 + phase,
                                      ) +
                                      1) /
                                  2)
                  : 0.08; // Altura mínima en reposo (línea plana).

              final double barH =
                  (_kBarHeights[i] * scale * 56).clamp(3.0, 56.0);

              // [COLOR] Alternancia estricta Magenta/Cyan sin opacidad.
              final Color barColor = _isWaveActive
                  ? (i.isEven ? _kMagenta : _kCyan)
                  : _kBorderDim; // Gris sólido cuando inactivo.

              return AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 4,
                height: barH,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: BARRA DE CONTROLES INFERIOR
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 44),
      decoration: const BoxDecoration(
        // [COLOR] Superficie fija, sin opacidad.
        color: Color(0xFF111111),
        border: Border(
          top: BorderSide(color: _kBorderDim, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── BOTÓN SECUNDARIO: COLGAR / SALIR ─────────────────────────────
          _buildRoundButton(
            icon: Icons.call_end_rounded,
            bgColor: _kSurface2,
            // [COLOR] Rojo sólido para acción destructiva (salir de sesión).
            iconColor: const Color(0xFFCC4444),
            size: 56,
            onTap: () => Navigator.of(context).pop(),
          ),

          // ── BOTÓN PRINCIPAL: MICRÓFONO ─────────────────────────────────────
          // El botón más grande (80px). Color cambia entre activo e inactivo.
          GestureDetector(
            onTap: _onMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // [COLOR] Cyan sólido cuando activo; Surface2 cuando muteado.
                color: _isMicActive ? _kCyan : _kSurface2,
                border: Border.all(
                  color: _isMicActive ? _kCyan : _kBorderDim,
                  width: 3.0,
                ),
              ),
              child: Icon(
                _isMicActive ? Icons.mic_rounded : Icons.mic_off_rounded,
                // [COLOR] Carbón sobre Cyan (contraste); gris sobre oscuro.
                color: _isMicActive ? _kCarbon : _kTextDim,
                size: 36,
              ),
            ),
          ),

          // ── BOTÓN SECUNDARIO: MODO TEXTO ──────────────────────────────────
          _buildRoundButton(
            icon: Icons.chat_bubble_outline_rounded,
            bgColor: _kSurface2,
            iconColor: _kTextDim,
            size: 56,
            onTap: () {
              // Conectar con ChatPage cuando esté disponible.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modo texto — próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── HELPER: BOTÓN CIRCULAR SECUNDARIO ──────────────────────────────────────

  Widget _buildRoundButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // [COLOR] Color sólido, sin opacidad.
          color: bgColor,
          border: Border.all(color: _kBorderDim, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.42),
      ),
    );
  }
}