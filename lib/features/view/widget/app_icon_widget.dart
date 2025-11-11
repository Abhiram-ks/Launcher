import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/service/app_icon_shape_notifier.dart';

import '../../../core/service/app_text_style_notifier.dart';

class AppIconWidget extends StatelessWidget {
  final Uint8List? iconData;
  final String? iconPath; // For custom icons from file path
  final double size;
  final String appName;

  const AppIconWidget({
    super.key,
    this.iconData,
    this.iconPath,
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
    
    // Priority: iconPath (custom icon) > iconData (original icon)
    if (iconPath != null) {
      // Custom icon from file path
      final file = File(iconPath!);
      if (file.existsSync()) {
        iconWidget = Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to original icon if custom icon fails
            return _buildFromIconData(borderRadius);
          },
          gaplessPlayback: true,
        );
      } else {
        // File doesn't exist, fallback to original icon
        iconWidget = _buildFromIconData(borderRadius);
      }
    } else if (iconData != null && iconData!.isNotEmpty) {
      // Original icon from memory
      iconWidget = _buildFromIconData(borderRadius);
    } else {
      // No icon available
      iconWidget = _buildPlaceholder(borderRadius);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color:  AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.1),
        child: iconWidget),
    );
  }

  Widget _buildFromIconData(BorderRadius borderRadius) {
    if (iconData != null && iconData!.isNotEmpty) {
      return Image.memory(
        iconData!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(borderRadius);
        },
        gaplessPlayback: true,
      );
    }
    return _buildPlaceholder(borderRadius);
  }

  BorderRadius _getBorderRadius(AppIconShape shape) {
    switch (shape) {
      case AppIconShape.squircle:
        return BorderRadius.circular(size * 0.25); // iOS-style smooth curve
      case AppIconShape.circle:
        return BorderRadius.circular(size / 2);
      case AppIconShape.roundedSquare:
        return BorderRadius.circular(size * 0.2);
      case AppIconShape.rectangle:
        return BorderRadius.circular(size * 0.15);
      case AppIconShape.teardrop:
        return BorderRadius.only(
          topLeft: Radius.circular(size / 2),
          topRight: Radius.circular(size / 2),
          bottomLeft: Radius.circular(size * 0.15),
          bottomRight: Radius.circular(size * 0.15),
        );
      case AppIconShape.pebble:
        return BorderRadius.only(
          topLeft: Radius.circular(size * 0.35),
          topRight: Radius.circular(size * 0.3),
          bottomLeft: Radius.circular(size * 0.3),
          bottomRight: Radius.circular(size * 0.35),
        );
      case AppIconShape.clipped:
        return BorderRadius.only(
          topLeft: Radius.circular(size * 0.3),
          topRight: Radius.circular(size * 0.3),
          bottomRight: Radius.circular(size * 0.3),
          bottomLeft: Radius.zero,
        );
      case AppIconShape.hexagon:
        return BorderRadius.circular(size * 0.12); // Slight rounding for hexagon effect
      case AppIconShape.octagon:
        return BorderRadius.circular(size * 0.18); // Octagon-like rounding
      case AppIconShape.leaf:
        return BorderRadius.only(
          topLeft: Radius.circular(size * 0.1),
          topRight: Radius.circular(size * 0.4),
          bottomLeft: Radius.circular(size * 0.4),
          bottomRight: Radius.circular(size * 0.1),
        );
      case AppIconShape.square:
        return BorderRadius.zero;
      case AppIconShape.stadium:
        return BorderRadius.circular(size * 0.4); // Pill shape
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

