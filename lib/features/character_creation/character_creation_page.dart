import 'package:flutter/material.dart';
import '../../models/mock_characters.dart';
import 'character_preview_page.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  State<CharacterCreationPage> createState() => _CharacterCreationPageState();
}

class _CharacterCreationPageState extends State<CharacterCreationPage> {
  bool _isListening = false;

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() {
          _isListening = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CharacterPreviewPage(character: raj),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Spacer(),
                      const Text(
                        'KIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const Spacer(),

                  // Main heading
                  const Text(
                    'Create your KIN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Tell me who you want to meet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white54),
                  ),

                  const SizedBox(height: 56),

                  // Voice interaction
                  GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.white
                            : const Color(0xFF151517),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: _isListening ? 0.8 : 0.1,
                          ),
                          width: 1,
                        ),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isListening
                            ? Icons.stop_rounded
                            : Icons.mic_none_rounded,
                        size: 46,
                        color: _isListening ? Colors.black : Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isListening
                          ? 'I’m listening...'
                          : 'Tap to start talking',
                      key: ValueKey(_isListening),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const SizedBox(
                    width: 500,
                    child: Text(
                      'Describe them however you want. '
                      'Their personality, story, voice, habits, secrets... '
                      'I’ll figure out the rest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white30,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Example prompt
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111113),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Try saying',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white30,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '“I want a roommate named Raj. '
                          'He’s ridiculously confident, thinks he’s an amazing cook, '
                          'and constantly steals my food.”',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
