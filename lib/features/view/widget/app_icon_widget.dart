import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/service/app_icon_shape_notifier.dart';

class AppIconWidget extends StatelessWidget {
  final Uint8List? iconData;
  final double size;
  final String appName;

  const AppIconWidget({
    super.key,
    required this.iconData,
    this.size = 40,
    this.appName = '',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppIconShape>(
      valueListenable: AppIconShapeNotifier.instance,
      builder: (context, shape, child) {
        return _buildIconWithShape(shape);
      },
    );
  }

  Widget _buildIconWithShape(AppIconShape shape) {
    final borderRadius = _getBorderRadius(shape);
    
    Widget iconWidget;
    if (iconData != null && iconData!.isNotEmpty) {
      iconWidget = Image.memory(
        iconData!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(borderRadius);
        },
        gaplessPlayback: true,
      );
    } else {
      iconWidget = _buildPlaceholder(borderRadius);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: iconWidget,
    );
  }

  BorderRadius _getBorderRadius(AppIconShape shape) {
    switch (shape) {
      case AppIconShape.rectangle:
        return BorderRadius.circular(8);
      case AppIconShape.circle:
        return BorderRadius.circular(size / 2);
      case AppIconShape.square:
        return BorderRadius.zero;
      case AppIconShape.clipped:
        return BorderRadius.only(
          topLeft: Radius.circular(size * 0.3),
          topRight: Radius.circular(size * 0.3),
          bottomRight: Radius.circular(size * 0.3),
        );
    }
  }

  Widget _buildPlaceholder(BorderRadius borderRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.apps,
        color: Colors.white54,
        size: size * 0.6,
      ),
    );
  }
}

