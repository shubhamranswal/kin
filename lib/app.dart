import 'package:flutter/material.dart';
import 'features/character_creation/character_creation_page.dart';

class KinApp extends StatelessWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KIN',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF111113),
        ),
        fontFamily: 'Arial',
      ),
      home: const KinHomePage(),
    );
  }
}

class KinHomePage extends StatelessWidget {
  const KinHomePage({super.key});

  void _openCharacterCreation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CharacterCreationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KIN',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  const Text(
                    'Create someone.',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -2,
                    ),
                  ),

                  const Text(
                    'Then actually talk to them.',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -2,
                      color: Colors.white38,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(
                    width: 600,
                    child: Text(
                      'Create AI characters with their own personality, '
                      'memories, emotions, voice and story.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  SizedBox(
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCharacterCreation(context),
                      icon: const Icon(Icons.mic_none_rounded),
                      label: const Text(
                        'Create a KIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111113),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          color: Colors.white38,
                          size: 28,
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your KINs will live here.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Create your first character and start a conversation.',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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