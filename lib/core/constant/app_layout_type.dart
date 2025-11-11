enum AppLayoutType {
  list,
  grid;

  String get displayName {
    switch (this) {
      case AppLayoutType.list:
        return 'List View';
      case AppLayoutType.grid:
        return 'Grid View';
    }
  }

  String get storageValue {
    switch (this) {
      case AppLayoutType.list:
        return 'list';
      case AppLayoutType.grid:
        return 'grid';
    }
  }

  static AppLayoutType fromString(String value) {
    switch (value) {
      case 'list':
        return AppLayoutType.list;
      case 'grid':
        return AppLayoutType.grid;
      default:
        return AppLayoutType.list;
    }
  }
}

