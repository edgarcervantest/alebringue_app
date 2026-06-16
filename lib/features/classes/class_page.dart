// lib/features/classes/pages/class_page.dart
//
// ─── PÁGINA: MIS CLASES ────────────────────────────────────────────────────
//
// Dos secciones:
//   1. Unirme a una clase — Form con validación, TextFormField estilizado.
//   2. Salones activos   — Lista scrolleable de tarjetas con barra lateral
//                          de color sólido, badge de nivel y botón de acceso.
//
// ─── REGLAS DE DISEÑO APLICADAS ─────────────────────────────────────────────
//   [COLOR]  Sin .withOpacity() en ningún lugar. Todos los colores son
//            const Color(0xFF...) declarados como tokens al inicio del archivo.
//   [TEXTO]  Cada Text susceptible a crecer está en Expanded/Flexible con
//            maxLines + TextOverflow.ellipsis.
//   [APPBAR] Sin título en el AppBar (requisito explícito). El encabezado
//            "Mis Clases" vive como Text dentro del body para mayor control.

import 'package:flutter/material.dart';

// ── TOKENS DE DISEÑO ──────────────────────────────────────────────────────────
// Definidos como constantes del archivo para total independencia del ThemeData.
const _kBone = Color(0xFFFAF9F6);
const _kCarbon = Color(0xFF131313);
const _kMagenta = Color(0xFFE0007C);
const _kCyan = Color(0xFF00E5FF);
const _kAmber = Color(0xFFFFC107);
const _kSurface = Color(0xFF1C1C1C); // Superficie de tarjeta sobre Carbon
const _kSurface2 = Color(0xFF262626); // Input fill / tarjeta secundaria
const _kBorderDim = Color(0xFF373737); // Borde neutral oscuro
const _kTextDim = Color(0xFF888888); // Texto secundario / subtítulos
const _kTextMuted = Color(0xFF555555); // Hints, placeholders

// ── MODELO MOCK ────────────────────────────────────────────────────────────────
// En producción este modelo vendría de un ClassModel y un repositorio.
class _ClassItem {
  final String title;
  final String teacher;
  final String level;
  final String schedule;
  final Color accentColor;

  const _ClassItem({
    required this.title,
    required this.teacher,
    required this.level,
    required this.schedule,
    required this.accentColor,
  });
}

