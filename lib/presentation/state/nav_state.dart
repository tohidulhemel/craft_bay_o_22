import 'package:flutter/foundation.dart';

// Remembers which bottom tab is selected. Other screens can switch tabs too,
// for example "See All" on Home will jump to the Categories tab.
class NavState extends ChangeNotifier {
  static const int home = 0;
  static const int categories = 1;
  static const int cart = 2;
  static const int wishlist = 3;

  int _index = home;
  int get index => _index;

  void goTo(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }

  void goHome() => goTo(home);

  
}
