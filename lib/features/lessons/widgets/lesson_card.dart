import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String lessonName;
  final String descriptionText;
  const LessonCard({
    super.key,
    required this.lessonName,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF131313),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF373737), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontFamily: 'Bungee'),
          ),
          const Divider(),
          Text(descriptionText, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF00E5FF)),
              foregroundColor: WidgetStatePropertyAll(Colors.black),

            ),
            child: Text('Comenzar lección'),
          ),
        ],
      ),
    );
  }
}
