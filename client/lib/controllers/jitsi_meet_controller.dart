import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetController {
  final JitsiMeet _jitsiMeetPlugin = JitsiMeet();

  Future<void> joinMeeting(String roomName, String userName, String userEmail,) async {
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://7b59bf5d1cb0d8610d3be58e1b11da2c.serveo.net",
      room: roomName,
      userInfo: JitsiMeetUserInfo(
        displayName: userName,
        email: userEmail,
      ),
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
      },
      featureFlags: {
        // FeatureFlags.welcomePageEnabled: false,
        // FeatureFlags.chatEnabled: true,
        // FeatureFlags.audioFocusDisabled: true,
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.welcomePageEnabled: false,
        FeatureFlags.preJoinPageEnabled: true,
        FeatureFlags.unsafeRoomWarningEnabled: true,
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.audioFocusDisabled: true,
        FeatureFlags.audioMuteButtonEnabled: true,
        FeatureFlags.audioOnlyButtonEnabled: true,
        FeatureFlags.calenderEnabled: true,
        FeatureFlags.callIntegrationEnabled: true,
        FeatureFlags.carModeEnabled: true,
        FeatureFlags.closeCaptionsEnabled: true,
        FeatureFlags.conferenceTimerEnabled: true,
        FeatureFlags.chatEnabled: true,
        FeatureFlags.filmstripEnabled: true,
        FeatureFlags.fullScreenEnabled: true,
        FeatureFlags.helpButtonEnabled: true,
        FeatureFlags.inviteEnabled: true,
        FeatureFlags.androidScreenSharingEnabled: true,
        FeatureFlags.speakerStatsEnabled: true,
        FeatureFlags.kickOutEnabled: true,
        FeatureFlags.liveStreamingEnabled: true,
        FeatureFlags.lobbyModeEnabled: true,
        FeatureFlags.meetingNameEnabled: true,
        FeatureFlags.meetingPasswordEnabled: true,
        FeatureFlags.notificationEnabled: true,
        FeatureFlags.overflowMenuEnabled: true,
        FeatureFlags.pipEnabled: true,
        FeatureFlags.pipWhileScreenSharingEnabled: true,
        FeatureFlags.preJoinPageHideDisplayName: true,
        FeatureFlags.raiseHandEnabled: true,
        FeatureFlags.reactionsEnabled: true,
        FeatureFlags.recordingEnabled: true,
        FeatureFlags.replaceParticipant: true,
        FeatureFlags.securityOptionEnabled: true,
        FeatureFlags.serverUrlChangeEnabled: true,
        FeatureFlags.settingsEnabled: true,
        FeatureFlags.tileViewEnabled: true,
        FeatureFlags.videoMuteEnabled: true,
        FeatureFlags.videoShareEnabled: true,
        FeatureFlags.toolboxEnabled: true,
        FeatureFlags.iosRecordingEnabled: true,
        FeatureFlags.iosScreenSharingEnabled: true,
        FeatureFlags.toolboxAlwaysVisible: true,
      },
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        print("Conference joined: $url");
      },
      conferenceTerminated: (url, error) {
        print("Conference terminated: $url, error: $error");
      },
      conferenceWillJoin: (url) {
        print("Conference will join: $url");
      },
    );

    await _jitsiMeetPlugin.join(options, listener);
  }

  Future<void> leaveMeeting() async {
    await _jitsiMeetPlugin.hangUp();
  }
}
