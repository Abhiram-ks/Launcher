enum AppIconShape {
  rectangle,
  circle,
  square,
  clipped;

  String get displayName {
    switch (this) {
      case AppIconShape.rectangle:
        return 'Rectangle';
      case AppIconShape.circle:
        return 'Circle';
      case AppIconShape.square:
        return 'Square';
      case AppIconShape.clipped:
        return 'Clipped';
    }
  }
}

