import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

class SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SendButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color:
              isLoading ? AppColors.primaryColor.withOpacity(0.6) : AppColors.primaryColor,
          shape: BoxShape.circle,
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: isLoading
            ? const AppLoadingIndicator(size: 22)
            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
