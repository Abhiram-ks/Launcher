class AppFontSizes {
  static const double defaultSize = 16.0;
  static const double smallSize = 12.0;
  static const double middleSize = 14.0;
  static const double largeSize = 18.0;
  static const double xlSize = 20.0;
  static const double xxlSize = 24.0;

  static const List<double> availableSizes = [
    defaultSize,
    smallSize,
    middleSize,
    largeSize,
    xlSize,
    xxlSize,
  ];

  static const List<String> sizeNames = [
    'Default (16px)',
    'Small (12px)',
    'Middle (14px)',
    'Large (18px)',
    'XL (20px)',
    'XXL (24px)',
  ];

  static String getSizeName(double size) {
    final index = availableSizes.indexOf(size);
    if (index == -1) return 'Default (16px)';
    return sizeNames[index];
  }

  static double normalizeSize(double size) {
    // Find the closest matching size
    if (availableSizes.contains(size)) {
      return size;
    }
    // Find closest match
    double closest = defaultSize;
    double minDiff = (size - defaultSize).abs();
    for (final availableSize in availableSizes) {
      final diff = (size - availableSize).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = availableSize;
      }
    }
    return closest;
  }
}

