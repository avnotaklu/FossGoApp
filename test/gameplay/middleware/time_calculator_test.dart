import 'package:go/models/variant_type.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:test/test.dart';

void main() {
  group('TimeCalculatorTest', () {
    late List<PlayerTimeSnapshot> playerTimeSnapshots;
    late TimeControl timeControl;
    late DateTime curTime;
    late int turn;

    StoneType curTurn() => StoneType.values[turn % 2];
    String curTimeString() => curTime.toIso8601String();

    final _1980Jan1_1_30PM = DateTime(1980, 1, 1, 13, 30, 0);

    void setup() {
      turn = 0;
      curTime = _1980Jan1_1_30PM;
      timeControl = TimeControl(
        mainTimeSeconds: 10,
        incrementSeconds: null,
        byoYomiTime: ByoYomiTime(byoYomis: 3, byoYomiSeconds: 3),
        timeStandard: TimeStandard.blitz,
      );

      playerTimeSnapshots = [
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: true,
        ),
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: false,
        ),
      ];
    }

    void setupIncrement() {
      turn = 0;
      curTime = _1980Jan1_1_30PM;
      timeControl = TimeControl(
        mainTimeSeconds: 10,
        incrementSeconds: 3,
        byoYomiTime: null,
        timeStandard: TimeStandard.blitz,
      );

      playerTimeSnapshots = [
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: true,
        ),
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: false,
        ),
      ];
    }

    void setupSimple() {
      turn = 0;
      curTime = _1980Jan1_1_30PM;
      timeControl = TimeControl(
        mainTimeSeconds: 10,
        incrementSeconds: 0,
        byoYomiTime: null,
        timeStandard: TimeStandard.blitz,
      );

      playerTimeSnapshots = [
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: true,
        ),
        PlayerTimeSnapshot(
          snapshotTimestamp: curTime,
          mainTimeMilliseconds: timeControl.mainTimeSeconds * 1000,
          byoYomisLeft: timeControl.byoYomiTime?.byoYomis ?? 0,
          byoYomiActive: false,
          timeActive: false,
        ),
      ];
    }

    test('TestByoYomi', () {
      final timeCalculator = TimeCalculator();

      setup();

      List<PlayerTimeSnapshot> recalc() {
        final result = timeCalculator.recalculateTurnPlayerTimeSnapshots(
          curTurn(),
          playerTimeSnapshots,
          timeControl,
          curTime,
        );
        playerTimeSnapshots = result;
        return result;
      }

      // Simulate moves
      curTime = curTime.add(const Duration(seconds: 8));
      turn++;
      var result = recalc();

      expect(result[1].mainTimeMilliseconds, 10 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      turn++;
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 3);

      curTime = curTime.add(const Duration(seconds: 3));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 2);

      curTime = curTime.add(const Duration(seconds: 3));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 1);

      curTime = curTime.add(const Duration(seconds: 3));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 0);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 0);
    });

    test('TestByoYomiTurnChangeHalfway', () {
      final timeCalculator = TimeCalculator();

      setup();

      List<PlayerTimeSnapshot> recalc() {
        final result = timeCalculator.recalculateTurnPlayerTimeSnapshots(
          curTurn(),
          playerTimeSnapshots,
          timeControl,
          curTime,
        );
        playerTimeSnapshots = result;
        return result;
      }

      // Simulate moves
      curTime = curTime.add(const Duration(seconds: 8));
      turn++;
      var result = recalc();

      expect(result[1].mainTimeMilliseconds, 10 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      turn++;
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 3);

      curTime = curTime.add(const Duration(seconds: 3));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].byoYomisLeft, 2);

      curTime = curTime.add(const Duration(seconds: 2));
      turn += 1;
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[1].timeActive, isTrue);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);
      expect(result[0].byoYomiActive, isTrue);
      expect(result[0].timeActive, isFalse);
      expect(result[0].byoYomisLeft, 2);
    });

    test('TestIncrement', () {
      final timeCalculator = TimeCalculator();

      setupIncrement();

      List<PlayerTimeSnapshot> recalc() {
        final result = timeCalculator.recalculateTurnPlayerTimeSnapshots(
          curTurn(),
          playerTimeSnapshots,
          timeControl,
          curTime,
        );
        playerTimeSnapshots = result;
        return result;
      }

      curTime = curTime.add(const Duration(seconds: 8));
      turn++;
      var result = recalc();

      expect(result[1].mainTimeMilliseconds, 10 * 1000);
      expect(result[0].mainTimeMilliseconds, 5 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      turn++;
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 11 * 1000);
      expect(result[0].mainTimeMilliseconds, 5 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 11 * 1000);
      expect(result[0].mainTimeMilliseconds, 3 * 1000);

      curTime = curTime.add(const Duration(seconds: 3));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 11 * 1000);
      expect(result[0].mainTimeMilliseconds, 0);
    });

    test('TestSimple', () {
      final timeCalculator = TimeCalculator();

      setupSimple();

      List<PlayerTimeSnapshot> recalc() {
        final result = timeCalculator.recalculateTurnPlayerTimeSnapshots(
          curTurn(),
          playerTimeSnapshots,
          timeControl,
          curTime,
        );
        playerTimeSnapshots = result;
        return result;
      }

      curTime = curTime.add(const Duration(seconds: 8));
      turn++;
      var result = recalc();

      expect(result[1].mainTimeMilliseconds, 10 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      turn++;
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 2 * 1000);

      curTime = curTime.add(const Duration(seconds: 2));
      result = recalc();

      expect(result[1].mainTimeMilliseconds, 8 * 1000);
      expect(result[0].mainTimeMilliseconds, 0 * 1000);
    });
  });
}
