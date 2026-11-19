import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'link_opener.g.dart';

/// Opens a saved link in the browser (S12), behind a provider so tests can
/// fake it. Resolves to false if nothing could open it.
class LinkOpener {
  const new();

  Future<bool> open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

@Riverpod(keepAlive: true)
LinkOpener linkOpener(Ref ref) => const LinkOpener();
