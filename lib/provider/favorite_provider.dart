//import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
   List<String> _quote = [];
  List<String> get quote => _quote;

    SharedPreferences? _prefs;

  FavoriteProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _quote = _prefs!.getStringList('favorite_quotes') ?? [];
    notifyListeners();
  }

  void _savePrefs() {
    _prefs!.setStringList('favorite_quotes', _quote);
  }

  void toggleFavorite(String quote) {
    final isExist = _quote.contains(quote);
    if (isExist) {
      _quote.remove(quote);
    }else {
      _quote.add(quote);
    }
    _savePrefs();
    notifyListeners();
  }

  bool isExist(String quote){
    final isExist = _quote.contains(quote);
    return isExist;
  }
  void clearFavorite(){
    _quote = [];
    _savePrefs();
    notifyListeners();
  }
}
