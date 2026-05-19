import 'package:alebringue/features/lessons/repository/lesson_remote_repository.dart';
import 'package:alebringue/features/lessons/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:alebringue/models/lesson_model.dart';

class LessonsPage extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const LessonsPage());

  const LessonsPage({super.key});
  static const String assetName = 'assets/images/mascot/pensativo.svg';

  @override
  Widget build(BuildContext context) {
    // 1. Inicializamos theme y colors para que no marquen error
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lessonRepo = LessonRepository();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Padding general para alinear todo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TARJETA DE PROGRESO DIARIO (Fija arriba) ---
              Center(
                child: Text(
                  'Tu meta diaria',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAF9F6),
                    // Turquesa
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFFFAF9F6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Lecciones diarias',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '2 / 3',
                            style: TextStyle(
                              color: colors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Barra de progreso estilizada
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.66,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade900,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- LISTA DE LECCIONES (Asíncrona) ---
              // Usamos Expanded para que el FutureBuilder tome el espacio restante
              Expanded(
                child: FutureBuilder<List<LessonModel>>(
                  future: lessonRepo.fetchLessons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay lecciones disponibles por ahora.'),
                      );
                    }

                    final lessonsList = snapshot.data!;

                    return ListView.builder(
                      padding: EdgeInsets
                          .zero, // Cero para evitar doble padding con el exterior
                      itemCount: lessonsList.length,
                      itemBuilder: (context, index) {
                        final lesson = lessonsList[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: LessonCard(lesson: lesson),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
