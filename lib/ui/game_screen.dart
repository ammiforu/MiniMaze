import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maze_model.dart';
import '../models/player_model.dart';
import '../models/score_model.dart';
import '../game/game_engine.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine _gameEngine;
  
  @override
  void initState() {
    super.initState();
    _gameEngine = GameEngine(
      Provider.of<MazeModel>(context, listen: false),
      Provider.of<PlayerModel>(context, listen: false),
      Provider.of<ScoreModel>(context, listen: false),
    );
  }
  
  @override
  void dispose() {
    _gameEngine.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniMaze'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              _showRestartDialog();
            },
          ),
        ],
      ),
      body: Consumer3<MazeModel, PlayerModel, GameEngine>(
        builder: (context, mazeModel, playerModel, gameEngine, child) {
          return Column(
            children: [
              // Timer and Stats Bar
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time: ${playerModel.formatTime(gameEngine.elapsedTime)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Best: ${playerModel.formatTime(playerModel.bestTime)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Maze Display
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Constants.wallColor,
                          width: Constants.wallThickness,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onTapUp: (details) {
                          _gameEngine.handleTap(details, context);
                        },
                        onHorizontalDragEnd: (details) {
                          _gameEngine.handleSwipe(details);
                        },
                        onVerticalDragEnd: (details) {
                          _gameEngine.handleVerticalSwipe(details);
                        },
                        child: CustomPaint(
                          painter: MazePainter(mazeModel),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Controls Info
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade50,
                child: const Text(
                  'Swipe or tap adjacent cells to move',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Game'),
        content: const Text('Are you sure you want to restart the current game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _gameEngine.restartGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

class MazePainter extends CustomPainter {
  final MazeModel mazeModel;
  
  MazePainter(this.mazeModel);
  
  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / Constants.mazeSize;
    final cellHeight = size.height / Constants.mazeSize;
    
    // Draw maze cells
    for (int y = 0; y < Constants.mazeSize; y++) {
      for (int x = 0; x < Constants.mazeSize; x++) {
        final cellValue = mazeModel.maze[y][x];
        final paint = Paint();
        
        switch (cellValue) {
          case MazeModel.wall:
            paint.color = Constants.wallColor;
            break;
          case MazeModel.player:
            paint.color = Constants.playerColor;
            break;
          case MazeModel.goal:
            paint.color = Constants.goalColor;
            break;
          default:
            paint.color = Constants.backgroundColor;
        }
        
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );
        
        canvas.drawRect(rect, paint);
        
        // Add subtle grid lines
        if (cellValue == MazeModel.empty) {
          paint.color = Colors.grey.withOpacity(0.2);
          canvas.drawRect(rect, paint);
        }
      }
    }
    
    // Draw player with a more visible dot
    if (mazeModel.isGenerated) {
      final playerX = mazeModel.playerX * cellWidth + cellWidth / 2;
      final playerY = mazeModel.playerY * cellHeight + cellHeight / 2;
      final playerRadius = min(cellWidth, cellHeight) * Constants.playerSize / 2;
      
      final playerPaint = Paint()
        ..color = Constants.playerColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(playerX, playerY), playerRadius, playerPaint);
      
      // Add white border to player for better visibility
      playerPaint.color = Colors.white;
      playerPaint.style = PaintingStyle.stroke;
      playerPaint.strokeWidth = 2;
      canvas.drawCircle(Offset(playerX, playerY), playerRadius - 1, playerPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
