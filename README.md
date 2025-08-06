# MiniMaze Rush

A minimalist maze game built with Flutter, featuring randomly generated mazes, daily challenges, and leaderboards.

## Features

- **Randomly Generated Mazes**: Each game presents a new maze to solve
- **Daily Challenge**: A unique maze generated daily that's the same for all players
- **Leaderboard**: Track your best times and compete with others
- **Touch Controls**: Swipe or tap to navigate the maze
- **Timer**: Race against the clock with a 60-second time limit
- **Local Storage**: All scores and progress are saved locally
- **Responsive Design**: Works well on both Android and iOS devices

## Tech Stack

- **Flutter**: Cross-platform framework for building the app
- **Dart**: Programming language
- **Provider**: State management
- **Shared Preferences**: Local storage
- **Intl**: Internationalization and date formatting

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── utils/
│   └── constants.dart        # App-wide constants
├── models/
│   ├── maze_model.dart       # Maze generation and state
│   ├── player_model.dart     # Player stats and progress
│   └── score_model.dart      # Score management and leaderboard
├── game/
│   └── game_engine.dart      # Game logic and timer
└── ui/
    ├── home_screen.dart      # Main menu
    ├── game_screen.dart      # Game play screen
    ├── leaderboard_screen.dart # Leaderboard and stats
    └── daily_challenge_screen.dart # Daily challenge mode
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extension

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd MiniMaze
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Android

1. Enable Android development on your device or set up an emulator
2. Run:
   ```bash
   flutter run
   ```

### Building for iOS

1. Enable iOS development on your device or set up a simulator
2. Run:
   ```bash
   flutter run
   ```

## How to Play

1. **Navigate the Maze**: Use swipe gestures or tap on adjacent cells to move the blue dot
2. **Reach the Goal**: Get to the green square as quickly as possible
3. **Beat the Clock**: You have 60 seconds to complete each maze
4. **Daily Challenge**: Complete the unique daily maze for a special challenge
5. **Improve Your Score**: Try to beat your best time and climb the leaderboard

## Game Controls

- **Swipe**: Swipe in any direction to move the player
- **Tap**: Tap on adjacent cells to move the player
- **Restart**: Use the restart button to start a new game

## Code Features

- **Modular Architecture**: Separate folders for UI, game logic, and models
- **State Management**: Using Provider for reactive UI updates
- **Local Storage**: Using SharedPreferences for persistent data
- **Responsive Design**: Adapts to different screen sizes
- **Clean Code**: Well-commented code following Flutter best practices

## Future Enhancements

- Online leaderboards with Firebase
- Multiple difficulty levels
- Power-ups and special items
- Custom maze themes
- Sound effects and music
- Social sharing features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

If you encounter any issues or have questions, please open an issue on the GitHub repository.
