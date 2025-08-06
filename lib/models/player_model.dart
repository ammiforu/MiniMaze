import 'package:flutter/material.dart';

class PlayerModel extends ChangeNotifier {
  String _name = 'Player';
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  Duration _bestTime = const Duration(seconds: 999);
  Duration _currentGameTime = Duration.zero;
  bool _isPlaying = false;
  bool _hasWon = false;
  
  String get name => _name;
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon => _gamesWon;
  double get winRate => _gamesPlayed > 0 ? _gamesWon / _gamesPlayed : 0.0;
  Duration get bestTime => _bestTime;
  Duration get currentGameTime => _currentGameTime;
  bool get isPlaying => _isPlaying;
  bool get hasWon => _hasWon;
  
  void setName(String name) {
    _name = name;
    notifyListeners();
  }
  
  void startGame() {
    _isPlaying = true;
    _hasWon = false;
    _currentGameTime = Duration.zero;
    notifyListeners();
  }
  
  void endGame({bool won = false}) {
    _isPlaying = false;
    _hasWon = won;
    _gamesPlayed++;
    
    if (won) {
      _gamesWon++;
      if (_currentGameTime < _bestTime) {
        _bestTime = _currentGameTime;
      }
    }
    
    notifyListeners();
  }
  
  void updateGameTime(Duration time) {
    _currentGameTime = time;
    notifyListeners();
  }
  
  void resetStats() {
    _gamesPlayed = 0;
    _gamesWon = 0;
    _bestTime = const Duration(seconds: 999);
    notifyListeners();
  }
  
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$minutes:$seconds.$milliseconds";
  }
}
