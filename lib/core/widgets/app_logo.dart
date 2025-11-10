import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          _buildLogoText(),
        ],
      ],
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purpleGradientStart,
            AppColors.purpleGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleGradientStart.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner circle
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          
          // House icon
          CustomPaint(
            size: Size(size * 0.6, size * 0.6),
            painter: HouseIconPainter(),
          ),
          
          // Connection dots
          if (animated) ...[
            _buildAnimatedDot(0, -size * 0.35, 0),
            _buildAnimatedDot(size * 0.35, 0, 0.5),
            _buildAnimatedDot(0, size * 0.35, 1.0),
            _buildAnimatedDot(-size * 0.35, 0, 1.5),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(double x, double y, double delay) {
    return Positioned(
      left: (size / 2) + x - 6,
      top: (size / 2) + y - 6,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 6, end: 10),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: value,
            height: value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppColors.pinkGradientStart,
                  AppColors.pinkGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pinkGradientStart.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoText() {
    return Column(
      children: [
        Text(
          'LifeHub',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.25,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: size * 0.05),
        Text(
          'Organize Your Life',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: size * 0.1,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class HouseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF667eea)
      ..style = PaintingStyle.fill;

    // Draw house base
    final houseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.5,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(houseRect, paint);

    // Draw roof
    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..close();

    final roofGradient = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.pinkGradientStart,
          AppColors.pinkGradientEnd,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(roofPath, roofGradient);

    // Draw door
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.6,
        size.width * 0.16,
        size.height * 0.25,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(doorRect, strokePaint);

    // Draw windows
    final windowPaint = Paint()..color = const Color(0xFF667eea);
    
    final leftWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.48,
        size.width * 0.12,
        size.height * 0.12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(leftWindow, windowPaint);

    final rightWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.63,
        size.height * 0.48,
        size.width * 0.12,
        size.height * 0.12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rightWindow, windowPaint);

    // Draw window crosses
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Left window cross
    canvas.drawLine(
      Offset(size.width * 0.31, size.height * 0.48),
      Offset(size.width * 0.31, size.height * 0.60),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.54),
      Offset(size.width * 0.37, size.height * 0.54),
      crossPaint,
    );

    // Right window cross
    canvas.drawLine(
      Offset(size.width * 0.69, size.height * 0.48),
      Offset(size.width * 0.69, size.height * 0.60),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.63, size.height * 0.54),
      Offset(size.width * 0.75, size.height * 0.54),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}