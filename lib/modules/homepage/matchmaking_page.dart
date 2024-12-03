
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/time_control_dto.dart';
import 'package:go/services/find_match_dto.dart';
import 'package:go/modules/homepage/matchmaking_provider.dart';
import 'package:go/widgets/selection_badge.dart';
import 'package:go/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class MatchmakingPage extends StatefulWidget {
  const MatchmakingPage({super.key});

  @override
  State<MatchmakingPage> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MatchmakingProvider(context.read<SignalRProvider>()),
      builder: (context, child) => Scaffold(
        drawer: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.7,
          child: Center(
            child: Text(context.read<AuthProvider>().currentUserRaw.email),
          ),
        ),
        appBar: MyAppBar('Baduk',
            leading: IconButton(
              onPressed: () {
                if (Scaffold.of(context).isDrawerOpen) {
                  Scaffold.of(context).closeDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              icon: const Icon(Icons.menu),
            )),
        body: Consumer<MatchmakingProvider>(
          builder: (context, provider, child) => Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Board Size',
                style: headingTextStyle(),
              ),
              SizedBox(
                  height: MediaQuery.sizeOf(context).width * 0.15,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: provider.allBoardSizes
                          .map(
                            (size) => Expanded(
                              child: boardSizeSelector(size, provider),
                            ),
                          )
                          .toList())),
              Text(
                'Time Controls',
                style: headingTextStyle(),
              ),
              Column(
                  mainAxisSize: MainAxisSize.max,
                  children: provider.allTimeControls
                      .map(
                        (timeControl) => SizedBox(
                          height: MediaQuery.sizeOf(context).width * 0.15,
                          child: timeSelector(timeControl, provider),
                        ),
                      )
                      .toList()),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      provider.findMatch();

                      context
                          .read<MatchmakingProvider>()
                          .onMatchmakingUpdated
                          .stream
                          .listen((event) {
                        if (context.mounted) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return GameWidget(
                                game: event.game,
                                gameInteractor: LiveGameOracle(
                                  api: Api(),
                                  authBloc: context.read<AuthProvider>(),
                                  signalRbloc: context.read<SignalRProvider>(),
                                  joiningData: event,
                                ));
                          }));
                        }
                      });
                    },
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

  Widget boardSizeSelector(
      MatchableBoardSizes size, MatchmakingProvider provider) {
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
              child: Text(size.boardName, style: pointTextStyle()),
            ),
          ),
        ),
      ),
    );
  }

  Widget timeSelector(
      TimeControlDto timeControl, MatchmakingProvider provider) {
    var selected = provider.selectedTimeControls.contains(timeControl);
    return GestureDetector(
      onTap: () {
        provider.modifyTimeControl(timeControl, !selected);
      },
      child: Card(
        color: defaultTheme.mainHighlightColor,
        child: Padding(
          padding: const EdgeInsets.only(right: 25.0, top: 5.0),
          child: SelectionBadge(
            selected: selected,
            child: Center(
                child: Text(timeControl.repr(), style: pointTextStyle())),
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
