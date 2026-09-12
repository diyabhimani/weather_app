import 'package:flutter/material.dart';

class WeatherLoadingShimmer extends StatefulWidget {
  const WeatherLoadingShimmer({
    super.key,
    this.message = 'Fetching weather data...',
  });

  final String message;

  @override
  State<WeatherLoadingShimmer> createState() => _WeatherLoadingShimmerState();
}

class _WeatherLoadingShimmerState extends State<WeatherLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular loader icon
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_animation.value * 0.4),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Skeleton cards preview
            _buildPlaceholder(width: 140, height: 24),
            const SizedBox(height: 12),
            _buildPlaceholder(width: 90, height: 56, borderRadius: 16),
            const SizedBox(height: 12),
            _buildPlaceholder(width: 180, height: 16),
          ],
        ),
      ),
    );
  }
}
