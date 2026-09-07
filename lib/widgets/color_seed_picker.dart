import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A grid of Material seed-color swatches used to drive [ColorScheme.fromSeed].
/// Built entirely from standard Material [Colors] — no custom color assets.
class ColorSeedPicker extends StatelessWidget {
  const ColorSeedPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in kSeedColorOptions)
          _SwatchButton(
            color: color,
            selected: color.toARGB32() == selected.toARGB32(),
            onTap: () => onSelected(color),
          ),
      ],
    );
  }
}

class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 3,
                  )
                : null,
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                )
              : null,
        ),
      ),
    );
  }
}
