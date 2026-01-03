import 'package:url_launcher/url_launcher.dart';

Future<void> openPdf(String url) async {
  final uri = Uri.parse(url);

  if (!await canLaunchUrl(uri)) {
    throw Exception('No se pudo abrir el PDF');
  }

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
