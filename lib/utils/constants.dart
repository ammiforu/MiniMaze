class Constants {
  // Game constants
  static const int mazeSize = 10; // 10x10 grid
  static const Duration gameTimer = Duration(seconds: 60);
  static const double playerSize = 0.8;
  static const double wallThickness = 2.0;
  
  // UI constants
  static const double padding = 16.0;
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 8.0;
  
  // Animation constants
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;
  
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.grey;
  static const Color backgroundColor = Colors.white;
  static const Color wallColor = Colors.black;
  static const Color playerColor = Colors.blue;
  static const Color goalColor = Colors.green;
  static const Color textColor = Colors.black;
  
  // SharedPreferences keys
  static const String scoresKey = 'maze_scores';
  static const String dailyChallengeKey = 'daily_challenge_completed';
  static const String lastDailyChallengeDateKey = 'last_daily_challenge_date';
}
