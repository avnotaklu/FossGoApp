import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/homepage/matchmaking_page.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';

class SelectionBadge extends StatelessWidget {
  final bool selected;
  final Widget? child;

  final String label;
  const SelectionBadge({
    super.key,
    required this.selected,
    this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Badge(
        label: selected ? dot : null,
        backgroundColor: Colors.transparent,
        isLabelVisible: selected,
        offset: Offset(0, 0),
        largeSize: 25,
        smallSize: 25,
        padding: const EdgeInsets.all(0),
        alignment: Alignment.topRight,
        child: Container(
          height: context.height * 0.5,
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: context.theme.shadowColor,
                // blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: Center(
            child: Text(label, style: pointTextStyle(context)),
          ),
        ),
      ),
    );
  }

  TextStyle? pointTextStyle(BuildContext con) => con.textTheme.bodyLarge;

  Widget get dot => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: defaultTheme.disabledColor,
            width: 2,
          ),
        ),
        child: StoneSelectionWidget(
          StoneSelectionType.auto,
        ),
      );
}
