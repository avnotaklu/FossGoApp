import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/utils/models.dart';

class RequestSend extends StatelessWidget {
  final GameMatch match;
  RequestSend(this.match);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BackgroundScreenWithDialog(
      child: ShareGameIDButton(match),
    );
  }
}
