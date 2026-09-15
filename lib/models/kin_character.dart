class KinCharacter {
  final String id;

  // Identity
  final String name;
  final int? age;
  final String role;
  final String appearance;

  // Personality
  final Personality personality;

  // Story
  final Story story;

  // Behavior
  final Behavior behavior;

  // Secrets
  final List<String> secrets;

  // Voice
  final VoiceProfile voice;

  // Languages
  final List<String> languages;

  // Runtime
  final CharacterState state;

  const KinCharacter({
    required this.id,
    required this.name,
    this.age,
    required this.role,
    required this.appearance,
    required this.personality,
    required this.story,
    required this.behavior,
    required this.secrets,
    required this.voice,
    required this.languages,
    required this.state,
  });
}

class Personality {
  final List<String> traits;

  final double humor;
  final double confidence;
  final double empathy;
  final double patience;
  final double emotionalVolatility;

  const Personality({
    required this.traits,
    this.humor = 0.5,
    this.confidence = 0.5,
    this.empathy = 0.5,
    this.patience = 0.5,
    this.emotionalVolatility = 0.5,
  });
}

class Story {
  final String backstory;
  final List<String> relationships;
  final List<String> experiences;
  final List<String> goals;

  const Story({
    required this.backstory,
    required this.relationships,
    required this.experiences,
    required this.goals,
  });
}

class Behavior {
  final List<String> rules;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> triggers;
  final List<String> boundaries;

  const Behavior({
    required this.rules,
    required this.likes,
    required this.dislikes,
    required this.triggers,
    required this.boundaries,
  });
}

class VoiceProfile {
  final String description;
  final String accent;
  final String tone;
  final String speakingStyle;
  final double energy;
  final double speed;

  const VoiceProfile({
    required this.description,
    required this.accent,
    required this.tone,
    required this.speakingStyle,
    this.energy = 0.5,
    this.speed = 1.0,
  });
}

class CharacterState {
  final String currentEmotion;
  final double emotionalIntensity;
  final double relationshipScore;
  final List<String> memories;

  const CharacterState({
    this.currentEmotion = 'neutral',
    this.emotionalIntensity = 0.0,
    this.relationshipScore = 0.5,
    this.memories = const [],
  });
}