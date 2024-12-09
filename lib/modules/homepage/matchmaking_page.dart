import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
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
        body: Consumer<MatchmakingProvider>(
          builder: (context, provider, child) => Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Board Size', style: titleLargeStyle(context)),
              SizedBox(
                  height: MediaQuery.sizeOf(context).width * 0.15,
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: provider.allBoardSizes
                          .map(
                            (size) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: boardSizeSelector(
                                  size,
                                  provider,
                                ),
                              ),
                            ),
                          )
                          .toList())),
              Text(
                'Time Controls',
                style: titleLargeStyle(context),
              ),
              SizedBox(height: 6.0),
              Column(
                  mainAxisSize: MainAxisSize.max,
                  children: provider.allTimeControls
                      .map(
                        (timeControl) => Container(
                          height: MediaQuery.sizeOf(context).width * 0.15,
                          padding: EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 8.0,
                          ),
                          child: timeSelector(timeControl, provider),
                        ),
                      )
                      .toList()),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                      text: "Play",
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
                                    signalRbloc:
                                        context.read<SignalRProvider>(),
                                    joiningData: event,
                                  ));
                            }));
                          }
                        });
                      }),
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
    return SelectionBadge(
      onTap: (v) {
        provider.modifyBoardSize(size, !selected);
      },
      selected: selected,
      label: size.boardName,
      // Card(
      //   color: cardColor,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(5),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.only(right: 25.0, top: 5.0),
      //     child: SelectionBadge(
      //       selected: selected,
      //       child: Center(
      //         child: Text(size.boardName, style: pointTextStyle()),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget timeSelector(
      TimeControlDto timeControl, MatchmakingProvider provider) {
    var selected = provider.selectedTimeControls.contains(timeControl);
    return SelectionBadge(
      selected: selected,
      label: timeControl.repr(),
      onTap: (v) => provider.modifyTimeControl(timeControl, !selected),
    );
  }

  TextStyle? titleLargeStyle(BuildContext context) {
    return context.textTheme.titleLarge;
  }
}

class PrimaryButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        // elevation: WidgetStateProperty.all(100),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        ),
        textStyle: WidgetStateProperty.all(
          context.textTheme.bodyLarge
        ),
        // side: WidgetStateProperty.all(
        //   BorderSide(
        //     // color: Colors.white,
        //     color: context.theme.shadowColor,
        //     width: 1,
        //   ),
        // ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
