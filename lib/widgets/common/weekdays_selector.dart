// widgets/common/weekdays_selector.dart
import 'package:flutter/material.dart';

class WeekdaysSelector extends StatefulWidget {
  final Set<int> initial; // 1=Lun ... 7=Dom
  final ValueChanged<Set<int>> onChanged;
  const WeekdaysSelector({
    super.key,
    this.initial = const {},
    required this.onChanged,
  });

  @override
  State<WeekdaysSelector> createState() => _WeekdaysSelectorState();
}

class _WeekdaysSelectorState extends State<WeekdaysSelector> {
  late Set<int> selected = {...widget.initial}; 
  static const labels = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"]; 

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: List.generate(7, (i) {
        final idx = i + 1;
        final isOn = selected.contains(idx);
        return FilterChip(
          label: Text(labels[i]),
          selected: isOn,
          onSelected: (v) {
            setState(() => v ? selected.add(idx) : selected.remove(idx));
            widget.onChanged(selected); 
          },
        );
      }),
    );
  }
}
