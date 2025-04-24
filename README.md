Tic-Tac-Toe Multiplayer Game
Welcome to the Tic-Tac-Toe Multiplayer Game, a Flutter-based application that allows two players to compete in real-time over the internet. Built with a focus on simplicity and fun, this game connects players using a WebSocket server hosted on Render, enabling seamless multiplayer action.
Features

Real-time multiplayer gameplay between two players (X and O).
Create or join a game room with a unique ID.
Visual feedback with confetti animations on winning or tying.
"Play Again" option to reset the game.
Cross-platform support: Play on Android devices, web browsers (Chrome), or emulators.

Prerequisites

Flutter SDK: Ensure Flutter is installed (version 3.19.x or later recommended). Check with flutter doctor.
Node.js: Required for the server (version 14.x or later).
Android Emulator or Physical Device: For testing on Android (e.g., API 21+).
Web Browser: Chrome or Edge for web play.
Render Account: For deploying the server (free tier available).
ngrok (Optional): For local server testing.

Installation
1. Clone the Repository
git clone https://github.com/yourusername/tic-tac-toe.git
cd tic-tac-toe

2. Install Dependencies

Install Flutter dependencies:
flutter pub get


Install Node.js dependencies for the server:
cd server
npm install



3. Set Up the Server

Deploy on Render:
Create a new web service on Render.

Upload the server directory contents (server.js, package.json).

Set the start command to npm start.

Note the deployed URL (e.g., https://tttf-server-2.onrender.com).

Update lib/services/socket_service.dart with the URL:
final String serverUrl = 'https://tttf-server-2.onrender.com';




Run Locally with ngrok (Optional):
Start the server locally:
node server.js


Expose it with ngrok:
ngrok http 3000


Use the ngrok URL in socket_service.dart.




4. Build and Run

On Android:
Connect a device (e.g., 23124RN87I) or start an emulator.

Build and run:
flutter run


Or build a release APK:
flutter build apk --release

Install the APK on your device:
adb install build/app/outputs/flutter-apk/app-release.apk




On Web (Chrome):
Run in Chrome:
flutter run -d chrome





5. Play the Game

First Player: Create a room (note the room ID).
Second Player: Join the same room ID.
Take turns placing X or O on the 3x3 grid.
Win by aligning three symbols, or tie if the board fills up.
Use "Play Again" to reset.

Troubleshooting

Connection Issues:
Ensure the Render server is running (check Render dashboard logs).

Test WebSocket connectivity:
wscat -c wss://tttf-server-2.onrender.com


If using ngrok, verify the URL and local server status.



Performance Lag:
Test on a physical device (e.g., 23124RN87I) instead of an emulator.
Optimize game_screen.dart by batching setState calls.


Build Errors:
Run flutter doctor to diagnose setup issues.
Verify android/app/build.gradle settings (minSdkVersion, targetSdkVersion).



Project Structure

lib/: Flutter app code.
main.dart: Entry point.
services/socket_service.dart: WebSocket client logic.
screens/game_screen.dart: Game UI and logic.


server/: Node.js WebSocket server.
server.js: Server implementation.
package.json: Dependencies.





Acknowledgements

Built with Flutter.
Server powered by Socket.IO.
Hosted on Render.
Confetti effects from confetti package.

Happy gaming!
