import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';

enum StatefulCardState { enabled, disabled }

// Inspired by material 3 design
// only a subset and is an approximation

class StatefulCard extends StatelessWidget {
  final StatefulCardState state;
  final Widget Function(BuildContext) builder;

  const StatefulCard({super.key, required this.state, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: state == StatefulCardState.enabled
          ? context.theme.colorScheme.secondary
          // ignore: deprecated_member_use
          : context.theme.colorScheme.surfaceVariant,
      child: Theme(
        data: context.theme.copyWith(
          textTheme: buildTextTheme(
            state == StatefulCardState.enabled
                ? context.theme.colorScheme.onSecondary
                : context.theme.colorScheme.onInverseSurface,
          ),
        ),
        child: Builder(builder: builder),
      ),
    );
  }
}
