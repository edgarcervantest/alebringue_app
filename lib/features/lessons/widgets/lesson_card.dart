import 'package:alebringue/features/lessons/pages/lesson_content_page.dart';
import 'package:flutter/material.dart';
import 'package:alebringue/models/lesson_model.dart'; // 1. Importamos el modelo

class LessonCard extends StatelessWidget {
  
  // 2. Reemplazamos los 3 Strings sueltos por el modelo completo
  final LessonModel lesson;

  const LessonCard({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajustado un poco el vertical
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF373737), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title, // 3. Usamos las propiedades del modelo
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Bungee'),
          ),
          const Divider(),
          RichText(
            text: TextSpan(
              text: 'Nivel:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Grotesque',
                    fontWeight: FontWeight.bold,
                  ),
              children: [
                TextSpan(
                  text: ' ${lesson.levelName}', // 4. Usamos el nivel del modelo
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'Grotesque'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            lesson.description, // 5. Usamos la descripción del modelo
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 6. Ahora sí le enviamos el objeto 'lesson' completo a la página de contenido
              Navigator.of(context).push(
                LessonContentPage.route(lesson: lesson ),
              );
            },
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: const WidgetStatePropertyAll(Color(0xFF00E5FF)),
                  foregroundColor: const WidgetStatePropertyAll(Color(0xFF131313)),
                ),
            child: const Text('Comenzar lección'),
          ),
        ],
      ),
    );
  }
}