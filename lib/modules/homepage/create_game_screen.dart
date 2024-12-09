import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
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
import 'package:go/widgets/stateful_card.dart';
import 'package:provider/provider.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Consumer<CreateGameProvider>(builder: (context, cgp, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
              // sectionHeading(context, "Time Format"),
              // SizedBox(
              //   height: MediaQuery.sizeOf(context).height * 0.08,
              //   child: Row(
              //     mainAxisSize: MainAxisSize.max,
              //     children: Constants.TimeFormat.values.map((item) {
              //       return Expanded(
              //         child: SelectionCard(
              //           onTap: () {
              //             cgp.changeTimeFormat(item);
              //           },
              //           selected: cgp.timeFormat == item,
              //           label: item.formatName,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),

              const SizedBox(
                height: 10,
              ),

              Container(
                height: context.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    sectionHeading(context, "Time Format"),
                    flatDialog(
                      context,
                      Constants.TimeFormat.values,
                      cgp.timeFormat,
                      cgp.changeTimeFormat,
                      (t) => t.formatName,
                    )
                  ],
                ),
              ),

              Container(
                height: context.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    sectionHeading(context, "Time Control"),
                    flatDialog(
                      context,
                      TimeStandard.values,
                      cgp.timeStandard,
                      cgp.changeTimeStandard,
                      (t) => t.standardName,
                    )
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     SizedBox(
              //       height: MediaQuery.sizeOf(context).height * 0.08,
              //       child: Row(
              //         mainAxisSize: MainAxisSize.max,
              //         children: TimeStandard.values.take(2).map((item) {
              //           return Expanded(
              //             child: SelectionCard(
              //               onTap: () {
              //                 cgp.changeTimeStandard(item);
              //               },
              //               selected: cgp.timeStandard == item,
              //               label: item.name.capitalize(),
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //     ),
              //     SizedBox(
              //       height: MediaQuery.sizeOf(context).height * 0.08,
              //       child: Row(
              //         mainAxisSize: MainAxisSize.max,
              //         children: TimeStandard.values.skip(2).map((item) {
              //           return Expanded(
              //             child: SelectionCard(
              //               onTap: () {
              //                 cgp.changeTimeStandard(item);
              //               },
              //               selected: cgp.timeStandard == item,
              //               label: item.name.capitalize(),
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //     )
              //   ],
              // ),
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
              ? context.theme.colorScheme.surfaceContainerHighest
              : context.theme.colorScheme.surfaceContainerLow,
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
      child: Text(heading, style: context.textTheme.labelLarge),
    );
  }

  Widget flatDialog<T>(BuildContext context, List<T> altTimes, T selectedTime,
      void Function(T) onTap, String Function(T) formatter) {
    return SizedBox(
      width: context.width * 0.4,
      child: MyDialog<T>(
        items: altTimes,
        selectedItem: selectedTime,
        itemBuilder: (entry) {
          return DropdownMenuItem(
            value: entry,
            child: Container(
              child: Text(
                formatter(entry),
                style: context.textTheme.labelSmall,
              ),
            ),
          );
        },
        label: null,
        onChanged: (value) {
          if (value == null) return;
          onTap(value);
        },
      ),
    );
  }

  Widget timeSelectionDropdown(BuildContext context, List<Duration> altTimes,
      Duration selectedTime, void Function(Duration) onTap, String label) {
    return MyDialog<Duration>(
      items: altTimes,
      selectedItem: selectedTime,
      itemBuilder: (entry) {
        return DropdownMenuItem(
          value: entry,
          child: Container(
            child: Text(
              entry.durationRepr(),
              style: context.textTheme.labelSmall,
            ),
          ),
        );
      },
      label: label,
      onChanged: (value) {
        if (value == null) return;
        onTap(value);
      },
    );
  }

  Widget timeSelectionTextField(
      BuildContext context, String label, TextEditingController controller) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLow,
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

class MyDialog<T> extends StatelessWidget {
  final String? label;
  final List<T> items;
  final T selectedItem;
  final DropdownMenuItem<T> Function(T) itemBuilder;
  final void Function(T?) onChanged;

  const MyDialog({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    container(Widget child, double height) => Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        );

    // dropdown below..
    final dropdown = Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          // dropdownColor: context.theme.cardColor,
          value: selectedItem,
          items: items.map(
            (entry) {
              return itemBuilder(entry);
            },
          ).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: context.theme.hintColor,
          ),

          iconSize: 24,
          // underline: SizedBox(),
        ),
      ),
    );

    if (label == null) return container(dropdown, 30);

    return container(
        InputDecorator(
          decoration: InputDecoration(
            border: InputBorder.none,
            label: Text(
              label!,
              style: context.textTheme.labelSmall,
            ),
          ),
          child: dropdown,
        ),
        50);
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
      child: StatefulCard(
        state:
            selected ? StatefulCardState.enabled : StatefulCardState.disabled,
        builder: (context) => Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
