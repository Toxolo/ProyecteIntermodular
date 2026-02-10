import 'dart:convert';
import 'package:client/config/GlobalVariables.dart';
import 'package:client/domain/entities/User.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Pantalla de inicio de sesión con diseño oscuro, animaciones y manejo de login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Clave para validar el formulario completo
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar email y contraseña
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controla si la contraseña se muestra en texto plano o asteriscos
  bool _isPasswordVisible = false;

  // Indica si está procesando el login (muestra spinner en el botón)
  bool _isLoading = false;

  // Controladores y animaciones para entrada suave de elementos
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Variable auxiliar para el usuario (se usa tras login exitoso)
  late User userActual;

  @override
  void initState() {
    super.initState();

    // Animación de aparición gradual (fade)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Animación de deslizamiento desde abajo hacia su posición final
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Iniciamos ambas animaciones al cargar la pantalla
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // Liberamos recursos para evitar memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Maneja todo el proceso de inicio de sesión
  Future<void> _handleLogin() async {
    // Valida campos del formulario antes de continuar
    if (!_formKey.currentState!.validate()) return;

    // Mostramos indicador de carga
    setState(() => _isLoading = true);

    // Payload en formato JSON-RPC (parece backend Odoo o similar)
    final payload = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "db": "Padalustro",
        "login": _emailController.text.trim(), // trim() evita espacios
        "password": _passwordController.text,
      },
      "id": 1,
    };

    try {
      final response = await http.post(
        Uri.parse(getTokenUrl), // URL de login definida en GlobalVariables
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Respuesta exitosa con tokens
        if (data['result'] != null) {
          setState(() => _isLoading = false);

          final result = data['result'];
          final token = result['access_token'];
          final refreshToken = result['refresh_token'];

          // Decodificamos el JWT para obtener información del usuario
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          final int id = decodedToken['user_id'] ?? 0;
          final String name = decodedToken['name'] ?? "USER";
          final bool isAdmin = decodedToken['is_admin'] ?? false;
          final bool hasSuscription = decodedToken['has_subscription'] ?? false;
          final int expiration = decodedToken['exp'] ?? 0;

          // Creamos objeto User con todos los datos
          User u = User();
          u.setId(id);
          u.setName(name);
          u.setAccesToken(token);
          u.setHasSuscription(hasSuscription);
          u.setIsAdmin(isAdmin);
          u.setRefreshToken(refreshToken);
          u.setTokenExpiration(u.formatExp(expiration));

          // Guardamos el usuario en el provider de Riverpod
          ref.read(userProvider.notifier).afegirUsuari(u);

          ref.read(userProvider.notifier).startTokenRefreshCheck();

          // Pequeña espera hasta que el estado se actualice (no ideal, pero funcional)
          while (ref.read(userProvider).getAccesToken() == null) {
            await Future.delayed(const Duration(milliseconds: 500));
          }

          // Navegamos a la pantalla principal eliminando esta del stack
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
        // Error devuelto por el servidor
        else if (data['error'] != null) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${data['error']['message']}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        // Respuesta inesperada (no tiene result ni error)
        else {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resposta inesperada del servidor'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
      // Error HTTP diferente de 200
      else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error HTTP ${response.statusCode}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de connexió: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo con gradiente oscuro elegante
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1a0a0a), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 60),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Logo animado con escala elástica + nombre de la app
  Widget _buildLogo() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.play_circle_filled,
                        size: 80,
                        color: Colors.black,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Padalustro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Benvingut de nou',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Contenedor del formulario (email + contraseña + botón)
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildLoginButton(),
        ],
      ),
    );
  }

  // Campo para introducir el correo electrónico
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Correu electrònic',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.white.withOpacity(0.7),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Si us plau, introdueix el teu correu';
        }
        if (!value.contains('@')) {
          return 'Introdueix un correu vàlid';
        }
        return null;
      },
    );
  }

  // Campo para la contraseña con opción de mostrar/ocultar
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Contrasenya',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.7),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Si us plau, introdueix la teva contrasenya';
        }
        return null;
      },
    );
  }

  // Botón grande de "Iniciar sessió" con spinner durante carga
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                'INICIAR SESSIÓ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  // Pie de página con enlace a registro (aún por implementar)
  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                const url = registerURL;
                final uri = Uri.parse(url);

                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Error launching URL: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blueGrey[900], // example: dark background
                foregroundColor: const Color(
                  0xFFFFD700,
                ), // gold text/icon color
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Registra\'t',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // optional improvement
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
