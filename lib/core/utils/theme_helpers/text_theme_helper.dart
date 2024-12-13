import 'package:flutter/material.dart';

extension TextStyleExt on TextStyle {
  // TextStyle invert(BuildContext context) {
  //   return this.copyWith(
  //     color: MediaQuery.of(context).platformBrightness == Brightness.dark
  //         ? Theme.of(context).dark
  //         : Colors.black,
  //   );
  // }

  TextStyle get italicify => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underlinify => copyWith(decoration: TextDecoration.underline);
  TextStyle get boldify => copyWith(fontWeight: FontWeight.bold);
}
