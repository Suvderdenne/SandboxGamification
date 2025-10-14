import 'package:flutter/material.dart';

class ThemeSwitch extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ThemeSwitch({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      onPressed: onToggleTheme,
    );
  }
}
