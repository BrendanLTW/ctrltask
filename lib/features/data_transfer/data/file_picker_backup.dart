import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Restore → Choose a file: any JSON file on the phone or in iCloud Drive.
/// One that isn't on local disk (an Android content URI) is copied to a
/// temporary file first, so restore always reads a path.
Future<String?> pickBackupFileWithFilePicker() async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (picked == null) return null;
  if (picked.path case final path?) return path;
  final copy = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}'
    'ctrltask-restore-${DateTime.now().millisecondsSinceEpoch}.json',
  );
  await copy.writeAsBytes(await picked.readAsBytes(), flush: true);
  return copy.path;
}
