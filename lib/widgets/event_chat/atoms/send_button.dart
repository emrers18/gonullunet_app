import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

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
        width: Responsive.scale(context, 46),
        height: Responsive.scale(context, 46),
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
            ? AppLoadingIndicator(size: Responsive.scale(context, 22))
            : Icon(Icons.send_rounded,
                color: Colors.white, size: Responsive.scale(context, 20)),
      ),
    );
  }
}