// Tres clases con niveles y acentos alebrijes distintos para demostrar
// el uso rotativo de la paleta: Magenta, Cyan, Ámbar.
const List<_ClassItem> _kMockClasses = [
  _ClassItem(
    title: 'Business English for Professionals',
    teacher: 'Prof. Sarah Mitchell',
    level: 'B2',
    schedule: 'Lun, Mié, Vie  ·  7:00 PM',
    accentColor: _kMagenta,
  ),
  _ClassItem(
    title: 'Everyday Conversation & Listening',
    teacher: 'Prof. Carlos Estrada',
    level: 'A2',
    schedule: 'Mar, Jue  ·  6:00 PM',
    accentColor: _kCyan,
  ),
  _ClassItem(
    title: 'Grammar Bootcamp: Tenses & Structure',
    teacher: 'Prof. Ana Torres',
    level: 'B1',
    schedule: 'Sáb  ·  10:00 AM',
    accentColor: _kAmber,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class ClassPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const ClassPage());

  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── ACCIÓN: UNIRSE A CLASE ──────────────────────────────────────────────────

  Future<void> _handleJoin() async {
    // Valida el formulario; si falla, Flutter muestra los errores inline.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    // Simula llamada al backend (reemplazar por llamada real al repositorio).
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return; // ← mounted check tras el await
    setState(() => _isJoining = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Buscando clase: ${_codeController.text.trim().toUpperCase()}…',
        ),
        backgroundColor: _kCyan,
        // [COLOR] SnackBar con color sólido del sistema de diseño.
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCarbon,

      // ── APPBAR ────────────────────────────────────────────────────────────
      // [APPBAR] Limpio: sin título. Solo íconos de navegación/acción.
      // appBar: AppBar(
      //   backgroundColor: _kCarbon,
      //   elevation: 0,
      //   surfaceTintColor: Colors.transparent,
      //   iconTheme: const IconThemeData(color: _kBone),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.notifications_none_outlined, color: _kBone),
      //       onPressed: () {},
      //       tooltip: 'Notificaciones',
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      // ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ENCABEZADO DEL BODY ──────────────────────────────────────────
            // El título vive aquí (no en el AppBar) para mayor control tipográfico.
            // const Text(
            //   'Mis Clases',
            //   style: TextStyle(
            //     fontFamily: 'Bungee',
            //     fontSize: 34,
            //     color: _kBone,
            //     letterSpacing: 0.8,
            //     height: 1.1,
            //   ),
            // ),
            // const SizedBox(height: 4),
            // const Text(
            //   'Únete o accede a tus salones activos',
            //   // [COLOR] Gris sólido sin opacidad.
            //   style: TextStyle(fontSize: 14, color: _kTextDim),
            // ),
            const SizedBox(height: 28),

            // ── SECCIÓN 1: UNIRSE ────────────────────────────────────────────
            _buildJoinCard(),
            const SizedBox(height: 36),

            // ── SECCIÓN 2: SALONES ACTIVOS ───────────────────────────────────
            Row(
              children: [
                const Text(
                  'Salones activos',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: 20,
                    color: _kBone,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                // Badge con el número de clases activas.
                // [COLOR] _kMagenta sólido, foreground _kBone sólido.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kMagenta,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_kMockClasses.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _kBone,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de tarjetas de clases.
            // Column en lugar de ListView para respetar el SingleChildScrollView padre.
            Column(
              children: _kMockClasses
                  .map((cls) => _buildClassCard(cls))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: TARJETA DE UNIRSE
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildJoinCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      // [COLOR] Superficie sólida oscura con borde rígido.
      //         Nunca Color.xxx.withOpacity().
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderDim, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado de sección ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _kCyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded, color: _kCarbon, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Unirme a una clase',
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 18,
                  color: _kBone,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ingresa el código que te compartió tu profesor',
            // [COLOR] Texto auxiliar con gris sólido.
            style: TextStyle(fontSize: 13, color: _kTextDim),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // ── INPUT DE CÓDIGO ──────────────────────────────────────────
                TextFormField(
                  controller: _codeController,
                  // Fuerza mayúsculas para el formato de código.
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: _kBone,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 4.0, // Simula formato "ABC - XYZ"
                  ),
                  decoration: InputDecoration(
                    hintText: 'CÓDIGO-XYZ',
                    hintStyle: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 20,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                    ),
                    // [COLOR] Todos los estados de borde son sólidos.
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _kBorderDim,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kCyan, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _kMagenta,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _kMagenta,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: _kSurface2,
                    prefixIcon: const Icon(
                      Icons.qr_code_outlined,
                      color: _kTextDim,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    // [COLOR] Texto de error en Magenta sólido.
                    errorStyle: const TextStyle(color: _kMagenta, fontSize: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código no puede estar vacío';
                    }
                    if (value.trim().length < 4) {
                      return 'Mínimo 4 caracteres';
                    }
                    // Acepta: letras A-Z, números 0-9 y guión (ej. "ABC-123").
                    final regex = RegExp(r'^[A-Z0-9\-]{4,12}$');
                    if (!regex.hasMatch(value.trim().toUpperCase())) {
                      return 'Solo letras, números y guiones (ej: ENG-B2)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── BOTÓN UNIRSE ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isJoining ? null : _handleJoin,
                    style: ElevatedButton.styleFrom(
                      // [COLOR] _kCyan sólido cuando activo;
                      //         _kBorderDim sólido cuando deshabilitado.
                      backgroundColor: _kCyan,
                      foregroundColor: _kCarbon,
                      disabledBackgroundColor: _kBorderDim,
                      disabledForegroundColor: _kTextDim,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isJoining
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _kCarbon,
                              ),
                            ),
                          )
                        : const Text(
                            'Unirme',
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDGET: TARJETA DE CLASE INSCRITA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildClassCard(_ClassItem cls) {
    // El foreground del badge de nivel depende del acento:
    //   · Magenta → texto Hueso (contraste blanco sobre rojo)
    //   · Cyan / Ámbar → texto Carbón (contraste oscuro sobre claro)
    final Color badgeFg = cls.accentColor == _kMagenta ? _kBone : _kCarbon;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorderDim, width: 1.5),
      ),
      // IntrinsicHeight hace que la barra lateral ocupe el 100% del alto
      // de la tarjeta, independientemente del contenido de texto.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── BARRA LATERAL DE COLOR ─────────────────────────────────────
            // [COLOR] Acento Alebrije puro, sin opacidad.
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: cls.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ── CONTENIDO ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila: título + badge de nivel
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [TEXTO] Expanded + maxLines + ellipsis para evitar
                        //         Yellow Lines de desbordamiento horizontal.
                        Expanded(
                          child: Text(
                            cls.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _kBone,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ── BADGE DE NIVEL ───────────────────────────────
                        // [COLOR] Color sólido del acento de la clase.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cls.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cls.level,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Nombre del profesor
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: _kTextDim,
                        ),
                        const SizedBox(width: 5),
                        // [TEXTO] Flexible + maxLines para nombres largos.
                        Flexible(
                          child: Text(
                            cls.teacher,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _kTextDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Horario
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: _kTextDim,
                        ),
                        const SizedBox(width: 5),
                        // [TEXTO] Flexible para evitar overflow en pantallas estrechas.
                        Flexible(
                          child: Text(
                            cls.schedule,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kTextDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── BOTÓN "ENTRAR AL AULA" ──────────────────────────────
                    // Alineado a la derecha. Estilo discreto con borde del
                    // acento de la clase para mantener la identidad visual.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          // [COLOR] Surface2 sólido + borde del acento.
                          backgroundColor: _kSurface2,
                          foregroundColor: cls.accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: cls.accentColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text(
                          'Entrar al aula',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
