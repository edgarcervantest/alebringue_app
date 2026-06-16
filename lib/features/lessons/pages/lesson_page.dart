import 'package:alebringue/features/lessons/repository/lesson_remote_repository.dart';
import 'package:alebringue/features/lessons/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import 'package:alebringue/models/lesson_model.dart';

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

class LessonsPage extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const LessonsPage());

  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonRepo = LessonRepository();

    return Scaffold(
      backgroundColor: _kCarbon,

      // appBar: AppBar(
      //   backgroundColor: _kCarbon,
      //   elevation: 0,
      //   surfaceTintColor: Colors.transparent,
      //   iconTheme: const IconThemeData(color: _kBone),
      //   actions: [
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(Icons.local_fire_department_rounded),
      //       color: _kMagenta,
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      // ),

      body: SafeArea(
        child: FutureBuilder<List<LessonModel>>(
          future: lessonRepo.fetchLessons(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // // ── HEADER ─────────────────────────────────────────
                  // const Text(
                  //   'Lecciones',
                  //   style: TextStyle(
                  //     fontFamily: 'Bungee',
                  //     fontSize: 34,
                  //     color: _kBone,
                  //     letterSpacing: 0.8,
                  //     height: 1.1,
                  //   ),
                  // ),

                  // const SizedBox(height: 4),

                  // const Text(
                  //   'Continúa tu progreso diario',
                  //   style: TextStyle(fontSize: 14, color: _kTextDim),
                  // ),

                  const SizedBox(height: 28),

                  // ── CARD META ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kBorderDim, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _kCyan,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: _kCarbon,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Text(
                                'Tu meta',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Bungee',
                                  fontSize: 18,
                                  color: _kBone,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),

                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _kMagenta,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '2 / 3',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _kBone,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Completa una lección más para mantener tu racha activa.',
                          style: TextStyle(
                            color: _kTextDim,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: _kSurface2,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              value: 0.66,
                              minHeight: 14,
                              backgroundColor: _kSurface2,
                              valueColor: AlwaysStoppedAnimation<Color>(_kCyan),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '66% completado',
                            style: TextStyle(
                              color: _kCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ── SECTION TITLE ────────────────────────────────
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Lecciones',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            fontSize: 20,
                            color: _kBone,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _kCyan,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEW',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _kCarbon,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── LOADING ─────────────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: _kCyan),
                      ),
                    ),

                  // ── ERROR ───────────────────────────────────────
                  if (snapshot.hasError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _kBorderDim, width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: _kMagenta,
                            size: 42,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No se pudieron cargar las lecciones',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _kBone,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── EMPTY ───────────────────────────────────────
                  if (snapshot.hasData && snapshot.data!.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _kBorderDim, width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            color: _kCyan,
                            size: 42,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No hay lecciones disponibles',
                            style: TextStyle(
                              color: _kBone,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── LISTADO ─────────────────────────────────────
                  if (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ...snapshot.data!.map(
                      (lesson) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: LessonCard(lesson: lesson),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
