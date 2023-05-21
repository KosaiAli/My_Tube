import 'dart:math';

import 'package:flutter/material.dart';

class MyCustomClipper extends CustomPainter {
  MyCustomClipper({
    this.width = 0.0,
  });
  double width;

  Path getpath(size) {
    double center = size.width / 2;
    double ratio = width / 28;

    Path path = Path();
    path.moveTo(0, 0);

    path.lineTo(center - width - 25 * ratio, 0);

    var a = width + 5.8 * ratio;
    var b = 0.0;
    var r = width + 5 * ratio;
    var x = (a * pow(r, 2) -
            sqrt(pow(a, 2) * pow(b, 2) * pow(r, 2) +
                pow(b, 4) * pow(r, 2) -
                pow(b, 2) * pow(r, 4))) /
        (pow(a, 2) + pow(b, 2));

    var y = sqrt(pow(r, 2) - pow(x, 2));

    path.quadraticBezierTo(center - a, b, center - x, y);

    path.arcToPoint(Offset(center + x, y),
        radius: Radius.circular(r), clockwise: false);

    path.quadraticBezierTo(center + a, b, center + width + 25 * ratio, 0);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF212121);
    Path content = getpath(size);
    content.lineTo(size.width, size.height);
    content.lineTo(0, size.height);
    content.lineTo(0, 0);
    canvas.drawPath(content, paint);
    canvas.drawPath(
        getpath(size),
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.grey[700]!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
