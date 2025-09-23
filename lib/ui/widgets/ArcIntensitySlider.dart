import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArcIntensitySlider extends StatefulWidget {
  final double value; // 0..1
  final Color color;
  final ValueChanged<double> onChanged;

  const ArcIntensitySlider({
    super.key,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  State<ArcIntensitySlider> createState() => _ArcIntensitySliderState();
}

class _ArcIntensitySliderState extends State<ArcIntensitySlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value.clamp(0.0, 1.0);
  }

  void _handlePan(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    double angle = math.atan2(dy, dx); // -PI..PI
    double normalized = (angle + math.pi) / math.pi; // 0..2
    normalized = normalized.clamp(0.0, 2.0);
    double v = (normalized / 2.0);
    v = v.clamp(0.0, 1.0);
    setState(() => _value = v);
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _handlePan(d.localPosition, context.size!),
      onPanUpdate: (d) => _handlePan(d.localPosition, context.size!),
      child: CustomPaint(
        painter: _ArcPainter(color: widget.color, value: _value),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value; // 0..1
  final Color color;

  _ArcPainter({required this.color, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - stroke;

    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    final startAngle = math.pi;
    final sweepBg = math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepBg,
      false,
      bgPaint,
    );

    final sweep = sweepBg * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      fgPaint,
    );

    final knobAngle = startAngle + sweep;
    final knobPos = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );
    final knobPaint = Paint()..color = color;
    canvas.drawCircle(knobPos, stroke + 2, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
