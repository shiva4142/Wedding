/// Static configuration for the wedding. Edit values here to customize.
class WeddingConfig {
  static const bride = 'Pooja';
  static const groom = 'Shiva';
  static final date = DateTime(2026, 5, 1, 9, 25, 0);
  static const venueCity = 'Kodumur, Kurnool, India';
  static const hashtag = '#PoojaWedsShiva';

  /// Backend base URL.
  /// During `flutter run -d chrome` Dart Frog defaults to http://localhost:8080.
  /// Override at build time:
  ///   flutter build web --dart-define=API_BASE=https://api.example.com
  static const apiBase =
      String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:8080');

  /// Public site URL for QR codes and share links.
  static const siteUrl =
      String.fromEnvironment('SITE_URL', defaultValue: 'http://localhost:5000');
}
