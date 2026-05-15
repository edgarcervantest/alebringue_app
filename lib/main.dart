import 'package:flutter/material.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
// import 'package:frontend/features/auth/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alebringüe App',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE4007C), // Tu Rosa Mexicano
          onPrimary: Color(0xFFFAF9F6), // Texto sobre rosa
          secondary: const Color(0xFF00E5FF), // Turquesa vibrante
          onSecondary: const Color(0xFF002025), // Texto sobre turquesa
          tertiary: const Color(0xFFFFAB40), // Naranja Alebrije
          surface: const Color(0xFF131313), // Fondo de tarjetas/hojas
          error: const Color(0xFFCF6679), // Rojo suave para errores
        ),

        textTheme: TextTheme(
          titleLarge: TextStyle(fontFamily: 'Grotesque', fontSize: 50),
          titleMedium: TextStyle(fontFamily: 'Grotesque', fontSize: 30),
          titleSmall: TextStyle(fontFamily: 'Grotesque'),
          bodyLarge: TextStyle(fontFamily: 'Grotesque'),
          bodyMedium: TextStyle(fontFamily: 'Grotesque'),
          bodySmall: TextStyle(fontFamily: 'Grotesque'),
        ),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0007C), width: 3),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 3, color: Colors.red),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Grotesque', fontSize: 16, fontWeight: FontWeight.bold),
            foregroundColor: Color(0xFFFAF9F6),
            backgroundColor: Color(0xFFE0007C),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
