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
      // Get current token
      final token = ref.read(userProvider).getAccesToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          _showSessionExpiredDialog();
        }
        return;
      }

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.apple.mpegurl, */*',
      };

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        formatHint: VideoFormat.hls,
        httpHeaders: headers,
      );

      // Add error listener BEFORE initialization
      _controller.addListener(_handleVideoError);
      await _controller.initialize();

      if (mounted) {
        setState(() {});
        await _controller.play();
        _startHideTimer();
      }
    } catch (error) {
      if (error is Exception) {
        print(error.toString());
      }

      // ANY error during init = likely 403, try refresh once
      if (!_hasTriedRefresh) {
        _hasTriedRefresh = true;

        try {
          await _refreshAndRetry();
          return; // _refreshAndRetry will restart everything
        } catch (refreshError) {}
      } else {}

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
    }
  }

  void _handleVideoError() {
    if (!_controller.value.hasError) {
      return;
    }

    final error = _controller.value.errorDescription ?? '';

    // Check for 403 Forbidden error during playback
    if ((error.contains('403') || error.contains('Forbidden')) &&
        !_isRefreshing) {
      _refreshAndRetry();
    } else if (_isRefreshing) {}
  }

  Future<void> _refreshAndRetry() async {
    // Prevent concurrent refresh attempts
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;

    try {
      // Step 1: Call refresh endpoint
      final refreshSuccess = await api.refreshToken();

      if (!refreshSuccess) {
        if (mounted) _showSessionExpiredDialog();
        return;
      }

      // Step 2: Get the new token from provider
      final newToken = ref.read(userProvider).getAccesToken();

      if (newToken == null || newToken.isEmpty) {
        if (mounted) _showSessionExpiredDialog();
        return;
      }

      // Step 3: Dispose old controller
      try {
        if (_controller.value.isInitialized) {
          await _controller.pause();
        }
        _controller.removeListener(_handleVideoError);
        await _controller.dispose();
      } catch (e) {
        print(e);
      }

      if (!mounted) {
        return;
      }

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

      await _controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {});

      await _controller.play();
      _startHideTimer();
    } catch (e) {
      if (mounted) {
        _showSessionExpiredDialog();
      }
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
