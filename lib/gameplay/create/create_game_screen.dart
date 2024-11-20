import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/request_send_screen.dart';
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
import 'package:go/services/auth_provider.dart';
import 'package:go/models/game_match.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/widgets/buttons.dart';
import 'package:go/utils/widgets/selection_badge.dart';
import 'package:provider/provider.dart';

class CreateGameScreen extends StatefulWidget {
  // final SignalRProvider signalRProvider;
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  // static const title = 'Grid List';
  Constants.BoardSize boardSize = Constants.boardSizes[0];
  StoneSelectionType mStoneType = StoneSelectionType.auto;

  // Time
  var timeFormat = Constants.TimeFormat.suddenDeath;
  Constants.TimeStandard timeStandard = Constants.TimeStandard.blitz;
  int mainTimeSeconds =
      Constants.timeStandardMainTime[Constants.TimeStandard.blitz]!;
  int incrementSeconds =
      Constants.timeStandardIncrement[Constants.TimeStandard.blitz]!;
  int byoYomis = 3;
  final byoYomiCountController = TextEditingController();
  int byoYomiSeconds =
      Constants.timeStandardByoYomiTime[Constants.TimeStandard.blitz]!;

  @override
  void initState() {
    mStoneType = StoneSelectionType.black;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    child: stoneSelectionButton(StoneSelectionType.black),
                  ),
                  Expanded(
                    child: stoneSelectionButton(StoneSelectionType.white),
                  ),
                  Expanded(
                    child: stoneSelectionButton(StoneSelectionType.auto),
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
                        onTap: () {
                          setState(() {
                            boardSize = item;
                          });
                        },
                        child: Card(
                          color: boardSize == item
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
                        setState(() {
                          timeFormat = item;
                        });
                      },
                      child: Card(
                        color: timeFormat == item
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
                children: Constants.TimeStandard.values.map((item) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          timeStandard = item;

                          mainTimeSeconds =
                              Constants.timeStandardMainTime[item]!;
                          incrementSeconds =
                              Constants.timeStandardIncrement[item]!;
                          byoYomiSeconds =
                              Constants.timeStandardByoYomiTime[item]!;
                        });
                      },
                      child: Card(
                        color: timeStandard == item
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
                          Constants.timeStandardMainTimeAlt[timeStandard]!,
                          mainTimeSeconds, (value) {
                        mainTimeSeconds = value;
                      }, "Main"),
                    ),
                    if (timeFormat == Constants.TimeFormat.fischer) ...[
                      Spacer(),
                      Expanded(
                        flex: 3,
                        child: timeSelectionDropdown(
                            Constants.timeStandardIncrementAlt[timeStandard]!,
                            incrementSeconds, (value) {
                          incrementSeconds = value;
                        }, "Increment"),
                      ),
                    ]
                  ],
                ),
                // Byo yomi stuff
                SizedBox(
                  height: 10,
                ),

                if (timeFormat == Constants.TimeFormat.byoYomi)
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: timeSelectionTextField(
                              "Byo-Yomis", byoYomiCountController)),
                      Spacer(),
                      Expanded(
                        flex: 3,
                        child: timeSelectionDropdown(
                            Constants.timeStandardByoYomiTimeAlt[timeStandard]!,
                            byoYomiSeconds, (value) {
                          byoYomiSeconds = value;
                        }, "Byo-Yomi Time"),
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
                final res =
                    await context.read<CreateGameProvider>().createGame(token!);

                res.fold((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message),
                    ),
                  );
                }, (game) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return MultiProvider(
                        providers: [
                          signalRBloc,
                        ],
                        builder: (context, child) {
                          return RequestSendScreen(game);
                        });
                  }));
                });
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  Widget stoneSelectionButton(StoneSelectionType type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          mStoneType = type;
        });
      },
      child:
          // SelectionBadge(
          //   selected: mStoneType == type,
          // child:

          Card(
        color: mStoneType == type
            ? defaultTheme.enabledColor
            : Colors.transparent,
        child: Center(
          child: SizedBox(
            height: 30,
            width: 30,
            child: StoneSelectionWidget(
              type,
              mStoneType == type,
              // ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionHeading(String heading) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        heading,
        style: TextStyle(color: Colors.white70, fontSize: 22),
      ),
    );
  }

  Widget timeSelectionDropdown(List<int> altTimes, int selectedTime,
      void Function(int) onTap, String label) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            style: TextStyle(fontSize: 14),
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
                    entry.toString(),
                    style: TextStyle(color: defaultTheme.mainHighlightColor),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (value == null) return;
                onTap(value);
              });
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      // dropdown below..
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          label: Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
