import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

import 'camera_service.dart';

String get _baseURL => Platform.isAndroid ? _baseUrlAndroid : _baseURLiOS;
const _baseURLiOS = "http://10.69.175.165:3000";
const _baseUrlAndroid = 'http://10.69.175.165:3000';

enum AICallState { idle, joining, active }

class AiDemoController extends ChangeNotifier {
  AiDemoController() {
    _connect();
    _cameraService = CameraService();
  }

  AICallState _callState = AICallState.idle;
  bool _isCameraActive = false;

  set callState(AICallState callState) {
    _callState = callState;
    notifyListeners();
  }

  AICallState get callState => _callState;

  bool get isCameraActive => _isCameraActive;

  set isCameraActive(bool value) {
    _isCameraActive = value;
    notifyListeners();
  }

  void toggleCamera() async {
    if (!_isCameraActive) {
      // Initialize camera when turning on
      await _cameraService.initialize();
    } else {
      // Clear visual context when turning off camera
      await _clearVisualContext();
    }
    isCameraActive = !_isCameraActive;
  }

  Future<void> _clearVisualContext() async {
    if (call != null) {
      try {
        await http.post(
          Uri.parse('$_baseURL/update-visual-context'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'callId': call!.id,
            'visualContext': '', // Empty context means no visual input
          }),
        );
        print('Visual context cleared - Lexi is back to normal mode');
      } catch (e) {
        print('Error clearing visual context: $e');
      }
    }
  }

  Credentials? credentials;
  stream_video.StreamVideo? streamVideo;
  stream_video.Call? call;
  late CameraService _cameraService;

  CameraService get cameraService => _cameraService;

  Future<Credentials?> _fetchCredentials() async {
    final url = Uri.parse('$_baseURL/credentials');
    try {
      final result = await http.get(url);
      final json = jsonDecode(result.body) as Map<String, dynamic>;
      return Credentials.fromJson(json);
    } catch (e) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: e, silent: true),
      );
      return null;
    }
  }

  final Completer<void> _connectCompleter = Completer();

  Future<void> _connect() async {
    final credentials = await _fetchCredentials();
    if (credentials == null) {
      _connectCompleter.completeError(Exception('No valid credentials'));
      return;
    }

    streamVideo = stream_video.StreamVideo(
      credentials.apiKey,
      user: stream_video.User.regular(userId: credentials.userId),
      userToken: credentials.token,
    );
    this.credentials = credentials;
    await streamVideo!.connect();

    _connectCompleter.complete();
  }

  Future<void> joinCall() async {
    try {
      callState = AICallState.joining;
      if (Platform.isAndroid) {
        final hasMicrophonePermission =
            await Permission.microphone.request().isGranted;
        if (!hasMicrophonePermission) {
          callState = AICallState.idle;
          return;
        }
      }

      await _connectCompleter.future;

      final credentials = this.credentials;
      final streamVideo = this.streamVideo;

      if (credentials == null || streamVideo == null) {
        callState = AICallState.idle;
        return;
      }

      final call = streamVideo.makeCall(
        callType: stream_video.StreamCallType.fromString(credentials.callType),
        id: credentials.callId,
      );
      this.call = call;

      await call.getOrCreate();
      await _connectAi(
        callType: credentials.callType,
        callId: credentials.callId,
      );
      await call.join();

      callState = AICallState.active;
    } catch (e) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: e, silent: true),
      );
      callState = AICallState.idle;
    }
  }

  Future _connectAi({required String callType, required String callId}) async {
    final url = Uri.parse('$_baseURL/$callType/$callId/connect');
    await http.post(url);
  }

  Future<void> leaveCall() async {
    final call = this.call;
    if (call == null) return;

    await call.leave();
    this.call = null;

    callState = AICallState.idle;
  }
}

class Credentials {
  Credentials.fromJson(Map<String, dynamic> json)
    : apiKey = json['apiKey'],
      token = json['token'],
      callType = json['callType'],
      callId = json['callId'],
      userId = json['userId'];

  final String apiKey;
  final String token;
  final String callType;
  final String callId;
  final String userId;
}
