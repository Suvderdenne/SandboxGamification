// widgets/fancy_loading.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class FancyLoading extends StatefulWidget {
  final String? message;
  final Widget? logo;
  final Color? color;
  final Duration delayBeforeAnimation;

  const FancyLoading({
    super.key,
    this.message,
    this.logo,
    this.color,
    this.delayBeforeAnimation = const Duration(seconds: 1),
  });

  @override
  State<FancyLoading> createState() => _FancyLoadingState();
}

class _FancyLoadingState extends State<FancyLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _rotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // 1 секунд хүлээгээд animation эхлүүлэх
    Future.delayed(widget.delayBeforeAnimation, () {
      if (mounted) {
        setState(() {
          _showAnimation = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).primaryColor;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Эхлээд зүгээр лого харуулах
          if (!_showAnimation)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: widget.logo ?? _buildDefaultLogo(),
            ),
          
          // 2. Дараа нь animation харуулах
          if (_showAnimation)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Тойрог гэрэл
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _RotatingLightPainter(
                          angle: _rotation.value,
                          color: themeColor,
                        ),
                      ),
                    ),
                    
                    // Эргэлдэж буй лого
                    Transform.rotate(
                      angle: _rotation.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                themeColor,
                                themeColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: widget.logo ?? _buildDefaultLogo(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          
          // 3. Мессеж
          if (widget.message != null) ...[
            const SizedBox(height: 32),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showAnimation ? 1.0 : 0.0,
              child: Text(
                widget.message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return const Icon(
      Icons.school,
      size: 40,
      color: Colors.white,
    );
  }
}

class _RotatingLightPainter extends CustomPainter {
  final double angle;
  final Color color;

  _RotatingLightPainter({
    required this.angle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // 8 жижиг гэрэл
    for (int i = 0; i < 8; i++) {
      final lightAngle = angle + (i * math.pi / 4);
      final opacity = 0.2 + (0.8 * (i % 3) / 3);
      
      final lightPos = Offset(
        center.dx + radius * math.cos(lightAngle),
        center.dy + radius * math.sin(lightAngle),
      );
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(lightPos, 6, paint);
    }
    
    // Гол эргэлдэж буй гэрэл
    final mainLightPos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(mainLightPos, 12, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _RotatingLightPainter oldDelegate) {
    return angle != oldDelegate.angle || color != oldDelegate.color;
  }
}