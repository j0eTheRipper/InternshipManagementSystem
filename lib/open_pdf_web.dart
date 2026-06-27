// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

void openPdfInBrowser(Uint8List bytes, {String? fileName}) {
  final blob = Blob([bytes], 'application/pdf');
  final url = Url.createObjectUrlFromBlob(blob);
  window.open(url, '_blank');
  Timer(const Duration(minutes: 1), () => Url.revokeObjectUrl(url));
}
