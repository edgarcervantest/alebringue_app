// lib/features/home/pages/home_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alebringue/features/auth/cubit/auth_cubit.dart';

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = 'Usuario';

        // Si el estado actual es LoggedIn y expone al usuario, extraemos su nombre
        if (state is AuthLoggedIn) {
          name = state
              .user
              .name; // Ajusta 'user.name' según las propiedades de tu AuthLoggedIn
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, $name!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const Card(
                child: ListTile(
                  title: Text('Tu progreso de hoy'),
                  subtitle: Text('Llevas 2 lecciones completadas'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
