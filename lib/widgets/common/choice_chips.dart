// widgets/common/choice_chips.dart
import 'package:flutter/material.dart';

class SingleChoiceChips<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const SingleChoiceChips({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, 
      children: items.map((e) => ChoiceChip(
        label: Text(labelOf(e)),
        selected: e == selected,
        onSelected: (_) => onChanged(e),
      )).toList(),
    );
  }
}
