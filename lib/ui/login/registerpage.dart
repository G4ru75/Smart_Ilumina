import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({Key? key}) : super(key: key);

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage>
    with SingleTickerProviderStateMixin {
  final UsuariosController usuariosControler = Get.find();
  final TextEditingController txtNombre = TextEditingController();
  final TextEditingController txtFechaNacimiento = TextEditingController();
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

    // **FIX: Inicializar correctamente ambas animaciones**
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Iniciar animación
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    txtNombre.dispose();
    txtFechaNacimiento.dispose();
    txtEmail.dispose();
    txtContrasena.dispose();
    super.dispose();
  }

  String Validacion() {
    if (txtEmail.text.isEmpty ||
        txtNombre.text.isEmpty ||
        txtFechaNacimiento.text.isEmpty ||
        txtContrasena.text.isEmpty) {
      return 'Por favor llene todos los campos';
    }

    if (txtNombre.text.length < 3 || txtNombre.text.length > 30) {
      return 'El nombre debe tener entre 3 y 30 caracteres';
    }

    if (txtFechaNacimiento.text.isEmpty) {
      return 'La fecha de nacimiento no es válida';
    }

    if (!txtEmail.text.contains('@') || !txtEmail.text.contains('.')) {
      return 'El correo electrónico no es válido';
    }

    if (txtContrasena.text.length < 6 || txtContrasena.text.length > 20) {
      return 'La contraseña debe tener entre 6 y 20 caracteres';
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
      '¡Registro exitoso!',
      'Tu cuenta ha sido creada correctamente',
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

  Future<void> handleSignUp() async {
    String resultado = Validacion();

    if (resultado != 'OK') {
      mostrarError(resultado);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parsear la fecha de nacimiento
      DateTime fechaNacimiento = DateTime.parse(txtFechaNacimiento.text);

      // Registrar usuario con el orden correcto: nombre, fecha, email, contraseña
      await usuariosControler.registrarUsuario(
        txtNombre.text.trim(),
        fechaNacimiento,
        txtEmail.text.trim(),
        txtContrasena.text.trim(),
      );

      if (!mounted) return;

      // Limpiar campos
      txtNombre.clear();
      txtFechaNacimiento.clear();
      txtEmail.clear();
      txtContrasena.clear();

      mostrarExito();

      // Esperar un momento antes de navegar
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navegar al login
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        mostrarError('Error al registrar: ${e.toString()}');
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
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      // Logo con fade
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Center(
                          child: Column(
                            children: [
                              TextoSuperior(texto: 'Smart💡ilumina'),
                              SizedBox(height: 1),
                              Icon(
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
                                child: TextoSuperior(texto: 'Sign Up'),
                              ),
                              const SizedBox(height: 24),

                              // Nombre
                              TextoField(
                                contrasena: false,
                                controlador: txtNombre,
                                titulo: 'Nombre',
                                textoSobre: 'Ingrese su nombre',
                              ),
                              const SizedBox(height: 10),

                              // Fecha de nacimiento
                              InputFecha(
                                controller: txtFechaNacimiento,
                                label: 'Fecha de Nacimiento',
                              ),
                              const SizedBox(height: 10),

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
                              const SizedBox(height: 23),

                              // Botón Sign Up
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
                                    onPressed: _isLoading ? null : handleSignUp,
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
                                            'Sign Up',
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

                              // Link a Login
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const LoginPage(),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                      ),
                                    );
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
                                          texto: '¿Ya tienes cuenta? ',
                                        ),
                                        Text(
                                          'Iniciar sesión',
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
