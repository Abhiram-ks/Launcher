enum AppIconShape {
  // Most Popular (Top 3)
  squircle,      // iOS-style smooth rounded square
  circle,        // Classic circular
  roundedSquare, // Rounded square
  
  // Popular
  rectangle,     // Slight rounded corners
  teardrop,      // Rounded top, pointed bottom
  pebble,        // Organic smooth shape
  
  // Unique/Modern
  clipped,       // Three rounded corners
  hexagon,       // Six-sided geometric
  octagon,       // Eight-sided geometric
  leaf,          // Organic leaf shape
  square,        // Pure square (no rounding)
  stadium;       // Pill/capsule shape

  String get displayName {
    switch (this) {
      case AppIconShape.squircle:
        return 'Squircle (iOS)';
      case AppIconShape.circle:
        return 'Circle';
      case AppIconShape.roundedSquare:
        return 'Rounded Square';
      case AppIconShape.rectangle:
        return 'Rectangle';
      case AppIconShape.teardrop:
        return 'Teardrop';
      case AppIconShape.pebble:
        return 'Pebble';
      case AppIconShape.clipped:
        return 'Clipped Corner';
      case AppIconShape.hexagon:
        return 'Hexagon';
      case AppIconShape.octagon:
        return 'Octagon';
      case AppIconShape.leaf:
        return 'Leaf';
      case AppIconShape.square:
        return 'Square';
      case AppIconShape.stadium:
        return 'Stadium';
    }
  }

  // Rating out of 5
  double get rating {
    switch (this) {
      case AppIconShape.squircle:
        return 4.9;
      case AppIconShape.circle:
        return 4.8;
      case AppIconShape.roundedSquare:
        return 4.7;
      case AppIconShape.rectangle:
        return 4.5;
      case AppIconShape.teardrop:
        return 4.4;
      case AppIconShape.pebble:
        return 4.3;
      case AppIconShape.clipped:
        return 4.2;
      case AppIconShape.hexagon:
        return 4.0;
      case AppIconShape.octagon:
        return 3.9;
      case AppIconShape.leaf:
        return 3.8;
      case AppIconShape.square:
        return 3.7;
      case AppIconShape.stadium:
        return 3.9;
    }
  }

  // Is this shape popular?
  bool get isPopular {
    switch (this) {
      case AppIconShape.squircle:
      case AppIconShape.circle:
      case AppIconShape.roundedSquare:
        return true;
      default:
        return false;
    }
  }

  // Description for each shape
  String get description {
    switch (this) {
      case AppIconShape.squircle:
        return 'Smooth iOS-style superellipse';
      case AppIconShape.circle:
        return 'Classic perfect circle';
      case AppIconShape.roundedSquare:
        return 'Square with rounded corners';
      case AppIconShape.rectangle:
        return 'Slightly rounded rectangle';
      case AppIconShape.teardrop:
        return 'Rounded top, elegant taper';
      case AppIconShape.pebble:
        return 'Natural organic curves';
      case AppIconShape.clipped:
        return 'Modern asymmetric style';
      case AppIconShape.hexagon:
        return 'Six-sided geometric';
      case AppIconShape.octagon:
        return 'Eight-sided geometric';
      case AppIconShape.leaf:
        return 'Natural leaf-inspired';
      case AppIconShape.square:
        return 'Perfect square, no rounding';
      case AppIconShape.stadium:
        return 'Pill-shaped elongated';
    }
  }
}

