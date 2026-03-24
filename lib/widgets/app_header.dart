import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_soderia/core/session/session_state.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key, required this.sectionTitle});

  final String sectionTitle;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  late DateTime _today;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _scheduleMidnightTick();
  }

  void _scheduleMidnightTick() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final diff = nextMidnight.difference(now);

    _midnightTimer = Timer(diff, () {
      if (!mounted) return;
      setState(() => _today = DateTime.now());
      _scheduleMidnightTick();
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.sectionTitle.trim();
    final t = Theme.of(context).textTheme;
    final color = Colors.white; // 👈 clave

    final dateText = _capitalize(
      DateFormat("EEEE d 'de' MMMM", 'es_AR').format(_today),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 2),

        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                dateText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),

            ValueListenableBuilder<SessionUser?>(
              valueListenable: sessionState,
              builder: (context, user, _) {
                final userText = user?.nombre ?? 'Sin usuario';

                return Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 14, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          userText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
}
