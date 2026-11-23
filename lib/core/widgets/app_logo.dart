import 'package:flutter/material.dart';
import '../constants/asset_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isHero;
  final String heroTag;

  const AppLogo({
    super.key,
    this.size = 80,
    this.isHero = false,
    this.heroTag = 'app_logo_hero',
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      AssetConstants.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF702321),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.shield, color: Colors.white, size: 36),
          ),
        );
      },
    );

    if (isHero) {
      return Hero(
        tag: heroTag,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

