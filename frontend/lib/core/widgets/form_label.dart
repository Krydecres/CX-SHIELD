import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Nhãn phía trên ô nhập như trong wireframe.
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
          children: [
            if (required) TextSpan(text: ' *', style: TextStyle(color: context.colors.error)),
          ],
        ),
      ),
    );
  }
}
