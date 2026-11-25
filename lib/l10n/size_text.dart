import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// File sizes with their words (S41's Export button, S42's status).
extension SizeText on AppLocalizations {
  /// "1.2 MB", or "260 KB" rounded up, so a small file never reads "0 KB".
  String fileSize(int bytes, String locale) => bytes >= 1024 * 1024
      ? sizeMb(NumberFormat('0.#', locale).format(bytes / (1024 * 1024)))
      : sizeKb('${(bytes / 1024).ceil()}');
}
