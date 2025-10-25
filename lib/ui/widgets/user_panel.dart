import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:intl/intl.dart';

/// Panel de información y gestión del usuario
class UserPanel extends StatelessWidget {
  const UserPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final UsuariosController usuariosController = Get.find();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Obx(() {
        final usuario = usuariosController.usuario.value;
        final isLoading = usuariosController.isLoading.value;
        final currentUser = usuariosController.currentUser;

        if (isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Mostrar email del usuario de Firebase Auth si no hay datos de Firestore
        final displayName =
            usuario?.nombre ?? currentUser?.displayName ?? 'Usuario';
        final displayEmail =
            usuario?.email ?? currentUser?.email ?? 'email@ejemplo.com';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior del modal
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar del usuario
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
              ),
              const SizedBox(height: 16),

              // Nombre del usuario
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Email del usuario
              Text(
                displayEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              // Fecha de nacimiento
              if (usuario?.fechaNacimiento != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cake, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(usuario!.fechaNacimiento),
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              // Botón Editar Perfil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditProfileDialog(
                      context,
                      usuariosController,
                      usuario,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Cambiar Contraseña
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showChangePasswordDialog(context, usuariosController);
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Cambiar contraseña'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[700]!, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context, usuariosController);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[600]!, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  /// Muestra diálogo para editar perfil
  void _showEditProfileDialog(
    BuildContext context,
    UsuariosController controller,
    dynamic usuario,
  ) {
    final nombreController = TextEditingController(text: usuario?.nombre ?? '');
    final emailController = TextEditingController(text: usuario?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validar nombre
              if (nombreController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'El nombre no puede estar vacío',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Validar email
              final email = emailController.text.trim();
              if (email.isEmpty) {
                Get.snackbar(
                  'Error',
                  'El correo electrónico no puede estar vacío',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Validar formato de email
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(email)) {
                Get.snackbar(
                  'Error',
                  'El formato del correo electrónico no es válido',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.pop(context);
              await controller.updateUserData(
                nombre: nombreController.text.trim(),
                email: email,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para cambiar contraseña
  void _showChangePasswordDialog(
    BuildContext context,
    UsuariosController controller,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Todos los campos son obligatorios',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (newPassword.length < 5) {
                  Get.snackbar(
                    'Error',
                    'La nueva contraseña debe tener al menos 5 caracteres',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  Get.snackbar(
                    'Error',
                    'Las contraseñas no coinciden',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                Navigator.pop(context);
                await controller.changePassword(currentPassword, newPassword);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra confirmación de cierre de sesión
  void _showLogoutConfirmation(
    BuildContext context,
    UsuariosController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.logout, color: Colors.red[600], size: 40),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
