import 'package:flutter/material.dart';
import 'package:alebringue/features/auth/cubit/auth_cubit.dart';
import 'package:alebringue/features/auth/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const SignupPage());
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  void signUpUser() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        passwordConfirmation: passwordConfirmationController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is AuthSignUp) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Registrado correctamente!, inicia sesión'),
              ),
            );
            Navigator.pushReplacement(context, LoginPage.route());
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 1. Usamos LayoutBuilder para conocer el alto máximo disponible de la pantalla
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // 2. Permite el scroll solo si el teclado bloquea la pantalla
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    // 3. Mantiene la coherencia de tamaños internos
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ), // Margen superior de seguridad
                            Image.asset(
                              'assets/images/logos/alt_name_logo_transparent.png',
                              height: 90,
                            ),
                            Text(
                              'Registrarse',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'Nombre de usuario',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "El nombre de usuario es requerido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: 'Correo',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    ).hasMatch(value)) {
                                  return "El correo no es válido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                hintText: 'Contraseña',
                              ),
                              obscureText: true, // Recomendado para contraseñas
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length <= 7) {
                                  return "La contraseña debe contener al menos 8 caracteres";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: passwordConfirmationController,
                              decoration: const InputDecoration(
                                hintText: 'Confirmar contraseña',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return "Las contraseñas no coinciden";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: signUpUser,
                              child: const Text('CREAR CUENTA'),
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(LoginPage.route());
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: '¿Ya tienes una cuenta? ',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text: 'Iniciar sesión',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFE4007C),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ), // Margen inferior de seguridad
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
