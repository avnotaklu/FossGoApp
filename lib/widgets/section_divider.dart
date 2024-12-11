import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(
        color: context.theme.colorScheme.outlineVariant,
      ),
    );
  }
}
