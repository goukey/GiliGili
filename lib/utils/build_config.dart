class BuildConfig {
  static const bool isDebug = bool.fromEnvironment('dart.vm.product').not;
} 