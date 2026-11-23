import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Valora official brand mark and wordmark rendered directly via vector paths.
class ValoraLogo extends StatelessWidget {
  final double size;
  final Color? colorSage;
  final Color? colorForest;
  final bool isMonochrome;
  final Color? monochromeColor;
  final bool withText;
  final double? fontSize;
  final Color? textColor;

  const ValoraLogo({
    super.key,
    this.size = 24.0,
    this.colorSage,
    this.colorForest,
    this.isMonochrome = false,
    this.monochromeColor,
    this.withText = false,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ValoraLogoPainter(
          colorSage: isMonochrome
              ? (monochromeColor ?? Colors.white)
              : (colorSage ?? AppColors.sageGreen),
          colorForest: isMonochrome
              ? (monochromeColor ?? Colors.white)
              : (colorForest ?? AppColors.forestGreen),
        ),
      ),
    );

    if (!withText) {
      return mark;
    }

    final effectiveFontSize = fontSize ?? (size * 0.9).clamp(16.0, 36.0);
    final effectiveTextColor = textColor ?? (isMonochrome ? (monochromeColor ?? Colors.white) : AppColors.forestGreen);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        const SizedBox(width: 8),
        Text(
          'Valora',
          style: GoogleFonts.plusJakartaSans(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: effectiveTextColor,
          ),
        ),
      ],
    );
  }
}

class _ValoraLogoPainter extends CustomPainter {
  final Color colorSage;
  final Color colorForest;

  const _ValoraLogoPainter({
    required this.colorSage,
    required this.colorForest,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 120.0;
    final dx = (size.width - 120.0 * scale) / 2.0;
    final dy = (size.height - 120.0 * scale) / 2.0;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final paintSage = Paint()
      ..color = colorSage
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final paintForest = Paint()
      ..color = colorForest
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Left Leaf (Sage)
    final path1 = Path();
    path1.moveTo(18, 30.2);
    path1.cubicTo(18, 20.7, 25.7, 13, 35.2, 13);
    path1.cubicTo(42.2, 13, 48.5, 17.2, 51.2, 23.7);
    path1.lineTo(64, 54.5);
    path1.lineTo(51.8, 77.9);
    path1.lineTo(27.6, 43.4);
    path1.cubicTo(21.6, 39.5, 18, 35.0, 18, 30.2);
    path1.close();
    canvas.drawPath(path1, paintSage);

    // 2. Right Leaf (Forest)
    final path2 = Path();
    path2.moveTo(102, 30.2);
    path2.cubicTo(102, 20.7, 94.3, 13, 84.8, 13);
    path2.cubicTo(77.8, 13, 71.5, 17.2, 68.8, 23.7);
    path2.lineTo(56, 54.5);
    path2.lineTo(68.2, 77.9);
    path2.lineTo(92.4, 43.4);
    path2.cubicTo(98.4, 39.5, 102, 35.0, 102, 30.2);
    path2.close();
    canvas.drawPath(path2, paintForest);

    // 3. Center Diamond (Forest)
    final path3 = Path();
    path3.moveTo(51.8, 77.9);
    path3.lineTo(60, 90.5);
    path3.lineTo(68.2, 77.9);
    path3.lineTo(60, 62.2);
    path3.close();
    canvas.drawPath(path3, paintForest);

    // 4. Bottom Smile Curve (Sage)
    final path4 = Path();
    path4.moveTo(34.8, 75.4);
    path4.cubicTo(33.1, 77.2, 33.4, 80.1, 35.7, 81.7);
    path4.lineTo(57.3, 97.9);
    path4.cubicTo(58.9, 99.1, 61.1, 99.1, 62.7, 97.9);
    path4.lineTo(84.3, 81.7);
    path4.cubicTo(86.6, 80.1, 86.9, 77.2, 85.2, 75.4);
    path4.cubicTo(83.5, 73.6, 80.6, 73.3, 78.9, 74.5);
    path4.lineTo(60, 88.7);
    path4.lineTo(41.1, 74.5);
    path4.cubicTo(39.4, 73.3, 36.5, 73.6, 34.8, 75.4);
    path4.close();
    canvas.drawPath(path4, paintSage);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ValoraLogoPainter oldDelegate) {
    return oldDelegate.colorSage != colorSage || oldDelegate.colorForest != colorForest;
  }
}
