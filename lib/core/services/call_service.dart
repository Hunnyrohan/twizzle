import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'socket_service.dart';
import 'dart:async';

class CallService {
  final SocketService socketService;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  
  final List<RTCIceCandidate> _remoteCandidatesQueue = [];
  bool _isRemoteDescriptionSet = false;
  bool _isInitialized = false;

  CallService({required this.socketService});

  Future<void> initRenderers() async {
    if (_isInitialized) return;
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _isInitialized = true;
  }

  Future<void> initLocalStream(bool video) async {
    await initRenderers();
    
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': video ? {
        'facingMode': 'user',
        'width': {'min': 640},
        'height': {'min': 480},
      } : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      localRenderer.srcObject = _localStream;
    } catch (e) {
      print('Error getting local stream: $e');
    }
  }

  Future<void> _setupPeerConnection(String targetUserId) async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    _peerConnection!.onIceCandidate = (candidate) {
      socketService.emit('peer:ice:candidate', {
        'to': targetUserId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection!.onTrack = (track) {
      if (track.streams.isNotEmpty) {
        _remoteStream = track.streams[0];
        remoteRenderer.srcObject = _remoteStream;
      }
    };

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }
  }

  Future<void> makeCall(String targetUserId, bool video) async {
    await initLocalStream(video);
    await _setupPeerConnection(targetUserId);

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    socketService.emit('call:user', {
      'to': targetUserId,
      'offer': offer.toMap(),
      'callType': video ? 'video' : 'audio',
    });
  }

  Future<void> acceptCall(String targetUserId, Map<String, dynamic> offerData, bool video) async {
    await initLocalStream(video);
    await _setupPeerConnection(targetUserId);

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offerData['sdp'], offerData['type']),
    );
    _isRemoteDescriptionSet = true;

    // Process queued candidates
    for (var candidate in _remoteCandidatesQueue) {
      await _peerConnection!.addCandidate(candidate);
    }
    _remoteCandidatesQueue.clear();

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    socketService.emit('call:accepted', {
      'to': targetUserId,
      'ans': answer.toMap(),
    });
  }

  Future<void> handleAnswer(Map<String, dynamic> answerData) async {
    if (_peerConnection != null) {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answerData['sdp'], answerData['type']),
      );
      _isRemoteDescriptionSet = true;
      
      // Process queued candidates
      for (var candidate in _remoteCandidatesQueue) {
        await _peerConnection!.addCandidate(candidate);
      }
      _remoteCandidatesQueue.clear();
    }
  }

  Future<void> handleIceCandidate(Map<String, dynamic> candidateData) async {
    if (_peerConnection != null) {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );

      if (_isRemoteDescriptionSet) {
        await _peerConnection!.addCandidate(candidate);
      } else {
        _remoteCandidatesQueue.add(candidate);
      }
    }
  }

  void hangUp() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _isRemoteDescriptionSet = false;
    _remoteCandidatesQueue.clear();
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  void dispose() {
    hangUp();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }
}
