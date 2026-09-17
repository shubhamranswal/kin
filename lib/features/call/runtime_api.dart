import 'dart:convert';

import 'package:http/http.dart' as http;


class RuntimeSession {
  final String agentId;
  final String characterId;
  final String characterName;
  final String channel;
  final int uid;
  final String rtcToken;

  const RuntimeSession({
    required this.agentId,
    required this.characterId,
    required this.characterName,
    required this.channel,
    required this.uid,
    required this.rtcToken,
  });

  factory RuntimeSession.fromJson(Map<String, dynamic> json) {
    return RuntimeSession(
      agentId: json['agent_id'] as String,
      characterId: json['character_id'] as String,
      characterName: json['character_name'] as String,
      channel: json['channel'] as String,
      uid: json['uid'] as int,
      rtcToken: json['rtc_token'] as String,
    );
  }
}

class RuntimeApi {
  static const String baseUrl = 'https://kin-jrny.onrender.com';

  Future<RuntimeSession> createSession() async {
    final response = await http.post(
      Uri.parse('$baseUrl/runtime/session'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Runtime session failed: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return RuntimeSession.fromJson(json);
  }
}