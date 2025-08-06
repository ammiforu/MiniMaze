import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ScoreModel extends ChangeNotifier {
  List<Map<String, dynamic>> _scores = [];
  final SharedPreferences _prefs;
  
  List<Map<String, dynamic>> get scores => List.unmodifiable(_scores);
  
  ScoreModel(this._prefs) {
    _loadScores();
  }
  
  void _loadScores() {
    final savedScores = _prefs.getString(Constants.scoresKey);
    if (savedScores != null) {
      try {
        final List<dynamic> decoded = json.decode(savedScores);
        _scores = decoded.map((score) => Map<String, dynamic>.from(score)).toList();
      } catch (e) {
        _scores = [];
      }
    }
  }
  
  void saveScore(String playerName, Duration time, {bool isDailyChallenge = false}) {
    final newScore = {
      'name': playerName,
      'time': time.inMilliseconds,
      'date': DateTime.now().toIso8601String(),
      'isDailyChallenge': isDailyChallenge,
    };
    
    _scores.add(newScore);
    _scores.sort((a, b) => a['time'].compareTo(b['time']));
    
    // Keep only top 10 scores
    if (_scores.length > 10) {
      _scores = _scores.sublist(0, 10);
    }
    
    _prefs.setString(Constants.scoresKey, json.encode(_scores));
    notifyListeners();
  }
  
  void clearScores() {
    _scores = [];
    _prefs.remove(Constants.scoresKey);
    notifyListeners();
  }
  
  Duration getBestTime() {
    if (_scores.isEmpty) {
      return const Duration(seconds: 999);
    }
    return Duration(milliseconds: _scores.first['time']);
  }
  
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$minutes:$seconds.$milliseconds";
  }
  
  bool isDailyChallengeCompleted() {
    final saved = _prefs.getBool(Constants.dailyChallengeKey) ?? false;
    return saved;
  }
  
  void markDailyChallengeCompleted() {
    _prefs.setBool(Constants.dailyChallengeKey, true);
    notifyListeners();
  }
  
  void resetDailyChallenge() {
    _prefs.remove(Constants.dailyChallengeKey);
    notifyListeners();
  }
  
  String getLastDailyChallengeDate() {
    return _prefs.getString(Constants.lastDailyChallengeDateKey) ?? '';
  }
  
  void setLastDailyChallengeDate(String date) {
    _prefs.setString(Constants.lastDailyChallengeDateKey, date);
    notifyListeners();
  }
  
  bool isNewDay() {
    final lastDate = getLastDailyChallengeDate();
    if (lastDate.isEmpty) return true;
    
    final lastDateTime = DateTime.parse(lastDate);
    final now = DateTime.now();
    
    return lastDateTime.year != now.year || 
           lastDateTime.month != now.month || 
           lastDateTime.day != now.day;
  }
}
