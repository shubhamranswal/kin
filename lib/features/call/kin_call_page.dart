import 'dart:async';

import 'package:flutter/material.dart';

import 'agora_call_service.dart';
import 'runtime_api.dart';

class KinCallPage extends StatefulWidget {
  final String appId;

  const KinCallPage({
    super.key,
    required this.appId,
  });

  @override
  State<KinCallPage> createState() => _KinCallPageState();
}

class _KinCallPageState extends State<KinCallPage>
    with SingleTickerProviderStateMixin {
  final AgoraCallService _callService = AgoraCallService();
  final RuntimeApi _runtimeApi = RuntimeApi();

  bool _connected = false;
  bool _rajPresent = false;
  bool _loading = true;
  bool _micEnabled = true;
  bool _rajSpeaking = false;
  bool _userSpeaking = false;

  String? _error;

  Timer? _callTimer;
  int _callSeconds = 0;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _startCall();
  }

  Future<void> _startCall() async {
    try {
      final session = await _runtimeApi.createSession();

      await _callService.join(
        appId: widget.appId,
        token: session.rtcToken,
        channel: session.channel,
        uid: session.uid,
        onJoined: () {
          if (!mounted) return;

          setState(() {
            _connected = true;
            _loading = false;
          });

          _startCallTimer();
        },
        onRemoteUserJoined: (remoteUid) {
          if (!mounted) return;

          setState(() {
            _rajPresent = true;
          });
        },
        onRemoteUserLeft: (remoteUid) {
          if (!mounted) return;

          setState(() {
            _rajPresent = false;
            _rajSpeaking = false;
          });
        },
        onAudioVolume: ({
          required int uid,
          required int volume,
        }) {
          if (!mounted) return;

          final isLocalUser = uid == 0;

          if (isLocalUser) {
            setState(() {
              _userSpeaking = volume > 20;
            });
          } else {
            setState(() {
              _rajSpeaking = volume > 20;
            });
          }
        },
        onError: (message) {
          if (!mounted) return;

          setState(() {
            _loading = false;
            _error = message;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();

    _callTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _callSeconds++;
        });
      },
    );
  }

  String get _formattedCallTime {
    final minutes = _callSeconds ~/ 60;
    final seconds = _callSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMic() async {
    final enabled = !_micEnabled;

    await _callService.setMicEnabled(enabled);

    if (!mounted) return;

    setState(() {
      _micEnabled = enabled;
    });
  }

  Future<void> _toggleSpeaker() async {
    await _callService.setSpeakerphoneEnabled(true);
  }

  Future<void> _leave() async {
    _callTimer?.cancel();

    await _callService.leave();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    _callService.leave();
    super.dispose();
  }

  String get _statusText {
    if (_error != null) {
      return 'Something went wrong';
    }

    if (_loading) {
      return 'Calling Raj...';
    }

    if (!_connected) {
      return 'Connecting...';
    }

    if (!_rajPresent) {
      return 'Waiting for Raj...';
    }

    if (_rajSpeaking) {
      return 'Raj is speaking';
    }

    if (_userSpeaking) {
      return 'Listening...';
    }

    return 'Raj is here';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow.
            Positioned(
              top: -140,
              left: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final opacity = _rajSpeaking
                      ? 0.10 + (_pulseController.value * 0.08)
                      : 0.05;

                  return Container(
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: opacity,
                          ),
                          blurRadius: 140,
                          spreadRadius: 60,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: Center(
                    child: _buildCharacterArea(),
                  ),
                ),

                _buildControls(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onPressed: _leave,
          ),

          const Spacer(),

          if (_connected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _formattedCallTime,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),

          const Spacer(),

          _GlassButton(
            icon: Icons.more_horiz_rounded,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() {
    final isActive = _rajSpeaking || _userSpeaking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = isActive
                ? 1.0 + (_pulseController.value * 0.035)
                : 1.0;

            return Transform.scale(
              scale: pulse,
              child: _buildAvatar(),
            );
          },
        ),

        const SizedBox(height: 30),

        const Text(
          'Raj',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 10),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _statusText,
            key: ValueKey(_statusText),
            style: TextStyle(
              color: _error != null
                  ? Colors.redAccent
                  : _rajSpeaking
                      ? Colors.white
                      : Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    final isSpeaking = _rajSpeaking;
    final isListening = _userSpeaking;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer speaking ring.
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSpeaking
                ? 190
                : isListening
                    ? 180
                    : 168,
            height: isSpeaking
                ? 190
                : isListening
                    ? 180
                    : 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSpeaking
                    ? Colors.white.withValues(alpha: 0.45)
                    : isListening
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.08),
                width: isSpeaking ? 2 : 1,
              ),
            ),
          ),

          // Avatar surface.
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSpeaking ? 142 : 136,
            height: isSpeaking ? 142 : 136,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A2A30),
                  Color(0xFF111114),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isSpeaking ? 0.22 : 0.10,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 35,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white70,
              size: 68,
            ),
          ),

          // Small online indicator.
          Positioned(
            right: 22,
            bottom: 22,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _rajPresent
                    ? const Color(0xFF6EE7B7)
                    : Colors.white24,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF08080A),
                  width: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CallControlButton(
            icon: _micEnabled
                ? Icons.mic_rounded
                : Icons.mic_off_rounded,
            label: _micEnabled ? 'Mute' : 'Unmute',
            active: !_micEnabled,
            onPressed: _toggleMic,
          ),

          _CallControlButton(
            icon: Icons.volume_up_rounded,
            label: 'Speaker',
            onPressed: _toggleSpeaker,
          ),

          _CallControlButton(
            icon: Icons.call_end_rounded,
            label: 'End',
            destructive: true,
            onPressed: _leave,
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white70,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;
  final bool destructive;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = destructive
        ? Colors.redAccent
        : active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.08);

    final foreground = destructive
        ? Colors.white
        : active
            ? Colors.black
            : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 62,
              height: 62,
              child: Icon(
                icon,
                color: foreground,
                size: 25,
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}