import 'package:flutter/material.dart';
import '../models/country.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final List<Country> _favorites = [];
  final List<HistoryItem> _history = [];

  List<Country> get favorites => List.unmodifiable(_favorites);
  List<HistoryItem> get history => List.unmodifiable(_history);

  bool isFavorite(Country country) {
    return _favorites.any((c) => c.name == country.name);
  }

  void toggleFavorite(Country country) {
    final index = _favorites.indexWhere((c) => c.name == country.name);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(country);
    }
    notifyListeners();
  }

  void addToHistory(Country country) {
    // Avoid immediate duplicate consecutive history entry if viewed repeatedly
    if (_history.isNotEmpty && _history.first.country.name == country.name) {
      // update timestamp
      _history[0] = HistoryItem(country: country, timestamp: DateTime.now());
    } else {
      _history.insert(0, HistoryItem(country: country, timestamp: DateTime.now()));
    }
    notifyListeners();
  }

  /// Hard Delete single history item
  void deleteHistoryItem(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      notifyListeners();
    }
  }

  /// Hard Delete ALL history items
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
