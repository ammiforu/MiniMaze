import 'dart:async';
import 'package:flutter/material.dart';
import '../models/maze_model.dart';
import '../models/player_model.dart';
import '../models/score_model.dart';
import '../utils/constants.dart';

class GameEngine with ChangeNotifier {
  final MazeModel _mazeModel;
  final PlayerModel _playerModel;
  final ScoreModel _scoreModel;
  
  Timer? _gameTimer;
  Duration _elapsedTime = Duration.zero;
  bool _isGameActive = false;
  
  GameEngine(this._mazeModel, this._playerModel, this._scoreModel);
  
  Duration get elapsedTime => _elapsedTime;
  bool get isGameActive => _isGameActive;
  
  void startGame({bool isDailyChallenge = false}) {
    _isGameActive = true;
    _elapsedTime = Duration.zero;
    
    _mazeModel.generateMaze(isDailyChallenge: isDailyChallenge);
    _playerModel.startGame();
    
    _startTimer();
    notifyListeners();
  }
  
  void _startTimer() {
    _gameTimer?.cancel();
    
    _gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _elapsedTime += const Duration(milliseconds: 10);
      _playerModel.updateGameTime(_elapsedTime);
      
      // Check if time is up
      if (_elapsedTime >= Constants.gameTimer) {
        endGame(won: false);
      }
    });
  }
  
  void movePlayer(int dx, int dy) {
    if (!_isGameActive) return;
    
    if (_mazeModel.movePlayer(dx, dy)) {
      // Check if player reached the goal
      if (_mazeModel.checkWin()) {
        endGame(won: true);
      }
    }
  }
  
  void endGame({required bool won}) {
    _isGameActive = false;
    _gameTimer?.cancel();
    _gameTimer = null;
    
    _playerModel.endGame(won: won);
    
    if (won) {
      _scoreModel.saveScore(_playerModel.name, _elapsedTime);
      
      // Mark daily challenge as completed if applicable
      if (_scoreModel.isNewDay()) {
        _scoreModel.resetDailyChallenge();
      }
      
      if (_scoreModel.isDailyChallengeCompleted()) {
        _scoreModel.markDailyChallengeCompleted();
      }
    }
    
    notifyListeners();
  }
  
  void restartGame() {
    endGame(won: false);
    startGame();
  }
  
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
  
  // Handle swipe gestures
  void handleSwipe(DragEndDetails details) {
    if (!_isGameActive) return;
    
    final velocity = details.primaryVelocity ?? 0;
    
    if (velocity.abs() < 500) return; // Minimum velocity threshold
    
    if (velocity > 0) {
      // Swiped right
      movePlayer(1, 0);
    } else if (velocity < 0) {
      // Swiped left
      movePlayer(-1, 0);
    }
  }
  
  void handleVerticalSwipe(DragEndDetails details) {
    if (!_isGameActive) return;
    
    final velocity = details.primaryVelocity ?? 0;
    
    if (velocity.abs() < 500) return; // Minimum velocity threshold
    
    if (velocity > 0) {
      // Swiped down
      movePlayer(0, 1);
    } else if (velocity < 0) {
      // Swiped up
      movePlayer(0, -1);
    }
  }
  
  // Handle tap controls
  void handleTap(TapUpDetails details, BuildContext context) {
    if (!_isGameActive) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;
    
    final double cellWidth = size.width / Constants.mazeSize;
    final double cellHeight = size.height / Constants.mazeSize;
    
    final int tappedX = (localPosition.dx / cellWidth).floor();
    final int tappedY = (localPosition.dy / cellHeight).floor();
    
    final int playerX = _mazeModel.playerX;
    final int playerY = _mazeModel.playerY;
    
    // Check if tap is adjacent to player
    final int dx = tappedX - playerX;
    final int dy = tappedY - playerY;
    
    // Only allow adjacent moves (not diagonal)
    if ((dx.abs() == 1 && dy == 0) || (dx == 0 && dy.abs() == 1)) {
      movePlayer(dx, dy);
    }
  }
}
