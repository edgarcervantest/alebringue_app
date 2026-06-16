// lib/features/translator/pages/translator_page.dart

import 'package:flutter/material.dart';

// ── TOKENS DE DISEÑO ──────────────────────────────────────────────────────────

const _kBone = Color(0xFFFAF9F6);
const _kCarbon = Color(0xFF131313);
const _kMagenta = Color(0xFFE0007C);
const _kCyan = Color(0xFF00E5FF);
const _kAmber = Color(0xFFFFC107);
const _kSurface = Color(0xFF1C1C1C);
const _kSurface2 = Color(0xFF262626);
const _kBorderDim = Color(0xFF373737);
const _kTextDim = Color(0xFF888888);
const _kTextMuted = Color(0xFF555555);

// ─────────────────────────────────────────────────────────────────────────────

class TranslatorPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const TranslatorPage());

  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _englishController = TextEditingController();

  String _translatedText = '';
  bool _isTranslating = false;

  @override
  void dispose() {
    _englishController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_englishController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _translatedText = _mockTranslate(_englishController.text.trim());
      _isTranslating = false;
    });
  }

  String _mockTranslate(String text) {
    final lower = text.toLowerCase();

    if (lower == 'hello') return 'Hola';
    if (lower == 'how are you?') return '¿Cómo estás?';
    if (lower == 'good morning') return 'Buenos días';
    if (lower == 'thank you') return 'Gracias';

    return 'Traducción simulada al español.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCarbon,

      // appBar: AppBar(
      //   backgroundColor: _kCarbon,
      //   elevation: 0,
      //   surfaceTintColor: Colors.transparent,
      //   iconTheme: const IconThemeData(color: _kBone),
      //   actions: [
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(
      //         Icons.history_rounded,
      //         color: _kBone,
      //       ),
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
            // const Text(
            //   'Traductor',
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
            //   'Traduce frases de inglés a español',
            //   style: TextStyle(fontSize: 14, color: _kTextDim),
            // ),
            const SizedBox(height: 28),

            _buildTranslatorCard(),

            const SizedBox(height: 32),

            _buildExamplesSection(),
          ],
        ),
      ),
    );
  }

  // ── CARD PRINCIPAL ─────────────────────────────────────────────────────────

  Widget _buildTranslatorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorderDim, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ───────────────────────────────────────────────────────
          Row(
            children: [
              const Text(
                'Inglés → Español',
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 18,
                  color: _kBone,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Escribe una palabra o frase en inglés',
            style: TextStyle(fontSize: 13, color: _kTextDim),
          ),

          const SizedBox(height: 22),

          // ── INPUT ────────────────────────────────────────────────────────
          TextField(
            controller: _englishController,
            style: const TextStyle(color: _kBone, fontSize: 16, height: 1.4),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Escribe algo en inglés...',
              hintStyle: const TextStyle(color: _kTextMuted),
              filled: true,
              fillColor: _kSurface2,
              contentPadding: const EdgeInsets.all(18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kBorderDim, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kCyan, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── BOTÓN ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kCyan,
                foregroundColor: _kCarbon,
                disabledBackgroundColor: _kBorderDim,
                disabledForegroundColor: _kTextDim,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isTranslating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_kCarbon),
                      ),
                    )
                  : const Icon(Icons.translate),
              label: Text(
                _isTranslating ? 'Traduciendo...' : 'Traducir',
                style: const TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── RESULTADO ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kSurface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorderDim, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.volume_up_outlined, size: 18, color: _kCyan),
                    SizedBox(width: 8),
                    Text(
                      'Traducción',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _kBone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  _translatedText.isEmpty
                      ? 'La traducción aparecerá aquí...'
                      : _translatedText,
                  style: TextStyle(
                    color: _translatedText.isEmpty ? _kTextMuted : _kBone,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EJEMPLOS ───────────────────────────────────────────────────────────────

  Widget _buildExamplesSection() {
    final examples = ['Hello', 'How are you?', 'Good morning', 'Thank you'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ejemplos rápidos',
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: 20,
            color: _kBone,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: examples.map((example) {
            return ActionChip(
              onPressed: () {
                _englishController.text = example;
              },
              backgroundColor: _kSurface,
              side: const BorderSide(color: _kBorderDim, width: 1.2),
              label: Text(
                example,
                style: const TextStyle(
                  color: _kBone,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
