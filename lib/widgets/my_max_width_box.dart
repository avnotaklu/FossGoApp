import 'package:flutter/cupertino.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MyMaxWidthBox extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MyMaxWidthBox({
    required this.maxWidth,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: context.height, maxWidth: maxWidth),
          // maxWidth: maxWidth,
          child: child,
        ),
      ),
    );
  }
}
