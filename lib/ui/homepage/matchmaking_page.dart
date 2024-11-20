import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/models/time_control.dart';
import 'package:go/ui/homepage/matchmaking_provider.dart';
import 'package:go/utils/widgets/selection_badge.dart';
import 'package:go/views/my_app_bar.dart';
import 'package:provider/provider.dart';

class MatchmakingPage extends StatelessWidget {
  const MatchmakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MatchmakingProvider(),
      builder: (context, child) => Scaffold(
        appBar: const MyAppBar(
          'Baduk',
          leading: Icon(Icons.menu),
        ),
        body: Consumer<MatchmakingProvider>(
          builder: (context, provider, child) => Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Board Size',
                style: headingTextStyle(),
              ),
              Container(
                  height: MediaQuery.sizeOf(context).width * 0.15,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: provider.allBoardSizes
                          .map(
                            (size) => Expanded(
                              child: BoardSizeSelector(size, provider),
                            ),
                          )
                          .toList())),
              Text(
                'Time Controls',
                style: headingTextStyle(),
              ),
              Container(
                  height: MediaQuery.sizeOf(context).width * 0.25,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: provider.allTimeControls
                          .map(
                            (timeControl) => Expanded(
                                child: TimeSelector(timeControl, provider)),
                          )
                          .toList())),
              Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Find", style: headingTextStyle()),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget BoardSizeSelector((int, int) size, MatchmakingProvider provider) {
    var selected = provider.selectedBoardSizes.contains(size);
    return GestureDetector(
      onTap: () {
        provider.modifyBoardSize(size, !selected);
      },
      child: Card(
        color: defaultTheme.mainHighlightColor,
        child: Padding(
          padding: const EdgeInsets.only(right: 25.0, top: 5.0),
          child: SelectionBadge(
            selected: selected,
            child: Center(
              child: Text("${size.$1}x${size.$2}", style: pointTextStyle()),
            ),
          ),
        ),
      ),
    );
  }

  Widget TimeSelector(
      (String, TimeControl) timeControl, MatchmakingProvider provider) {
    var selected = provider.selectedTimeControls.contains(timeControl.$2);
    return GestureDetector(
      onTap: () {
        provider.modifyTimeControl(timeControl.$2, !selected);
      },
      child: Card(
        color: defaultTheme.mainHighlightColor,
        child: Padding(
          padding: const EdgeInsets.only(right: 25.0, top: 5.0),
          child: SelectionBadge(
            selected: selected,
            child: Center(child: Text(timeControl.$1, style: pointTextStyle())),
          ),
        ),
      ),
    );
  }

  TextStyle headingTextStyle() =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w500);

  TextStyle pointTextStyle() =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);
}
