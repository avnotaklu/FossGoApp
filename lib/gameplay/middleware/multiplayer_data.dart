import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MultiplayerData extends InheritedWidget {
  final Widget mChild;
  final DatabaseReference database;
  final moveRef;
  final gameRef;
  final firestoreInstance;
  final curUser;

  MultiplayerData({required this.curUser, required this.mChild, required this.database})
      : firestoreInstance = FirebaseFirestore.instance,
        moveRef = database.child('move'),
        gameRef = database.child('game'),
        super(child: mChild);
  get move_ref => moveRef;
  get game_ref => gameRef;

  getCurGameRef(String id) {
    return gameRef.child(id);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static MultiplayerData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MultiplayerData>();
}
