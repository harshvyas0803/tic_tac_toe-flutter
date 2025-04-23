import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'package:uuid/uuid.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _joinController = TextEditingController();

  void createRoom() {
    final String roomId = Uuid().v4().substring(0, 6); // Short room ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameId: roomId),
      ),
    );
  }

  void joinRoom() {
    final String roomId = _joinController.text.trim();
    if (roomId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(gameId: roomId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Multiplayer Tic Tac Toe",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: createRoom,
                child: const Text("🎯 Create Room"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _joinController,
                decoration: const InputDecoration(
                  labelText: "Enter Room ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: joinRoom,
                child: const Text("🔗 Join Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
