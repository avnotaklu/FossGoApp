import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/string_formatting.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/gameplay/create/stone_selection_widget.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/stages/before_start_stage.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/gameplay_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/time_control.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/homepage_bloc.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:go/utils/widgets/selection_badge.dart';
import 'package:provider/provider.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Consumer<CreateGameProvider>(builder: (context, cgp, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading("Color"),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.05,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: stoneSelectionButton(
                          context, StoneSelectionType.black),
                    ),
                    Expanded(
                      child: stoneSelectionButton(
                          context, StoneSelectionType.white),
                    ),
                    Expanded(
                      child: stoneSelectionButton(
                          context, StoneSelectionType.auto),
                    ),
                  ],
                ),
              ),
              sectionHeading("Size"),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.05,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: Constants.boardSizes.map((item) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => cgp.changeBoardSize(item),
                          child: Card(
                            color: cgp.boardSize == item
                                ? defaultTheme.enabledColor
                                : defaultTheme.disabledColor,
                            child: Center(
                              child: Text(
                                item.toString(),
                                style: TextStyle(
                                    color: defaultTheme.secondaryTextColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ),
              sectionHeading("Time Format"),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: Constants.TimeFormat.values.map((item) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          cgp.changeTimeFormat(item);
                        },
                        child: Card(
                          color: cgp.timeFormat == item
                              ? defaultTheme.enabledColor
                              : defaultTheme.disabledColor,
                          child: Center(
                            child: Text(
                              item.formatName,
                              style: TextStyle(
                                  color: defaultTheme.secondaryTextColor),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              sectionHeading("Time Control"),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: TimeStandard.values.take(4).map((item) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          cgp.changeTimeStandard(item);
                        },
                        child: Card(
                          color: cgp.timeStandard == item
                              ? defaultTheme.enabledColor
                              : defaultTheme.disabledColor,
                          child: Center(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  color: defaultTheme.secondaryTextColor),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  // Main and increment time stuff
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: timeSelectionDropdown(
                          Constants.timeStandardMainTimeAlt[cgp.timeStandard]!,
                          cgp.mainTimeSeconds,
                          cgp.changeMainTimeSeconds,
                          "Main",
                        ),
                      ),
                      if (cgp.timeFormat == Constants.TimeFormat.fischer) ...[
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: timeSelectionDropdown(
                            Constants
                                .timeStandardIncrementAlt[cgp.timeStandard]!,
                            cgp.incrementSeconds,
                            cgp.changeIncrementSeconds,
                            "Increment",
                          ),
                        ),
                      ]
                    ],
                  ),
                  // Byo yomi stuff
                  const SizedBox(
                    height: 10,
                  ),

                  if (cgp.timeFormat == Constants.TimeFormat.byoYomi)
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: timeSelectionTextField(
                                "Byo-Yomis", cgp.byoYomiCountController)),
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: timeSelectionDropdown(
                              Constants.timeStandardByoYomiTimeAlt[
                                  cgp.timeStandard]!,
                              cgp.byoYomiSeconds,
                              cgp.changeByoYomiSeconds,
                              "Byo-Yomi Time"),
                        ),
                      ],
                    )
                ],
              ),
              const Spacer(),
              BadukButton(
                onPressed: () async {
                  final signalRProvider = context.read<SignalRProvider>();
                  final signalRBloc =
                      ChangeNotifierProvider.value(value: signalRProvider);
                  final authBloc = context.read<AuthProvider>();
                  final token = context.read<AuthProvider>().token;
                  final res = await context
                      .read<CreateGameProvider>()
                      .createGame(token!);

                  res.fold((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message),
                      ),
                    );
                  }, (game) {
                    final signalRProvider = context.read<SignalRProvider>();

                    final authBloc = context.read<AuthProvider>();
                    var stage = StageType.BeforeStart;
                    // final gameStatebloc = context.read<GameStateBloc>();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => GameWidget(
                            game: game,
                            joinMessage: null,
                          ),
                        ));
                  });
                },
                child: const Text("Create"),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget stoneSelectionButton(BuildContext context, StoneSelectionType type) {
    final cgp = context.read<CreateGameProvider>();

    return GestureDetector(
      onTap: () {
        cgp.changeStoneType(type);
      },
      child:
          // SelectionBadge(
          //   selected: mStoneType == type,
          // child:

          Card(
        color: cgp.mStoneType == type
            ? defaultTheme.enabledColor
            : Colors.transparent,
        child: Center(
          child: SizedBox(
            height: 30,
            width: 30,
            child: StoneSelectionWidget(
              type,
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionHeading(String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        heading,
        style: const TextStyle(color: Colors.white70, fontSize: 22),
      ),
    );
  }

  Widget timeSelectionDropdown(List<Duration> altTimes, Duration selectedTime,
      void Function(Duration) onTap, String label) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      // dropdown below..
      child: InputDecorator(
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            dropdownColor: Colors.white,
            value: selectedTime,
            items: altTimes.map((entry) {
              return DropdownMenuItem(
                value: entry,
                child: Container(
                  child: Text(
                    entry.durationRepr(),
                    style: TextStyle(color: defaultTheme.mainHighlightColor),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              onTap(value);
            },
            isExpanded: true,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),

            iconSize: 32,
            // underline: SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget timeSelectionTextField(
      String label, TextEditingController controller) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      // dropdown below..
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          label: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
