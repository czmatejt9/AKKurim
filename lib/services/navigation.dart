import 'package:flutter/material.dart';
import 'helpers.dart';

class NavigationService extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  DateTime _selectedDate = Helper().midnight(DateTime.now());
  DateTime get selectedDate => _selectedDate;
  DateTime _focusedDay = Helper().midnight(DateTime.now());
  DateTime get focusedDay => _focusedDay;

  bool _trainingForCurrenDay = false;
  bool get trainingForCurrentDay => _trainingForCurrenDay;
  set trainingForCurrentDay(value) => _trainingForCurrenDay = value;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set selectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  set focusedDay(DateTime date) {
    _focusedDay = date;
    notifyListeners();
  }
}
