import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MazeModel extends ChangeNotifier {
  late List<List<int>> _maze;
  late int _playerX;
  late int _playerY;
  late int _goalX;
  late int _goalY;
  bool _isGenerated = false;
  
  // Maze cell values
  static const int empty = 0;
  static const int wall = 1;
  static const int player = 2;
  static const int goal = 3;
  
  List<List<int>> get maze => _maze;
  int get playerX => _playerX;
  int get playerY => _playerY;
  int get goalX => _goalX;
  int get goalY => _goalY;
  bool get isGenerated => _isGenerated;
  
  MazeModel() {
    _initializeMaze();
  }
  
  void _initializeMaze() {
    _maze = List.generate(Constants.mazeSize, (i) => 
      List.generate(Constants.mazeSize, (j) => empty)
    );
    _isGenerated = false;
    notifyListeners();
  }
  
  void generateMaze({bool isDailyChallenge = false}) {
    _initializeMaze();
    
    // Generate a simple maze using recursive backtracking
    final random = Random(isDailyChallenge ? _getDailySeed() : null);
    
    // Create border walls
    for (int i = 0; i < Constants.mazeSize; i++) {
      _maze[0][i] = wall;
      _maze[Constants.mazeSize - 1][i] = wall;
      _maze[i][0] = wall;
      _maze[i][Constants.mazeSize - 1] = wall;
    }
    
    // Add some random internal walls
    for (int i = 2; i < Constants.mazeSize - 2; i += 2) {
      for (int j = 2; j < Constants.mazeSize - 2; j += 2) {
        _maze[i][j] = wall;
        
        // Create a path in a random direction
        final directions = [
          (0, 2), (2, 0), (0, -2), (-2, 0)
        ];
        directions.shuffle(random);
        
        for (var (dx, dy) in directions) {
          final nx = i + dx;
          final ny = j + dy;
          
          if (nx > 0 && nx < Constants.mazeSize - 1 && 
              ny > 0 && ny < Constants.mazeSize - 1) {
            _maze[i + dx ~/ 2][j + dy ~/ 2] = wall;
            break;
          }
        }
      }
    }
    
    // Ensure there's a path from start to end
    _ensurePath();
    
    // Set player position (top-left corner)
    _playerX = 1;
    _playerY = 1;
    _maze[_playerY][_playerX] = player;
    
    // Set goal position (bottom-right corner)
    _goalX = Constants.mazeSize - 2;
    _goalY = Constants.mazeSize - 2;
    _maze[_goalY][_goalX] = goal;
    
    _isGenerated = true;
    notifyListeners();
  }
  
  void _ensurePath() {
    // Simple path clearing algorithm
    for (int i = 1; i < Constants.mazeSize - 1; i++) {
      if (i % 2 == 1) {
        _maze[i][1] = empty;
        _maze[1][i] = empty;
      }
    }
  }
  
  int _getDailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
  
  bool movePlayer(int dx, int dy) {
    if (!_isGenerated) return false;
    
    final newX = _playerX + dx;
    final newY = _playerY + dy;
    
    // Check boundaries and walls
    if (newX < 0 || newX >= Constants.mazeSize || 
        newY < 0 || newY >= Constants.mazeSize) {
      return false;
    }
    
    if (_maze[newY][newX] == wall) {
      return false;
    }
    
    // Clear old position
    _maze[_playerY][_playerX] = empty;
    
    // Update position
    _playerX = newX;
    _playerY = newY;
    
    // Set new position
    _maze[_playerY][_playerX] = player;
    
    notifyListeners();
    return true;
  }
  
  bool checkWin() {
    return _playerX == _goalX && _playerY == _goalY;
  }
  
  void reset() {
    _initializeMaze();
  }
}
