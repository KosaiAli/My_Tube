import 'package:flutter/material.dart';

class DownloadSingleProvider extends ChangeNotifier {
  int _selectedplaylist = -1;

  get selectedplaylist => _selectedplaylist;
  set selectedplaylist(value) {
    _selectedplaylist = value;
    notifyListeners();
  }
}
