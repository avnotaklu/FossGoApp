import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/gameplay/game_state/oracle/face_to_face_game_oracle.dart';
import 'package:go/modules/gameplay/middleware/local_gameplay_server.dart';
import 'package:go/modules/homepage/custom_games_page.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';
import 'package:go/modules/homepage/create_game_provider.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/ongoing_games.dart';
import 'package:go/services/time_control_dto.dart';

import 'package:go/widgets/buttons.dart';
import 'package:go/widgets/my_text_form_field.dart';
import 'package:go/widgets/stateful_card.dart';
import 'package:provider/provider.dart';

// Future<Either<AppError, Game>> Function(
//     StoneSelectionType stone,
//     TimeControlDto time,
//     Constants.BoardSizeData board) liveGameCreate(String token, Api api) {
//   return (stone, time, boardSize) {
//     return api.createGame(
//         GameCreationDto(
//           rows: boardSize.rows,
//           columns: boardSize.cols,
//           timeControl: time,
//           firstPlayerStone: stone,
//         ),
//         token);
//   };
// }

Future<Either<AppError, Game>> Function(GameCreationParams) liveGameCreate(
    Api api) {
  return (params) {
    return api.createGame(
      GameCreationDto(
        rows: params.board.rows,
        columns: params.board.cols,
        timeControl: params.time,
        firstPlayerStone: params.stone,
      ),
    );
  };
}

Future<Either<AppError, LocalGameplayServer>> Function(GameCreationParams)
    overTheBoardCreate() {
  return (params) {
    var localGame = LocalGameplayServer(
        params.board.rows, params.board.cols, params.time.getTimeControl());
    return Future.value(right(localGame));
  };
}

void showOverTheBoardCreateCustomGameDialog(BuildContext context) async {
  final Completer<GameCreationParams> paramsCompleter = Completer();

  await showDialog(
      context: context,
      builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) =>
                      CreateGameProvider(paramsCompleter, context.read<Api>())
                        ..init(),
                ),
              ],
              builder: (context, child) {
                return const CreateGameScreen();
              }));

  if (paramsCompleter.isCompleted) {
    final params = await paramsCompleter.future;
    final res = await overTheBoardCreate()(params);

    if (context.mounted) {
      res.fold((l) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.message),
            ),
          );
        }
      }, (r) {
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => GameWidget(
                  game: r.getGame(), gameOracle: FaceToFaceGameOracle(r)),
            ));
      });
    }
  } else {
    // NOOOTHING TO DO
  }
}

void showLiveCreateCustomGameDialog(BuildContext context) async {
  final signalRBloc = context.read<SignalRProvider>();
  final authPro = context.read<AuthProvider>();
  final statsRepo = context.read<IStatsRepository>();
  final homepageBloc = context.read<HomepageBloc>();
  var api = context.read<Api>();

  final Completer<GameCreationParams> paramsCompleter = Completer();

  final res = await showDialog(
      context: context,
      builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: signalRBloc,
                ),
                Provider.value(value: statsRepo),
                ChangeNotifierProvider(
                  create: (context) =>
                      CreateGameProvider(paramsCompleter, api)..init(),
                ),
              ],
              builder: (context, child) {
                return const CreateGameScreen();
              }));

  if (paramsCompleter.isCompleted) {
    final params = await paramsCompleter.future;
    final res = await liveGameCreate(api)(params);

    if (context.mounted) {
      res.fold((l) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.message),
            ),
          );
        }
      }, (r) {
        final statRepo = context.read<IStatsRepository>();
        homepageBloc.addNewGame(
          OnGoingGame(
            game: r,
            opposingPlayer: null,
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  LiveGameWidget(r, null, statRepo),
            ));
      });
    }
  } else {
    // NOOOTHING TO DO
  }
}

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  // ignore: use_key_in_widget_constructors
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
      child: Consumer<CreateGameProvider>(builder: (context, cgp, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: min(
            MediaQuery.of(context).size.width * 0.8,
            context.tabletBreakPoint.end,
          ),
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
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: flatDropdown(
                        context,
                        Constants.TimeFormat.values,
                        cgp.timeFormat,
                        cgp.changeTimeFormat,
                        (t) => t.formatName,
                      ),
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
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: flatDropdown(
                      context,
                      TimeStandard.values
                          .take(3)
                          .toList(), // TODO: Add correspondance as well, after proper correspondance support
                      cgp.timeStandard,
                      cgp.changeTimeStandard,
                      (t) => t.standardName,
                    )),
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
                          Constants.timeStandardMainTimesCons(cgp.timeStandard),
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
                            Constants.timeStandardIncrementCons(
                                cgp.timeStandard),
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
                              Constants.timeStandardByoYomiTimesCons(
                                  cgp.timeStandard),
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
                  final res = context.read<CreateGameProvider>().createGame();
                  Navigator.pop(context);
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
              ? context.theme.colorScheme.primary
              : context.theme.colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(
            style: BorderStyle.none,
            color: context.theme.disabledColor,
            width: 2,
          ),
        ),
        child: Center(
          child: LayoutBuilder(builder: (context, cons) {
            return Container(
              padding: const EdgeInsets.all(2),
              height: cons.maxHeight,
              width: cons.maxHeight,
              child: StoneSelectionWidget(
                type,
              ),
            );
          }),
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

  Widget flatDropdown<T>(BuildContext context, List<T> altTimes, T selectedTime,
      void Function(T) onTap, String Function(T) formatter) {
    return MyDropDown<T>(
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
    );
  }

  Widget timeSelectionDropdown(BuildContext context, List<Duration> altTimes,
      Duration selectedTime, void Function(Duration) onTap, String label) {
    return MyDropDown<Duration>(
      items: altTimes,
      selectedItem: selectedTime,
      itemBuilder: (entry) {
        return DropdownMenuItem(
          value: entry,
          child: Container(
            child: Text(
              entry.smallRepr(),
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
    return MyTextField(
      controller: controller,
      hintText: "Byo-Yomis",
      textInputType: const TextInputType.numberWithOptions(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class MyDropDown<T> extends StatelessWidget {
  final String? label;
  final List<T> items;
  final T selectedItem;
  final DropdownMenuItem<T> Function(T) itemBuilder;
  final void Function(T?) onChanged;

  const MyDropDown({
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
              style: context.textTheme.labelLarge,
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
