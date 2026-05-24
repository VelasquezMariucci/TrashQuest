import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _username;
  int _points = 0;
  List<String> _prizes = [];

  String? get username => _username;
  int get points => _points;
  List<String> get prizes => _prizes;

  bool get isLoggedIn => _username != null;

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _points = 0;
    _prizes = [];
    notifyListeners();
  }

  void addPoints(int points) {
    _points += points;
    notifyListeners();
  }

  bool spendPoints(int points) {
    if (_points >= points) {
      _points -= points;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addPrize(String prize) {
    _prizes.add(prize);
    notifyListeners();
  }
}
