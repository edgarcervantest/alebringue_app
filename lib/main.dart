import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alebringue/features/auth/cubit/auth_cubit.dart';
import 'package:alebringue/features/auth/pages/login_page.dart';
import 'package:alebringue/features/home/pages/home_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit()..getUserData(),
        ), // Puedes dispararlo desde aquí
      ],

      child: const MyApp(),
    ),
  );
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getUserData();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'alebringue App',
      initialRoute: '/',
      routes: {},
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE0007C), // Tu Rosa Mexicano
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
            textStyle: const TextStyle(
              fontFamily: 'Grotesque',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            foregroundColor: Color(0xFFFAF9F6),
            backgroundColor: Color(0xFFE0007C),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFE0007C),
          titleTextStyle: TextStyle(
            fontFamily: 'Bungee',
            fontSize: 25,
            color: Color(0xFFFAF9F6),
          ),
          actionsIconTheme: IconThemeData(color: Color(0xFFFAF9F6)),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF131313),
          indicatorColor: Color(0xFFE0007C),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Grotesque',
              fontSize: 16,
              color: Color(0xFFFAF9F6),
            ),
          ),
        ),
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
