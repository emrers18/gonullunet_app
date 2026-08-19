import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:gonullunet_app/utils/responsive.dart';

Widget buildGlassButton(
    BuildContext context, IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: Responsive.padding(context, all: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
          ),
          child: Icon(icon, color: Colors.white, size: Responsive.scale(context, 24)),
        ),
      ),
    ),
  );
}
