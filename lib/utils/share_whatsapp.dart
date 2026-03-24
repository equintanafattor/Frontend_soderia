import 'package:url_launcher/url_launcher.dart';

Future<void> shareWhatsApp({
  required String phone, // ej: '5493435123456'
  required String message,
}) async {
  final encodedMessage = Uri.encodeComponent(message);

  final url = Uri.parse(
    'https://wa.me/$phone?text=$encodedMessage',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir WhatsApp');
  }
}
