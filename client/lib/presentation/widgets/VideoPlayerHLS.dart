import 'dart:async';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

// Reproductor de vídeo HLS con controles personalizados
class VideoPlayerHLS extends ConsumerStatefulWidget {
  final String url; // URL del archivo .m3u8 (HLS)
  final VoidCallback onBack; // Callback al pulsar atrás
  final String? authToken; // Token opcional (aunque se lee del provider)

  const VideoPlayerHLS({
    required this.url,
    this.authToken,
    required this.onBack,
  });

  @override
  ConsumerState<VideoPlayerHLS> createState() => _VideoPlayerHLSState();
}

class _VideoPlayerHLSState extends ConsumerState<VideoPlayerHLS> {
  // Controlador oficial de video_player para reproducir HLS
  late VideoPlayerController _controller;

  // Muestra u oculta los controles (barra progreso, play/pausa, etc.)
  bool _showControls = true;

  // Temporizador que oculta los controles tras 3 segundos sin tocar
  Timer? _hideTimer;

  // Instancia singleton del API (para refrescar token)
  final api = ApiService.instance;

  // Evita múltiples refrescos simultáneos
  bool _isRefreshing = false;

  // Bandera para refrescar solo una vez por sesión (evita bucle infinito)
  bool _hasTriedRefresh = false;

  @override
  void initState() {
    super.initState();

    // Forzamos orientación landscape al entrar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializePlayer();
  }

  // Inicializa el reproductor con headers de autenticación
  Future<void> _initializePlayer() async {
    try {
      // Obtenemos token actual del provider
      final token = ref.read(userProvider).getAccesToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          _showSessionExpiredDialog();
        }
        return;
      }

      // Headers necesarios para HLS autenticado
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.apple.mpegurl, */*',
      };

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        formatHint: VideoFormat.hls,
        httpHeaders: headers,
      );

      // Listener para detectar errores durante reproducción
      _controller.addListener(_handleVideoError);

      await _controller.initialize();

      if (mounted) {
        setState(() {});
        await _controller.play();
        _startHideTimer();
      }
    } catch (error) {
      print(error.toString());

      // Si hay error (muy probablemente 403) → intentamos refrescar token una vez
      if (!_hasTriedRefresh) {
        _hasTriedRefresh = true;
        try {
          await _refreshAndRetry();
          return; // _refreshAndRetry se encarga del resto
        } catch (refreshError) {}
      }

      // Si falla el refresh o ya lo intentamos → mostramos error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading video: $error")));

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showSessionExpiredDialog();
          }
        });
      }
    }
  }

  // Listener que detecta errores durante la reproducción
  void _handleVideoError() {
    if (!_controller.value.hasError) return;

    final error = _controller.value.errorDescription ?? '';

    // Si detectamos 403 Forbidden → intentamos refrescar token
    if ((error.contains('403') || error.contains('Forbidden')) &&
        !_isRefreshing) {
      _refreshAndRetry();
    }
  }

  // Intenta refrescar el token y reinicializar el reproductor
  Future<void> _refreshAndRetry() async {
    if (_isRefreshing) return; // Evitamos múltiples refrescos simultáneos

    _isRefreshing = true;

    try {
      // 1. Llamamos al endpoint de refresh
      final refreshSuccess = await api.refreshToken();
      if (!refreshSuccess) {
        if (mounted) _showSessionExpiredDialog();
        return;
      }

      // 2. Obtenemos el nuevo token del provider
      final newToken = ref.read(userProvider).getAccesToken();
      if (newToken == null || newToken.isEmpty) {
        if (mounted) _showSessionExpiredDialog();
        return;
      }

      // 3. Limpiamos el controlador anterior
      try {
        if (_controller.value.isInitialized) {
          await _controller.pause();
        }
        _controller.removeListener(_handleVideoError);
        await _controller.dispose();
      } catch (e) {
        print(e);
      }

      if (!mounted) return;

      // 4. Creamos nuevo controlador con el token fresco
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

      if (!mounted) return;

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

  // Muestra diálogo cuando la sesión expira o falla el refresh
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
              widget.onBack(); // Volvemos a la pantalla anterior
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Inicia temporizador para ocultar controles tras 3 segundos
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

  // Alterna visibilidad de controles al tocar la pantalla
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideTimer();
    }
  }

  // Retrocede 10 segundos
  void _rewind10() {
    final pos = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
  }

  // Avanza 10 segundos
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

    // Restauramos orientación portrait al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  // Formatea duración en HH:MM:SS o MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Mientras no esté inicializado → spinner negro
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tocar cualquier parte → muestra/oculta controles
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Vídeo que ocupa toda la pantalla y se ajusta
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

            // Botón de volver (solo visible con controles)
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

            // Controles centrales: retroceder, play/pausa, avanzar
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

            // Barra de progreso y tiempos (abajo)
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
