import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/maze_model.dart';
import '../models/player_model.dart';
import '../models/score_model.dart';
import '../game/game_engine.dart';
import '../utils/constants.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late GameEngine _gameEngine;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeDailyChallenge();
  }
  
  void _initializeDailyChallenge() {
    final scoreModel = Provider.of<ScoreModel>(context, listen: false);
    
    // Check if it's a new day
    if (scoreModel.isNewDay()) {
      scoreModel.resetDailyChallenge();
      scoreModel.setLastDailyChallengeDate(DateTime.now().toIso8601String());
    }
    
    _gameEngine = GameEngine(
      Provider.of<MazeModel>(context, listen: false),
      Provider.of<PlayerModel>(context, listen: false),
      scoreModel,
    );
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _gameEngine.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final scoreModel = Provider.of<ScoreModel>(context);
    final playerModel = Provider.of<PlayerModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Daily Challenge Info Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.orange.shade100,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Daily Challenge',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A unique maze for everyone, every day!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Today: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Challenge Status
                Consumer<ScoreModel>(
                  builder: (context, scoreModel, child) {
                    final isCompleted = scoreModel.isDailyChallengeCompleted();
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      color: isCompleted ? Colors.green.shade100 : Colors.red.shade100,
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : : Icons.hourglass_empty,
                            color: isCompleted ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted ? 'Challenge Completed!' : 'Challenge Not Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Timer and Stats Bar
                Consumer3<MazeModel, PlayerModel, GameEngine>(
                  builder: (context, mazeModel, playerModel, gameEngine, child) {
                    return Container(
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
                    );
                  },
                ),
                
                // Maze Display
                Expanded(
                  child: Consumer3<MazeModel, PlayerModel, GameEngine>(
                    builder: (context, mazeModel, playerModel, gameEngine, child) {
                      return Center(
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
                      );
                    },
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
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showRestartDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Restart Challenge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Challenge'),
        content: const Text('Are you sure you want to restart the daily challenge?'),
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
  
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Daily Challenge'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The Daily Challenge is a special maze that is the same for all players each day.'),
            SizedBox(height: 8),
            Text('• Complete it to earn a special badge on the leaderboard'),
            SizedBox(height: 4),
            Text('• The maze resets at midnight local time'),
            SizedBox(height: 4),
            Text('• Only one completion per day counts'),
            SizedBox(height: 4),
            Text('• Try to beat your best time!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
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
