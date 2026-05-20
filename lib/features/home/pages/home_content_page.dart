// lib/features/home/pages/home_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alebringue/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  static const String mascotPensativo = 'assets/images/mascot/pensativo.svg';
  static const String mascotAlegre = 'assets/images/mascot/alegre.svg';
  static const String mascotTriste = 'assets/images/mascot/triste.svg';
  static const String mascotSorprendido = 'assets/images/mascot/sorprendido.svg';
  static const String mascotEnojado = 'assets/images/mascot/enojado.svg';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = 'Aprendiz';

        if (state is AuthLoggedIn) {
          name = state.user.name;
        }

        // Datos de ejemplo para la racha
        final weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
        final completedDays = [
          true,
          true,
          false,
          false,
          false,
          false,
          false,
        ]; // L, M, M completados

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN DE BIENVENIDA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, $name!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary,
                          ),
                        ),
                        Text(
                          '¿Qué vamos a aprender hoy?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- CARD DE RACHA (DAYS OF WEEK) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF373737), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado de la racha
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: colors.tertiary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Racha actual',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '2 días',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Color(0xFF131313),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Días de la semana en círculos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(weekDays.length, (index) {
                        final isCompleted = completedDays[index];
                        return Column(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? colors.primary
                                    : colors.surface,
                                border: Border.all(
                                  color: isCompleted
                                      ? colors.secondary
                                      : Color(0xFF373737),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  weekDays[index],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontFamily: 'Bungee',
                                        // fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: isCompleted
                                            ? colors.onPrimary
                                            : Color(0xFF373737),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getDayName(index),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Mensaje motivacional
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Color(0xFF131313),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '¡Sigue así! Completa 3 días más para obtener una racha de 5 días',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- MASCOTA (Imagen central) ---
              Center(
                child: SvgPicture.asset(
                  mascotPensativo,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Helper para obtener nombre completo del día
  String _getDayName(int index) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return days[index];
  }
}
