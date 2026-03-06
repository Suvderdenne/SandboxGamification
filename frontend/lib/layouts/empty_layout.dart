// layouts/empty_layout.dart

import 'package:flutter/material.dart';

class EmptyLayout extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;

  const EmptyLayout({
    super.key,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: body),
    );
  }
}