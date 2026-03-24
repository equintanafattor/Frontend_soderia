import 'package:url_launcher/url_launcher.dart';

Future<void> abrirEnMaps({
  required double lat,
  required double lng,
  String? label,
}) async {
  final query = label != null
      ? Uri.encodeComponent(label)
      : '$lat,$lng';

  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'No se pudo abrir Maps';
  }
}
