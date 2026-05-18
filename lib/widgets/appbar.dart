// lib/widgets/custom_app_bar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLeading;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLeading = true,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showLeading
          ? IconButton(
              icon: const Icon(CupertinoIcons.profile_circled),
              color: Theme.of(context).appBarTheme.foregroundColor,
              onPressed: onProfileTap ?? () {
                // Acción por defecto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil')),
                );
              },
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontFamily: 'Bungee',
        ),
      ),
      actions: actions ?? [
        IconButton(
          onPressed: onLogoutTap ?? () {
            // Acción por defecto
            _showLogoutDialog(context);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Aquí va tu lógica de logout
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}