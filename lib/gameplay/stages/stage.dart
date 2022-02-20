import 'package:flutter/material.dart';
import 'package:go/utils/position.dart';

abstract class Stage {
  const Stage();
  onClickCell(Position position, BuildContext context);
}

