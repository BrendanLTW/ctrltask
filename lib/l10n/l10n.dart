import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:ctrltask/l10n/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
