import 'dart:async';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoPlayerHLS extends ConsumerStatefulWidget {
  final String url;
  final VoidCallback onBack;
  final String? authToken;

  const VideoPlayerHLS({
    required this.url,
    this.authToken,
    required this.onBack,
  });

  @override
  ConsumerState<VideoPlayerHLS> createState() => _VideoPlayerHLSState();
}

class _VideoPlayerHLSState extends ConsumerState<VideoPlayerHLS> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;
  final api = ApiService.instance;
  bool _isRefreshing = false;
  bool _hasTriedRefresh = false; // Prevent infinite loops

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Forzar vertical por defecto
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializePlayer() async {
    try {
      print("\n🎬 ==================== PLAYER INIT START ====================");
      print("🎬 Starting player initialization...");

      // Get current token
      final token = ref.read(userProvider).getAccesToken();

      print("🎬 Token check:");
      print("   - Token exists: ${token != null}");
      print("   - Token not empty: ${token?.isNotEmpty}");
      print("   - Token length: ${token?.length}");
      print("   - Token preview: ${token?.substring(0, 20)}...");

      if (token == null || token.isEmpty) {
        print("❌ No token available");
        if (mounted) {
          _showSessionExpiredDialog();
        }
        print("🎬 ==================== PLAYER INIT END ====================\n");
        return;
      }

      print("🎬 Video URL: ${widget.url}");
      print("🔑 Creating headers with token...");

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.apple.mpegurl, */*',
      };

      print("🔑 Headers: $headers");

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        formatHint: VideoFormat.hls,
        httpHeaders: headers,
      );

      // Add error listener BEFORE initialization
      _controller.addListener(_handleVideoError);

      print("⏳ Initializing controller...");
      await _controller.initialize();

      print("✅ Controller initialized successfully");
      print("✅ Controller value: ${_controller.value}");
      print("✅ Duration: ${_controller.value.duration}");

      if (mounted) {
        setState(() {});
        print("▶️ Starting playback...");
        await _controller.play();
        _startHideTimer();
        print("▶️ Video playing");
      }
      print("🎬 ==================== PLAYER INIT END ====================\n");
    } catch (error) {
      print("❌ Error initializing video: $error");
      print("❌ Error type: ${error.runtimeType}");
      print("❌ Full stack trace:");
      if (error is Exception) {
        print(error.toString());
      }

      // ANY error during init = likely 403, try refresh once
      if (!_hasTriedRefresh) {
        print("🔐 Init failed - attempting token refresh in case of 403...");
        _hasTriedRefresh = true;

        try {
          await _refreshAndRetry();
          return; // _refreshAndRetry will restart everything
        } catch (refreshError) {
          print("❌ Refresh also failed: $refreshError");
        }
      } else {
        print("⚠️ Already tried refresh once, giving up");
      }

      // If we get here, give up and show error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading video: $error")));

        // Show full dialog on persistent errors
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showSessionExpiredDialog();
          }
        });
      }
      print("🎬 ==================== PLAYER INIT END ====================\n");
    }
  }

  void _handleVideoError() {
    print("🎥 _handleVideoError called");
    print("🎥 Has error: ${_controller.value.hasError}");
    print("🎥 Error description: ${_controller.value.errorDescription}");

    if (!_controller.value.hasError) {
      print("🎥 No error, returning");
      return;
    }

    final error = _controller.value.errorDescription ?? '';
    print("🎥 Full error string: $error");
    print("🎥 Contains '403': ${error.contains('403')}");
    print("🎥 Contains 'Forbidden': ${error.contains('Forbidden')}");
    print("🎥 Is refreshing: $_isRefreshing");

    // Check for 403 Forbidden error during playback
    if ((error.contains('403') || error.contains('Forbidden')) &&
        !_isRefreshing) {
      print("🔐 DETECTED 403 - attempting token refresh");
      _refreshAndRetry();
    } else if (_isRefreshing) {
      print("⚠️ Already refreshing, skipping");
    }
  }

  Future<void> _refreshAndRetry() async {
    // Prevent concurrent refresh attempts
    if (_isRefreshing) {
      print("⚠️ Refresh already in progress, skipping");
      return;
    }

    _isRefreshing = true;

    try {
      print("\n🔄 ==================== REFRESH START ====================");
      print("🔄 Refreshing token...");

      // Step 1: Call refresh endpoint
      final refreshSuccess = await api.refreshToken();

      print("🔄 Refresh result: $refreshSuccess");

      if (!refreshSuccess) {
        print("❌ Token refresh failed - invalid refresh token or server error");
        if (mounted) _showSessionExpiredDialog();
        print("🔄 ==================== REFRESH END ====================\n");
        return;
      }

      // Step 2: Get the new token from provider
      final newToken = ref.read(userProvider).getAccesToken();
      print("🔄 New token from provider: ${newToken?.substring(0, 20)}...");
      print("🔄 New token exists: ${newToken != null}");
      print("🔄 New token not empty: ${newToken?.isNotEmpty}");

      if (newToken == null || newToken.isEmpty) {
        print("❌ No valid token in provider after refresh");
        if (mounted) _showSessionExpiredDialog();
        print("🔄 ==================== REFRESH END ====================\n");
        return;
      }

      print("✅ Got new token, reinitializing player...");

      // Step 3: Dispose old controller
      try {
        if (_controller.value.isInitialized) {
          await _controller.pause();
          print("✅ Old controller paused");
        }
        _controller.removeListener(_handleVideoError);
        await _controller.dispose();
        print("✅ Old controller disposed");
      } catch (e) {
        print("⚠️ Error disposing controller: $e");
      }

      if (!mounted) {
        print("⚠️ Widget unmounted, returning");
        print("🔄 ==================== REFRESH END ====================\n");
        return;
      }

      // Step 4: Create fresh controller with new token
      print("🔄 Creating new controller with fresh token...");

      final headers = <String, String>{
        'Authorization': 'Bearer $newToken',
        'Accept': 'application/vnd.apple.mpegurl, */*',
      };

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        formatHint: VideoFormat.hls,
        httpHeaders: headers,
      );

      _controller.addListener(_handleVideoError);

      print("⏳ Initializing new controller...");
      await _controller.initialize();

      if (!mounted) {
        print("⚠️ Widget unmounted after init");
        print("🔄 ==================== REFRESH END ====================\n");
        return;
      }

      print("✅ New controller ready");
      setState(() {});

      await _controller.play();
      _startHideTimer();

      print("✅ Video resumed playback");
      print("🔄 ==================== REFRESH END ====================\n");
    } catch (e) {
      print("❌ Error during refresh and retry: $e");
      print("❌ Error type: ${e.runtimeType}");
      if (mounted) {
        _showSessionExpiredDialog();
      }
      print("🔄 ==================== REFRESH END ====================\n");
    } finally {
      _isRefreshing = false;
    }
  }

  void _showSessionExpiredDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Your session has expired. Please log in again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBack(); // Go back to previous screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _rewind10() {
    final pos = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
  }

  void _forward10() {
    final pos = _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(
      pos < _controller.value.duration ? pos : _controller.value.duration,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_handleVideoError);
    _controller.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            // Back button
            if (_showControls)
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            // Central controls (play, rewind, forward)
            if (_showControls)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: const Icon(Icons.replay_10),
                      onPressed: _rewind10,
                    ),
                    IconButton(
                      iconSize: 60,
                      color: Colors.white,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                          _startHideTimer();
                        });
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: const Icon(Icons.forward_10),
                      onPressed: _forward10,
                    ),
                  ],
                ),
              ),
            // Progress bar at bottom
            if (_showControls)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.white30,
                      min: 0,
                      max: _controller.value.duration.inMilliseconds.toDouble(),
                      value: _controller.value.position.inMilliseconds
                          .toDouble()
                          .clamp(
                            0.0,
                            _controller.value.duration.inMilliseconds
                                .toDouble(),
                          ),
                      onChanged: (value) {
                        _controller.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
