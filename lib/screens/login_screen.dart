import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/screens/home_screen.dart';
import 'package:frontend_soderia/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave del formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus para saltar de usuario -> contraseña -> submit con Enter
  final _usuarioFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _authService = AuthService();
  bool _loading = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _usuarioFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _loading) return;

    setState(() => _loading = true);

    try {
      final usuario = _usuarioController.text.trim();
      final password = _passwordController.text.trim();

      final success = await _authService.login(usuario, password);

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Login exitoso, $usuario!')),
        );
        // Navegar al Home (reemplaza el stack)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(nombreUsuario: usuario)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 800;

    final leftPanel = Container(
      color: AppColors.verde, // panel verde de tu paleta
      child: const Center(
        child: Text(
          'SAN MIGUEL',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );

    final rightPanel = Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Usuario
                    TextFormField(
                      controller: _usuarioController,
                      focusNode: _usuarioFocus,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre de usuario';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Contraseña
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_mostrarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          tooltip: _mostrarPassword ? 'Ocultar' : 'Mostrar',
                          icon: Icon(
                            _mostrarPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _mostrarPassword = !_mostrarPassword);
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _onSubmit(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 4) {
                          return 'La contraseña debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botón submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(_loading ? 'Ingresando...' : 'Iniciar sesión'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: cs.primary,      // azul de tu tema
                          foregroundColor: cs.onPrimary,     // blanco
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _loading ? null : _onSubmit,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Link "Olvidé mi contraseña" (placeholder)
                    TextButton(
                      onPressed: _loading ? null : () {},
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: cs.background,
      body: isWide
          // Dos columnas (tablet/desktop)
          ? Row(
              children: [
                Expanded(flex: 1, child: leftPanel),
                Expanded(flex: 1, child: rightPanel),
              ],
            )
          // Una sola columna (móvil)
          : Column(
              children: [
                Expanded(flex: 1, child: leftPanel),
                Expanded(flex: 1, child: rightPanel),
              ],
            ),
    );
  }
}
