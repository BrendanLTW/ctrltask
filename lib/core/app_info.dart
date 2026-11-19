/// The app's version, as `pubspec.yaml` has it without the build number.
/// A test keeps the two in step; there's no package for it on the stack.
const appVersion = '0.1.0';

/// "0.1": major.minor, as S35's footer shows it.
String get appVersionShort => appVersion.split('.').take(2).join('.');
