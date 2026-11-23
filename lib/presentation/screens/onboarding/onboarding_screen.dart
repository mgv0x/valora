import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/valora_logo.dart';
import '../../navigation/main_navigation_screen.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  void _finish(BuildContext context) {
    if (onComplete != null) {
      onComplete!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            // Top Logo & Brand Wordmark
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ValoraLogo(size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Valora',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Warm Minimalist Pantry Art Banner
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), offset: Offset(0, 2), blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _PantryArtPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 15, color: AppColors.sageGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Tudo fresco, visível e em harmonia',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Welcoming Content
            Text(
              'Sua comida merece ser aproveitada.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.forestGreen,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Organize sua despensa, acompanhe validades no seu ritmo e reduza o desperdício sem esforço ou culpa.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: AppColors.subHeader,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 3 Pillars of Delight (Horizontal Chips)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPillarChip(icon: Icons.eco, label: 'Sem desperdício'),
                _buildPillarChip(icon: Icons.savings, label: 'Mais economia'),
                _buildPillarChip(icon: Icons.spa, label: 'Rotina tranquila'),
              ],
            ),
            const SizedBox(height: 20),

            // Warm Reassuring Micro-Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0EAC9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active, size: 20, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembretes serenos',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          'Avisos carinhosos antes de qualquer alimento vencer',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Bottom Interactive Actions
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _finish(context),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Começar agora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        onSuccess: () => _finish(context),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Já utilizo o Valora',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: TextStyle(color: AppColors.softGray)),
                    ),
                    Text(
                      'Entrar',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.sageGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PantryArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 320.0;
    canvas.save();
    canvas.scale(scale, scale);

    final linePaint = Paint()
      ..color = const Color(0xFFC1C8C1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final forestStroke = Paint()
      ..color = AppColors.forestGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final sageFill = Paint()
      ..color = const Color(0xFFD0EAC9)
      ..style = PaintingStyle.fill;

    final oliveFill = Paint()
      ..color = const Color(0xFFDFE7B8)
      ..style = PaintingStyle.fill;

    // Tabletop line
    canvas.drawLine(const Offset(20, 150), const Offset(300, 150), linePaint);

    // Mason jar glass body
    final jarRect = RRect.fromRectAndRadius(const Rect.fromLTWH(60, 50, 70, 96), const Radius.circular(14));
    final jarFill = Paint()..color = const Color(0xFFF7FAF4);
    canvas.drawRRect(jarRect, jarFill);

    // Grains inside
    final grainPath = Path()
      ..moveTo(62, 100)
      ..quadraticBezierTo(95, 90, 128, 100)
      ..lineTo(128, 142)
      ..quadraticBezierTo(95, 148, 62, 142)
      ..close();
    canvas.drawPath(grainPath, oliveFill);

    canvas.drawRRect(jarRect, forestStroke);

    // Jar lid
    final lidRect = RRect.fromRectAndRadius(const Rect.fromLTWH(66, 40, 58, 10), const Radius.circular(4));
    canvas.drawRRect(lidRect, sageFill);
    canvas.drawRRect(lidRect, forestStroke);

    // Pear
    final pearPath = Path()
      ..moveTo(170, 146)
      ..cubicTo(150, 146, 142, 132, 146, 114)
      ..cubicTo(149, 102, 154, 96, 158, 84)
      ..cubicTo(161, 75, 168, 73, 171, 73)
      ..cubicTo(174, 73, 181, 75, 184, 84)
      ..cubicTo(188, 96, 193, 102, 196, 114)
      ..cubicTo(200, 132, 190, 146, 170, 146)
      ..close();
    canvas.drawPath(pearPath, oliveFill);
    canvas.drawPath(pearPath, forestStroke);

    // Citrus fruit
    final citrusCenter = const Offset(215, 126);
    canvas.drawCircle(citrusCenter, 20, sageFill);
    canvas.drawCircle(citrusCenter, 20, forestStroke);

    // Herbal sprig
    final herbStem = Path()
      ..moveTo(235, 148)
      ..quadraticBezierTo(250, 110, 245, 60);
    canvas.drawPath(herbStem, forestStroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
