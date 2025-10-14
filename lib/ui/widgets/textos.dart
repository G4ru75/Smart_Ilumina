import 'package:flutter/material.dart';

// Widget reutilizable para campos de texto
class TextoField extends StatelessWidget {
  final String titulo;
  final TextEditingController controlador;
  final bool contrasena;
  final String textoSobre;

  const TextoField({
    Key? key,
    required this.titulo,
    required this.controlador,
    this.contrasena = false,
    required this.textoSobre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        TextField(
          controller: controlador,
          obscureText: contrasena,
          decoration: InputDecoration(
            hintText: textoSobre,
            hintStyle: TextStyle(color: Colors.grey[800]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
        ),
      ],
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
