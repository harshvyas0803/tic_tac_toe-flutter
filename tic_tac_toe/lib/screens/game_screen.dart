import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SocketService socketService;
  List<List<String?>> board = List.generate(3, (_) => List.filled(3, null));
  String mySymbol = '';
  String currentTurn = 'X'; // Default turn

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    socketService.connect();
    socketService.joinGame(widget.gameId);

    // Get assigned player symbol (X or O)
    socketService.listenForSymbol((symbol) {
      setState(() {
        mySymbol = symbol;
      });
    });

    // Update turn from server
    socketService.listenForTurn((turn) {
      setState(() {
        currentTurn = turn;
      });
    });

    // Listen for moves from other players
    socketService.listenForMoves((move) {
      setState(() {
        board[move['row']][move['col']] = move['player'];
      });
    });
  }

  void makeMove(int row, int col) {
    if (board[row][col] != null || mySymbol != currentTurn) return;

    setState(() {
      board[row][col] = mySymbol;
    });

    socketService.makeMove(widget.gameId, {
      'row': row,
      'col': col,
      'player': mySymbol,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mySymbol.isEmpty
                  ? 'Waiting to join...'
                  : (currentTurn == mySymbol
                      ? 'Your Turn ($mySymbol)'
                      : 'Opponent\'s Turn'),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ...List.generate(3, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (col) {
                  String? value = board[row][col];
                  return GestureDetector(
                    onTap: () => makeMove(row, col),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(6),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:
                            value != null
                                ? [
                                    BoxShadow(
                                      color: value == 'X'
                                          ? Colors.cyanAccent.withOpacity(0.6)
                                          : Colors.pinkAccent.withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : [],
                      ),
                      child: Center(
                        child: Text(
                          value ?? '',
                          style: TextStyle(
                            fontSize: 40,
                            color: value == 'X'
                                ? Colors.cyanAccent
                                : Colors.pinkAccent,
                            fontWeight: FontWeight.bold,
                            shadows: value != null
                                ? [
                                    Shadow(
                                      color: value == 'X'
                                          ? Colors.cyanAccent
                                          : Colors.pinkAccent,
                                      blurRadius: 20,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }
}
