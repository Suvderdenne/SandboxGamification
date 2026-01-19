// widgets/loading_widget.dart
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
    this.delayDuration = const Duration(seconds: 1),
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // 360 градус радиан
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Лого эргэлдэх animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showContent
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Transform.scale(
                          scale: widget.showPulse
                              ? _pulseAnimation.value
                              : 1.0,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  )
                : SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
          ),
          
          // Хэрэв мессеж байвал харуулах
          if (widget.message != null && _showContent) ...[
            const SizedBox(height: 24),
            _buildMessage(),
          ],
          
          // Тойрог гэрэл animation
          if (_showContent) ...[
            const SizedBox(height: 32),
            _buildLightRing(),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo() {
    if (widget.logoAsset != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.spinColor ?? Theme.of(context).primaryColor)
                  .withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            widget.logoAsset!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    // Default лого (хэрэв лого байхгүй бол)
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.school,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _showContent ? 1.0 : 0.0,
      child: Text(
        widget.message!,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLightRing() {
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LightRingPainter(
              progress: _controller.value,
              color: widget.spinColor ?? Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }
}

class _LightRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LightRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Гол тойрог
    canvas.drawCircle(center, radius, paint);
    
    // Эргэлдэж буй гэрэл
    final lightAngle = progress * 2 * 3.14159;
    final lightOffset = Offset(
      center.dx + radius * math.cos(lightAngle),
      center.dy + radius * math.sin(lightAngle),
    );
    
    final lightPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(lightOffset, 8, lightPaint);
    
    // Жижиг гэрлүүд
    for (int i = 0; i < 8; i++) {
      final angle = lightAngle + (i * 3.14159 / 4);
      final offset = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle),
      );
      
      final smallLightPaint = Paint()
        ..color = color.withOpacity(0.5 - (i * 0.05))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(offset, 4, smallLightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightRingPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
