import 'package:flutter/material.dart';

class ProviderClass with ChangeNotifier {

  List favlist = [];

  addToFav(index) {
    favlist.add(index);
    notifyListeners();
  }

  removeFav(index) {
    favlist.remove(index);
    notifyListeners();
  }
}
