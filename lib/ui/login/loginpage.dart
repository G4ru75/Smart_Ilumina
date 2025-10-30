import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final UsuariosController usuariosController = Get.find();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1), // Comienza desde abajo
          end: Offset.zero, // Termina en su posición
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Iniciar animación
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    txtEmail.dispose();
    txtContrasena.dispose();
    super.dispose();
  }

  String validacion() {
    if (txtEmail.text.isEmpty && txtContrasena.text.isEmpty) {
      return 'Debe de llenar todos los campos';
    }

    if (txtEmail.text.isEmpty) {
      return 'El correo electrónico no puede estar vacío';
    }

    if (!txtEmail.text.contains('@') || !txtEmail.text.contains('.')) {
      return 'El correo electrónico no es válido';
    }

    if (txtContrasena.text.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }

    if (txtContrasena.text.length < 5) {
      return 'La contraseña debe tener mínimo 5 caracteres';
    }

    if (txtContrasena.text.length > 20) {
      return 'La contraseña debe tener máximo 20 caracteres';
    }

    return 'OK';
  }

  void mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  void mostrarExito() {
    Get.snackbar(
      '¡Bienvenido!',
      'Inicio de sesión exitoso',
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  Future<void> handleLogin() async {
    String validacionResult = validacion();

    if (validacionResult != 'OK') {
      mostrarError(validacionResult);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ok = await usuariosController.loginUsuario(
        txtEmail.text.trim(),
        txtContrasena.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        mostrarExito();
        txtContrasena.clear();
        txtEmail.clear();

        // Esperar un momento antes de navegar
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/home');
      } else {
        mostrarError('Usuario o contraseña incorrecta');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: viewInsets),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),

                      // Logo con fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            children: [
                              const TextoSuperior(texto: 'Smart💡ilumina'),
                              const SizedBox(height: 1),
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 200,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Card con animación de slide
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA9AED4),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100),
                              topRight: Radius.circular(100),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                offset: Offset(0, -8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 42,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: TextoSuperior(texto: 'Login'),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              TextoField(
                                contrasena: false,
                                controlador: txtEmail,
                                titulo: 'Email',
                                textoSobre: 'Ingrese su correo electrónico',
                              ),
                              const SizedBox(height: 10),

                              // Contraseña
                              TextoField(
                                contrasena: true,
                                controlador: txtContrasena,
                                titulo: 'Contraseña',
                                textoSobre: 'Ingrese su contraseña',
                              ),

                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                              ),

                              // Botón Login
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: Colors.blueAccent
                                          .withOpacity(0.5),
                                      disabledBackgroundColor:
                                          Colors.blueAccent.shade200,
                                    ),
                                    onPressed: _isLoading ? null : handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 20,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Link registro
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed('/signup');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextosPequenos(
                                          texto: '¿No tienes cuenta? ',
                                        ),
                                        Text(
                                          'Regístrate',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.blueAccent,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
