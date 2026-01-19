// lib/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingWidget extends StatefulWidget {
  final String? message;
  final String? logoAsset;
  final Color? spinColor;
  final Duration delayDuration;
  final bool showPulse;

  const LoadingWidget({
    super.key,
    this.message,
    this.logoAsset,
    this.spinColor,
    this.delayDuration = const Duration(seconds: 5000),
    this.showPulse = true,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi, // 360 градус радиан
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 1 секунд хүлээгээд лого харуулах
    Future.delayed(widget.delayDuration, () {
      if (mounted) {
        setState(() {
          _showContent = true;
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
    final themeColor = widget.spinColor ?? Theme.of(context).primaryColor;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Эхлээд зүгээр лого (1 секунд)
          if (!_showContent)
            _buildStaticLogo(),
          
          // 2. Дараа нь эргэлдэх animation
          if (_showContent)
            _buildAnimatedLogo(themeColor),
          
          // 3. Мессеж (animation эхэлсний дараа)
          if (widget.message != null && _showContent) ...[
            const SizedBox(height: 24),
            _buildMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildStaticLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.logoAsset != null
          ? Image.asset(
            widget.logoAsset!,
            width: 60,  // Хэмжээ тодорхойлно
            height: 60,
          )
          : _buildDefaultLogo(),
    );
  }

  Widget _buildAnimatedLogo(Color themeColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Тойрог гэрэл
            Container(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _RotatingLightPainter(
                  angle: _rotationAnimation.value,
                  color: themeColor,
                ),
              ),
            ),
            
            // Эргэлдэж буй лого
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: widget.showPulse ? _pulseAnimation.value : 1.0,
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
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.logoAsset != null
                        ? Image.asset(
                            widget.logoAsset!,
                            width: 50,
                            height: 50,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.quiz,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return const Icon(
      Icons.quiz,
      size: 60,
      color: Colors.blue,
    );
  }

  Widget _buildMessage() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 5000),
      opacity: _showContent ? 1.0 : 0.0,
      child: Column(
        children: [
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Түр хүлээнэ үү...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
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
    final radius = size.width / 2 - 20;
    
    // Тойрог шугам
    final circlePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, circlePaint);
    
    // 8 жижиг гэрэл
    for (int i = 0; i < 8; i++) {
      final lightAngle = angle + (i * math.pi / 4);
      final opacity = 0.3 + (0.7 * (i % 4) / 4);
      
      final lightPos = Offset(
        center.dx + radius * math.cos(lightAngle),
        center.dy + radius * math.sin(lightAngle),
      );
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(lightPos, 5, paint);
    }
    
    // Гол эргэлдэж буй гэрэл
    final mainLightPos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(mainLightPos, 10, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _RotatingLightPainter oldDelegate) {
    return angle != oldDelegate.angle || color != oldDelegate.color;
  }
}