import 'package:flutter/material.dart';

class LessonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String englishLevel;
  const LessonAppbar({
    super.key,
    required this.title,
    required this.englishLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(fontFamily: 'Bungee'),
      ),
    );
  }

  // 2. AGREGA ESTE GETTER (Es obligatorio para que Scaffold sepa la altura)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
