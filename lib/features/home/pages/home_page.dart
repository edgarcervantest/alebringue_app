// lib/home_page.dart
import 'package:alebringue/features/home/pages/home_content_page.dart'; // 1. Importa tu nueva página
import 'package:alebringue/features/lessons/pages/lessons_page.dart';
import 'package:alebringue/features/settings/pages/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  // 2. Estructuramos los datos apuntando a los contenidos reales
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'page': const HomeContentPage(), // <-- Solucionado: Ya no se llama a sí mismo
      'title': 'Alebringüe',
    },
    {
      'page': const LessonsPage(),
      'title': 'Lecciones',
    },
    {
      'page': const SettingsPage(),
      'title': 'Ajustes',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = _navigationItems[currentPageIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.profile_circled),
          color: Theme.of(context).appBarTheme.foregroundColor,
          onPressed: () {
            // Acción del perfil
          },
        ),
        title: Text(
          currentTab['title'],
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontFamily: 'Bungee',
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Acción de logout
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: _navigationItems
            .map<Widget>((item) => item['page'] as Widget)
            .toList(),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).navigationBarTheme.indicatorColor,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.play_lesson),
            icon: Icon(Icons.play_lesson_outlined),
            label: 'Lecciones',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}