import 'package:flutter/material.dart';

/// Küçük, inline dönen logo spinnerı.
/// [size] varsayılan olarak 32'dir (CircularProgressIndicator büyüklüğünde).
/// Tam ekran loading için [AppLoadingCenter] veya [AppLoadingPage] kullanın.
class AppLoadingIndicator extends StatefulWidget {
  final double size;

  const AppLoadingIndicator({super.key, this.size = 32});

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'lib/assets/images/logo.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// [AppLoadingIndicator]'ı merkeze alan yardımcı widget.
/// Scaffold olmadan sadece ortaya hizalar — tam ekranı kaplamaz.
class AppLoadingCenter extends StatelessWidget {
  final double size;

  const AppLoadingCenter({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Center(child: AppLoadingIndicator(size: size));
  }
}
