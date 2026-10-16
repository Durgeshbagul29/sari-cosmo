import 'package:flutter/material.dart';

class BubbleLoadingIndicator extends StatefulWidget {
  final Color color;
  final double bubbleSize;

  const BubbleLoadingIndicator({
    super.key,
    this.color = Colors.white,
    this.bubbleSize = 6.0,
  });

  @override
  State<BubbleLoadingIndicator> createState() => _BubbleLoadingIndicatorState();
}

class _BubbleLoadingIndicatorState extends State<BubbleLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.bubbleSize * 2.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              double progress = _controller.value - delay;
              if (progress < 0) progress += 1.0;
              
              // Staggered bounce height and scale using sine curve
              final double dy = -1.2 * widget.bubbleSize * (progress < 0.5 ? progress * 2 : (1.0 - progress) * 2);
              final double scale = 0.8 + 0.4 * (1.0 - (dy.abs() / (widget.bubbleSize * 1.2)));

              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: widget.bubbleSize,
                    height: widget.bubbleSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
