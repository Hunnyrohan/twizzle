import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:twizzle/core/services/call_service.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/injection_container.dart';

class CallScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserAvatar;
  final bool isVideo;
  final bool isIncoming;
  final Map<String, dynamic>? offerData;
  // Caller's own info — sent to the remote side so they see the right name/avatar
  final String? callerName;
  final String? callerImage;
  final bool callerIsVerified;
  final String? conversationId;

  const CallScreen({
    Key? key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserAvatar,
    this.isVideo = true,
    this.isIncoming = false,
    this.offerData,
    this.callerName,
    this.callerImage,
    this.callerIsVerified = false,
    this.conversationId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = sl<CallService>();
  bool _isMuted = false;
  bool _isCameraOff = false;

  bool _remoteVideoReceived = false;
  bool _isRinging = false;

  @override
  void initState() {
    super.initState();
    _callService.remoteRenderer.addListener(_onRendererStateChange);
    _callService.localRenderer.addListener(_onRendererStateChange);
    // When the remote side accepts our call, update the UI
    _callService.onCallAccepted = () {
      if (mounted) setState(() {});
    };
    _callService.onCallEnded = () {
      if (mounted) Navigator.of(context).pop();
    };
    
    if (widget.isIncoming) {
      _isRinging = true;
    } else {
      _startCall();
    }
  }

  void _onRendererStateChange() {
    if (mounted) {
      setState(() {
        if (_callService.remoteRenderer.srcObject != null && 
            _callService.remoteRenderer.srcObject!.getVideoTracks().isNotEmpty) {
          _remoteVideoReceived = true;
        }
      });
    }
  }

  void _startCall() async {
    if (widget.isIncoming && widget.offerData != null) {
      await _callService.acceptCall(widget.targetUserId, widget.offerData!, widget.isVideo);
      if (mounted) setState(() => _isRinging = false);
    } else {
      await _callService.makeCall(
        widget.targetUserId,
        widget.isVideo,
        callerName: widget.callerName,
        callerImage: widget.callerImage,
        isVerified: widget.callerIsVerified,
        conversationId: widget.conversationId,
      );
    }
    if (mounted) setState(() {});
  }

  void _acceptIncomingCall() {
    _startCall();
  }

  void _declineIncomingCall() {
     _callService.handleReject(widget.targetUserId); 
  }

  void _hangUp() {
    _callService.hangUp(targetUserId: widget.targetUserId);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _callService.localRenderer.srcObject?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
  }

  void _switchCamera() {
    _callService.switchCamera();
  }

  @override
  void dispose() {
    _callService.remoteRenderer.removeListener(_onRendererStateChange);
    _callService.localRenderer.removeListener(_onRendererStateChange);
    _callService.onCallAccepted = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Glow/Gradient (Always visible)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xff1da1f2), Colors.black],
                stops: [0.0, 0.8],
              ),
            ),
          ),

          // Remote Video (FullScreen)
          RTCVideoView(
            _callService.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          
          // Connecting/Profile Overlay (Visible until video starts or if audio call)
          if (!widget.isVideo || !_remoteVideoReceived)
             Container(
               color: _remoteVideoReceived ? Colors.transparent : Colors.black54,
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: _remoteVideoReceived ? 0 : 5, sigmaY: _remoteVideoReceived ? 0 : 5),
                 child: Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: const Color(0xff1da1f2).withOpacity(0.5), width: 2),
                         ),
                         child: CircleAvatar(
                           radius: 80,
                           backgroundColor: const Color(0xff1da1f2).withOpacity(0.1),
                           backgroundImage: widget.targetUserAvatar != null && widget.targetUserAvatar!.isNotEmpty
                               ? NetworkImage(MediaUtils.resolveImageUrl(widget.targetUserAvatar!))
                               : null,
                           child: widget.targetUserAvatar == null || widget.targetUserAvatar!.isEmpty
                               ? Text(
                                   widget.targetUserName.isNotEmpty ? widget.targetUserName[0].toUpperCase() : '?',
                                   style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                 )
                               : null,
                         ),
                       ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).fadeIn(),
                       const SizedBox(height: 24),
                       Text(
                         widget.targetUserName,
                         style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                       ).animate().fadeIn(delay: 200.ms),
                       const SizedBox(height: 8),
                       Text(
                         _getStatusText(),
                         style: const TextStyle(color: Colors.white70, fontSize: 18),
                       ).animate().fadeIn(delay: 400.ms),
                     ],
                   ),
                 ),
               ),
             ),

          // Local Video (Overlay) - standard PiP
          if (widget.isVideo)
            Positioned(
              right: 20,
              bottom: 120,
              width: _remoteVideoReceived ? 100 : 120,
              height: _remoteVideoReceived ? 150 : 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RTCVideoView(
                    _callService.localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ).animate().slideX(begin: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
            ),

          // Top Info (Only for active Video Calls)
          if (widget.isVideo && _remoteVideoReceived)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white10,
                    backgroundImage: widget.targetUserAvatar != null && widget.targetUserAvatar!.isNotEmpty
                        ? NetworkImage(MediaUtils.resolveImageUrl(widget.targetUserAvatar!))
                        : null,
                    child: widget.targetUserAvatar == null || widget.targetUserAvatar!.isEmpty
                        ? Text(widget.targetUserName.isNotEmpty ? widget.targetUserName[0].toUpperCase() : '?', 
                            style: const TextStyle(color: Colors.white, fontSize: 12))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.targetUserName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Video Active',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(),
            ),

          // Bottom Controls (Refined Glassmorphism)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white10, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _isRinging 
                      ? [
                          _circularButton(
                            icon: Icons.call_end_rounded,
                            color: Colors.redAccent.withOpacity(0.9),
                            onPressed: _declineIncomingCall,
                            size: 70,
                          ),
                          _circularButton(
                            icon: Icons.call_rounded,
                            color: Colors.green.withOpacity(0.9),
                            onPressed: _acceptIncomingCall,
                            size: 70,
                          ),
                        ]
                      : [
                          _actionButton(
                            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            isActive: _isMuted,
                            onPressed: _toggleMute,
                          ),
                          _actionButton(
                            icon: Icons.switch_camera_rounded,
                            onPressed: _switchCamera,
                          ),
                          _circularButton(
                            icon: Icons.call_end_rounded,
                            color: Colors.redAccent.withOpacity(0.9),
                            onPressed: _hangUp,
                            size: 70,
                          ),
                          if (widget.isVideo)
                            _actionButton(
                              icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                              isActive: _isCameraOff,
                              onPressed: () {
                                 setState(() => _isCameraOff = !_isCameraOff);
                                 _callService.localRenderer.srcObject?.getVideoTracks().forEach((track) {
                                   track.enabled = !_isCameraOff;
                                 });
                              },
                            ),
                        ],
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (_isRinging) return 'Incoming Call...';
    
    // For audio calls, once we aren't ringing and are accepted, we're active
    if (!widget.isVideo) return 'Audio Active';
    
    // For video calls, wait for remote track
    if (_remoteVideoReceived) return 'Video Active';
    
    return 'Connecting...';
  }

  Widget _actionButton({required IconData icon, bool isActive = false, required VoidCallback onPressed}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _circularButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    double size = 56,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }
}
