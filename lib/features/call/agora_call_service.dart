import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraCallService {
  RtcEngine? _engine;

  bool _micEnabled = true;

  bool get micEnabled => _micEnabled;

  Future<void> join({
    required String appId,
    required String token,
    required String channel,
    required int uid,
    required void Function() onJoined,
    required void Function(int remoteUid) onRemoteUserJoined,
    required void Function(int remoteUid) onRemoteUserLeft,
    required void Function({
      required int uid,
      required int volume,
    }) onAudioVolume,
    required void Function(String message) onError,
  }) async {
    final engine = createAgoraRtcEngine();
    _engine = engine;

    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) async {
          await engine.setEnableSpeakerphone(true);

          print(
            'AGORA JOINED '
            'channel=${connection.channelId} '
            'localUid=${connection.localUid}',
          );

          onJoined();
        },

        onUserJoined: (connection, remoteUid, elapsed) {
          print(
            'AGORA REMOTE JOINED '
            'remoteUid=$remoteUid '
            'channel=${connection.channelId}',
          );

          onRemoteUserJoined(remoteUid);
        },

        onUserOffline: (connection, remoteUid, reason) {
          print(
            'AGORA REMOTE LEFT '
            'remoteUid=$remoteUid '
            'reason=$reason',
          );

          onRemoteUserLeft(remoteUid);
        },

        onAudioVolumeIndication: (
          connection,
          speakers,
          speakerNumber,
          totalVolume,
        ) {
          for (final speaker in speakers) {
            print(
              'AUDIO uid=${speaker.uid} '
              'volume=${speaker.volume}',
            );

            onAudioVolume(
              uid: speaker.uid!,
              volume: speaker.volume ?? 0,
            );
          }
        },

        onAudioSubscribeStateChanged: (
          channel,
          remoteUid,
          oldState,
          newState,
          elapsed,
        ) {
          print(
            'AUDIO SUBSCRIBE '
            'uid=$remoteUid '
            '$oldState -> $newState',
          );
        },

        onLocalAudioStateChanged: (
          connection,
          state,
          error,
        ) {
          print(
            'LOCAL AUDIO '
            'state=$state '
            'error=$error',
          );
        },

        onError: (err, msg) {
          print('AGORA ERROR $err $msg');

          onError('$err: $msg');
        },
      ),
    );

    await engine.enableAudio();

    await engine.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: true,
    );

    await engine.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  Future<void> setMicEnabled(bool enabled) async {
    final engine = _engine;

    if (engine == null) {
      return;
    }

    await engine.muteLocalAudioStream(!enabled);

    _micEnabled = enabled;

    print(
      'MIC ${enabled ? 'ENABLED' : 'DISABLED'}',
    );
  }

  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    final engine = _engine;

    if (engine == null) {
      return;
    }

    await engine.setEnableSpeakerphone(enabled);

    print(
      'SPEAKERPHONE ${enabled ? 'ENABLED' : 'DISABLED'}',
    );
  }

  Future<void> leave() async {
    final engine = _engine;

    if (engine == null) {
      return;
    }

    await engine.leaveChannel();
    await engine.release();

    _engine = null;
    _micEnabled = true;
  }
}