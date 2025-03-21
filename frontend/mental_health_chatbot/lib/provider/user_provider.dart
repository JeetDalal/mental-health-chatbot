import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Jeet Dalal';
  String _email = 'jeet@example.com';
  int _points = 0;
  int _streak = 0;

  String get name => _name;
  String get email => _email;
  int get points => _points;
  int get streak => _streak;

  void updatePoints(int points) {
    _points += points;
    notifyListeners();
  }

  void updateStreak() {
    _streak++;
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    notifyListeners();
  }

  void updateUserInfo({String? name, String? email}) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    notifyListeners();
  }
}
