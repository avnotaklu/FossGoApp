import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/homepage/custom_games_page.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/homepage/create_game_provider.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';

import 'package:go/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.theme.dialogBackgroundColor,
      child: Consumer<CreateGameProvider>(builder: (context, cgp, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading(context, "Color"),
              SizedBox(
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
              sectionHeading(context, "Size"),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: Constants.boardSizes.map((item) {
                      return Expanded(
                        child: SelectionCard(
                          onTap: () => cgp.changeBoardSize(item),
                          selected: cgp.boardSize == item,
                          label: item.toString(),
                        ),
                      );
                    }).toList()),
              ),
              sectionHeading(context, "Time Format"),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: Constants.TimeFormat.values.map((item) {
                    return Expanded(
                      child: SelectionCard(
                        onTap: () {
                          cgp.changeTimeFormat(item);
                        },
                        selected: cgp.timeFormat == item,
                        label: item.formatName,
                      ),
                    );
                  }).toList(),
                ),
              ),
              sectionHeading(context, "Time Control"),
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.08,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: TimeStandard.values.take(2).map((item) {
                        return Expanded(
                          child: SelectionCard(
                            onTap: () {
                              cgp.changeTimeStandard(item);
                            },
                            selected: cgp.timeStandard == item,
                            label: item.name.capitalize(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.08,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: TimeStandard.values.skip(2).map((item) {
                        return Expanded(
                          child: SelectionCard(
                            onTap: () {
                              cgp.changeTimeStandard(item);
                            },
                            selected: cgp.timeStandard == item,
                            label: item.name.capitalize(),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
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
                          context,
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
                            context,
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
                            context,
                            "Byo-Yomis",
                            cgp.byoYomiCountController,
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: timeSelectionDropdown(
                              context,
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
                    // final gameStatebloc = context.read<GameStateBloc>();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => GameWidget(
                            game: game,
                            gameInteractor: LiveGameOracle(
                              api: Api(),
                              authBloc: context.read<AuthProvider>(),
                              signalRbloc: context.read<SignalRProvider>(),
                              joiningData: null,
                            ),
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
      child: Container(
        decoration: BoxDecoration(
          color: cgp.mStoneType == type
              ? context.theme.indicatorColor
              : context.theme.cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            style: BorderStyle.none,
            color: context.theme.disabledColor,
            width: 2,
          ),
        ),
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

  Widget sectionHeading(BuildContext context, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(heading, style: context.textTheme.titleLarge),
    );
  }

  Widget timeSelectionDropdown(BuildContext context, List<Duration> altTimes,
      Duration selectedTime, void Function(Duration) onTap, String label) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
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
            dropdownColor: context.theme.cardColor,
            value: selectedTime,
            items: altTimes.map((entry) {
              return DropdownMenuItem(
                value: entry,
                child: Container(
                  child: Text(
                    entry.durationRepr(),
                    style: context.textTheme.labelSmall,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              onTap(value);
            },
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: context.theme.hintColor,
            ),

            iconSize: 32,
            // underline: SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget timeSelectionTextField(
      BuildContext context, String label, TextEditingController controller) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
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
            style: context.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  // final CreateGameProvider cgp;
  final void Function() onTap;
  final bool selected;
  final String label;

  const SelectionCard({
    required this.onTap,
    required this.selected,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color:
            // cgp.boardSize == item
            selected
                ? context.theme.indicatorColor
                : context.theme.disabledColor,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: selected
                ? context.textTheme.labelSmall
                : context.textTheme.labelSmall?.copyWith(
                    color: context.theme
                        .cardColor, // HACK: card color is always a contrasting color to disabled color
                  ),
          ),
        ),
      ),
    );
  }
}
