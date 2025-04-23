import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'dart:math';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _joinController = TextEditingController();

  void createRoom() {
    // Generate a 6-digit numeric room ID
    final String roomId = (Random().nextInt(900000) + 100000).toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameId: roomId, isCreator: true),
      ),
    );
  }

  void joinRoom() {
    final String roomId = _joinController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Room ID to join')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameId: roomId, isCreator: false),
      ),
    );
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text("🎯 Create Room", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _joinController,
                decoration: const InputDecoration(
                  labelText: "Enter Room ID",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: joinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text("🔗 Join Room", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }
}