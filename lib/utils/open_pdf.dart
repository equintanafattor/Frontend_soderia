import 'package:url_launcher/url_launcher.dart';

Future<void> openPdf(String url) async {
  final uri = Uri.parse(url);

  final ok = await launchUrl(
    uri,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: '_blank', // ✅ en web abre una pestaña nueva
  );

  if (!ok) {
    throw Exception('No se pudo abrir el PDF: $url');
  }
}
