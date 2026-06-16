// lib/features/home/pages/home_content_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alebringue/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── TOKENS ───────────────────────────────────────────────────────────────────

const _kBone = Color(0xFFFAF9F6);
const _kCarbon = Color(0xFF131313);

const _kMagenta = Color(0xFFE0007C);
const _kCyan = Color(0xFF00E5FF);

const _kSurface = Color(0xFF1C1C1C);
const _kSurface2 = Color(0xFF262626);

const _kBorderDim = Color(0xFF373737);
const _kTextDim = Color(0xFF888888);

// ─────────────────────────────────────────────────────────────────────────────

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  static const String mascotPensativo = 'assets/images/mascot/pensativo.svg';

  static const String mascotAlegre = 'assets/images/mascot/alegre.svg';

  static const String mascotTriste = 'assets/images/mascot/triste.svg';

  static const String mascotSorprendido =
      'assets/images/mascot/sorprendido.svg';

  static const String mascotEnojado = 'assets/images/mascot/enojado.svg';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = 'Aprendiz';

        if (state is AuthLoggedIn) {
          name = state.user.name;
        }

        final weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

        final completedDays = [true, true, false, false, false, false, false];

        return Scaffold(
          backgroundColor: _kCarbon,

          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP BAR ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const SizedBox(height: 28),
                            Text(
                              '¡Hola, $name!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Bungee',
                                fontSize: 28,
                                color: _kBone,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              '¿Qué vamos a aprender hoy?',
                              style: TextStyle(fontSize: 14, color: _kTextDim),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kBorderDim, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: _kCyan,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── CARD DE RACHA ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _kBorderDim, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── HEADER ───────────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _kMagenta,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: _kBone,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Text(
                                'Racha actual',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Bungee',
                                  fontSize: 18,
                                  color: _kBone,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _kCyan,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '2 días',
                                style: TextStyle(
                                  color: _kCarbon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Mantén tu progreso activo estudiando todos los días.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _kTextDim,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ── DÍAS ─────────────────────────────────
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 12) / 7;

                            return Row(
                              children: List.generate(weekDays.length, (index) {
                                final isCompleted = completedDays[index];

                                return SizedBox(
                                  width: itemWidth,
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),

                                        width: itemWidth.clamp(32, 42),
                                        height: itemWidth.clamp(32, 42),

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted
                                              ? _kCyan
                                              : _kSurface2,
                                          border: Border.all(
                                            color: isCompleted
                                                ? _kCyan
                                                : _kBorderDim,
                                            width: 2,
                                          ),
                                        ),

                                        child: Center(
                                          child: Text(
                                            weekDays[index],
                                            style: TextStyle(
                                              fontFamily: 'Bungee',
                                              fontSize: itemWidth < 38
                                                  ? 12
                                                  : 16,
                                              color: isCompleted
                                                  ? _kCarbon
                                                  : _kTextDim,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        _getDayName(index),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: itemWidth < 38 ? 8 : 10,
                                          color: _kTextDim,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── MENSAJE ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _kSurface2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kBorderDim, width: 1.2),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _kMagenta,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_outlined,
                                  color: _kBone,
                                  size: 18,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Text(
                                  '¡Sigue así! Completa 3 días más para desbloquear una racha de 5 días.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _kBone,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ── MASCOTA ───────────────────────────────────
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _kBorderDim, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            mascotPensativo,
                            height: 220,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Tu compañero de aprendizaje',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: 18,
                              color: _kBone,
                              letterSpacing: 0.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Practica pronunciación, vocabulario y comprensión auditiva diariamente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _kTextDim,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int index) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

    return days[index];
  }
}
