import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/score_model.dart';
import '../models/player_model.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreModel = Provider.of<ScoreModel>(context);
    final playerModel = Provider.of<PlayerModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // This would typically fetch updated scores from a server
              // For now, we'll just refresh the UI
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Player Stats Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  children: [
                    Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Games', playerModel.gamesPlayed.toString()),
                        _buildStatCard('Won', playerModel.gamesWon.toString()),
                        _buildStatCard('Best', playerModel.formatTime(playerModel.bestTime)),
                        _buildStatCard('Rate', '${(playerModel.winRate * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Leaderboard List
              Expanded(
                child: scoreModel.scores.isEmpty
                    ? _buildEmptyState()
                    : _buildLeaderboardList(scoreModel),
              ),
              
              // Clear Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showClearDialog(context, scoreModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear All Scores',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No scores yet!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play a game to see your time here!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardList(ScoreModel scoreModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: scoreModel.scores.length,
      itemBuilder: (context, index) {
        final score = scoreModel.scores[index];
        final isPlayerScore = score['name'] == Provider.of<PlayerModel>(context, listen: false).name;
        final isDailyChallenge = score['isDailyChallenge'] ?? false;
        
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: isPlayerScore ? Colors.blue.withOpacity(0.1) : Colors.white,
          child: ListTile(
            leading: _buildRankIcon(index + 1),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    score['name'],
                    style: TextStyle(
                      fontWeight: isPlayerScore ? FontWeight.bold : FontWeight.normal,
                      color: isPlayerScore ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                if (isDailyChallenge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Daily',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(score['date'])),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              scoreModel.formatTime(Duration(milliseconds: score['time'])),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '1',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '2',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 3:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.brown,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '3',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }
  
  void _showClearDialog(BuildContext context, ScoreModel scoreModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Scores'),
        content: const Text('Are you sure you want to clear all scores? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              scoreModel.clearScores();
              Provider.of<PlayerModel>(context, listen: false).resetStats();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
