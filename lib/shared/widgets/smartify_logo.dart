import 'package:flutter/material.dart';
import 'dart:math' as math;

class SmartifyLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const SmartifyLogo({
    super.key,
    this.size = 80,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShieldPainter(color: backgroundColor),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: size * 0.12),
            child: CustomWifiIcon(size: size * 0.5, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class CustomWifiIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CustomWifiIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CustomWifiPainter(color: color),
    );
  }
}

class _CustomWifiPainter extends CustomPainter {
  final Color color;

  _CustomWifiPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height * 0.875);
    
    // Cung dưới (nhỏ nhất)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.15),
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      paint,
    );
    
    // Cung giữa
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.45),
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      paint,
    );

    // Cung ngoài cùng lớn nhất
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.75),
      -math.pi * 3 / 4,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldPainter extends CustomPainter {
  final Color color;

  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    double w = size.width;
    double h = size.height;

    var path = Path();
    
    // Đỉnh bo tròn rộng hơn
    path.moveTo(w * 0.35, h * 0.18);
    path.quadraticBezierTo(w * 0.50, h * 0.08, w * 0.65, h * 0.18);
    
    // Cạnh nóc phải
    path.lineTo(w * 0.85, h * 0.32);
    // Bo tròn vai phải rất sâu để thật tròn
    path.quadraticBezierTo(w * 0.98, h * 0.42, w * 0.92, h * 0.55);
    
    // Cạnh sườn phải thuôn vô
    path.lineTo(w * 0.85, h * 0.82);
    // Bo tròn góc dưới phải to mềm hơn
    path.quadraticBezierTo(w * 0.82, h * 0.98, w * 0.65, h * 0.96);
    
    // Đường đáy
    path.lineTo(w * 0.35, h * 0.96);
    // Bo tròn góc dưới trái to mềm đối xứng 100%
    path.quadraticBezierTo(w * 0.18, h * 0.98, w * 0.15, h * 0.82);
    
    // Cạnh sườn trái thuôn lên vai
    path.lineTo(w * 0.08, h * 0.55);
    // Bo tròn vai trái rất sâu và đối xứng hoàn toàn
    path.quadraticBezierTo(w * 0.02, h * 0.42, w * 0.15, h * 0.32);
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
