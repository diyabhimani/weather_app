import 'package:flutter/material.dart';

class AnimatedRefreshButton extends StatefulWidget {
  const AnimatedRefreshButton({
    super.key,
    required this.isRefreshing,
    required this.onPressed,
  });

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  State<AnimatedRefreshButton> createState() => _AnimatedRefreshButtonState();
}

class _AnimatedRefreshButtonState extends State<AnimatedRefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isRefreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh Weather',
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      onPressed: widget.isRefreshing ? null : widget.onPressed,
    );
  }
}
