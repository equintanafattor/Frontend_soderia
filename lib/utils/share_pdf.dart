import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> sharePdfFromUrl({
  required String url,
  required String filename,
  String? message,
}) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('No se pudo descargar PDF: ${res.statusCode} ${res.body}');
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(res.bodyBytes);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/pdf', name: filename)],
    text: message,
  );
}
