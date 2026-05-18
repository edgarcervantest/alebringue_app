import 'package:alebringue/features/lessons/widgets/lesson_card.dart';
import 'package:flutter/material.dart';

class LessonsPage extends StatelessWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const LessonsPage());

  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          
          children: [
            LessonCard(lessonName: "Food", descriptionText: "Learn about food"),
            LessonCard(lessonName: "Cars", descriptionText: "Learn about Cars"),
          ],
        ),
      ),
    );
  }
}
