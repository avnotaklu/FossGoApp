import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';

class MultiplayerData extends InheritedWidget {
  final Widget mChild;
  final DatabaseReference database;
  final gamesRef;
  final firestoreInstance;
  User? curUser;
  DatabaseReference? curGame;

  GameDatabaseReferences? curGameReferences;

  MultiplayerData({required this.curUser, required this.mChild, required this.database})
      : firestoreInstance = FirebaseFirestore.instance,
        gamesRef = database.child('game'),
        super(child: mChild);
  DatabaseReference get game_ref => gamesRef;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  set setUser(User user) {
    curUser = user;
  }

  static MultiplayerData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MultiplayerData>();

  createGameDatabaseRefs(String id) {
    curGameReferences = GameDatabaseReferences(game_id: id, gamesRef: gamesRef);
  }
}

class GameDatabaseReferences {
  final String game_id;
  DatabaseReference thisGame;

  GameDatabaseReferences({required this.game_id, required DatabaseReference gamesRef}) : thisGame = gamesRef.child(game_id);

  DatabaseReference get game => thisGame;
  DatabaseReference get moves => thisGame.child("moves");
  DatabaseReference get uid => thisGame.child("uid");
  DatabaseReference get lastTimeAndDuration => thisGame.child("lastTimeAndDuration");
  DatabaseReference get playgroundMap => thisGame.child("playgroundMap");
  DatabaseReference get rows => thisGame.child("rows");
  DatabaseReference get runStatus => thisGame.child("runStatus");
  DatabaseReference get startTime => thisGame.child("startTime");
  DatabaseReference get time => thisGame.child("time");
  DatabaseReference get turn => thisGame.child("turn");
  DatabaseReference get removedClusters => thisGame.child("removedClusters");
  DatabaseReference? myRemovedCluster(context) => removedClusters.child(GameData.of(context)!.getClientPlayer(context).toString());
  DatabaseReference remoteRemovedCluster(context) => removedClusters.child(GameData.of(context)!.getRemotePlayer(context).toString());
}
