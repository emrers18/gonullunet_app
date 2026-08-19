import 'package:flutter/material.dart';

import 'package:gonullunet_app/utils/responsive.dart';

Widget buildSocialButton(
  BuildContext context,
  String label,
  Color color, {
  VoidCallback? onTap,
  Gradient? gradient,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: Responsive.scale(context, 40),
        height: Responsive.scale(context, 40),
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.sp(context, 16))),
        ),
      ),
    ),
  );
}
