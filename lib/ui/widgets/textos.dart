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
        SizedBox(height: 4),
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
