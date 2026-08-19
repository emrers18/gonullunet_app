import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: Responsive.padding(context, left: 8, top: 4, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: Responsive.scale(context, 16),
              backgroundColor: AppColors.darkPrimaryColor,
              child: Icon(
                Icons.auto_awesome,
                size: Responsive.scale(context, 18),
                color: Colors.white,
              ),
            ),
            SizedBox(width: Responsive.scale(context, 8)),
            Container(
              padding: Responsive.padding(context, horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kCardBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Responsive.scale(context, 16)),
                  topRight: Radius.circular(Responsive.scale(context, 16)),
                  bottomLeft: Radius.circular(Responsive.scale(context, 4)),
                  bottomRight: Radius.circular(Responsive.scale(context, 16)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final value = ((_controller.value + delay) % 1.0);
                      final opacity = 0.3 + 0.7 * (1 - (2 * value - 1).abs());
                      return Container(
                        margin: Responsive.padding(context, horizontal: 2),
                        child: Opacity(
                          opacity: opacity.clamp(0.3, 1.0),
                          child: Container(
                            width: Responsive.scale(context, 8),
                            height: Responsive.scale(context, 8),
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryText,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
