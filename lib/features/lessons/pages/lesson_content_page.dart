import 'package:alebringue/features/lessons/widgets/lesson_appbar.dart';
import 'package:flutter/material.dart';
import 'package:alebringue/models/lesson_model.dart';

class LessonContentPage extends StatelessWidget {
  // 1. Declaramos la variable 'lesson' como una propiedad final de la clase
  final LessonModel lesson;

  // 2. Modificamos el método route para que pida la lección obligatoriamente
  static MaterialPageRoute<dynamic> route({required LessonModel lesson}) =>
      MaterialPageRoute(builder: (context) => LessonContentPage(lesson: lesson));

  // 3. La agregamos al constructor utilizando 'required'
  const LessonContentPage({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Scaffold(
      // 4. Ahora sí tienes acceso completo a las propiedades de 'lesson'
      appBar: LessonAppbar(
        title: lesson.title, 
        englishLevel: lesson.levelName,
      ),
      body: Center(
        child: Text(
          'Contenido de la lección: ${lesson.title}',
          style: theme.textTheme.titleLarge?.copyWith(color: colors.onSurface),
        ),
      ),
    );
  }
}