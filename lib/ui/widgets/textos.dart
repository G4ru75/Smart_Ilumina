import 'package:flutter/material.dart';

// Widget reutilizable para campos de texto
class TextoField extends StatefulWidget {
  final bool contrasena;
  final TextEditingController controlador;
  final String titulo;
  final String textoSobre;

  const TextoField({
    Key? key,
    required this.contrasena,
    required this.controlador,
    required this.titulo,
    required this.textoSobre,
  }) : super(key: key);

  @override
  State<TextoField> createState() => _TextoFieldState();
}

class _TextoFieldState extends State<TextoField> {
  bool _obscureText = true;
  bool _isFocused = false;

  IconData _getIcon() {
    if (widget.contrasena) return Icons.lock_outline;
    if (widget.titulo.toLowerCase().contains('email'))
      return Icons.email_outlined;
    if (widget.titulo.toLowerCase().contains('nombre')) return Icons.home;
    return Icons.text_fields;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextField(
        controller: widget.controlador,
        obscureText: widget.contrasena ? _obscureText : false,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: widget.titulo,
          hintText: widget.textoSobre,
          labelStyle: TextStyle(
            color: _isFocused
                ? Colors.blueAccent.shade700
                : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.transparent, // Sin fondo blanco
          // Ícono prefijo con color dinámico
          prefixIcon: Icon(
            _getIcon(),
            color: _isFocused
                ? Colors.blueAccent.shade700
                : Colors.grey.shade800,
            size: 22,
          ),

          // Toggle de contraseña mejorado
          suffixIcon: widget.contrasena
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _isFocused
                        ? Colors.blueAccent.shade100
                        : Colors.grey.shade800,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  splashRadius: 20,
                  tooltip: _obscureText
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                )
              : null,

          // Bordes mejorados con transición de color
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent.shade700,
              width: 2.5,
            ),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.5),
          ),

          // Padding
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// Widget reutilizable para el texto superior
class TextoSuperior extends StatelessWidget {
  final String texto;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const TextoSuperior({
    Key? key,
    required this.texto,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class TextosPequenos extends StatelessWidget {
  final String texto;

  const TextosPequenos({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        letterSpacing: 1,
      ),
    );
  }
}

class InputFecha extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const InputFecha({
    Key? key,
    required this.controller,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Selecciona tu fecha',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime.now(),
        );
        if (picked != null) {
          controller.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      },
    );
  }
}

class HoraInputField extends StatelessWidget {
  final String titulo;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  const HoraInputField({
    super.key,
    required this.titulo,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    this.enabled = true,
  });

  String _fmt(BuildContext context) {
    return value == null ? '— — : — —' : value!.format(context);
  }

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    final initial = value ?? const TimeOfDay(hour: 18, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: titulo,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          child: Text(_fmt(context)),
        ),
      ),
    );
  }
}

class textoMediano extends StatelessWidget {
  final String texto;
  const textoMediano({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
