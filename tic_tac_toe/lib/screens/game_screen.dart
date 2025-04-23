import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  final bool isCreator;

  const GameScreen({Key? key, required this.gameId, required this.isCreator}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SocketService socketService;
  late ConfettiController _confettiController;
  List<List<String?>> board = List.generate(3, (_) => List.filled(3, null));
  String mySymbol = '';
  String currentTurn = 'X';
  String? gameStatus;
  bool gameEnded = false;
  bool isConnected = false;
  bool gameStarted = false;
  String? connectionError;
  String? gameMessage;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    socketService = SocketService();
    socketService.connect();

    socketService.socket.on('connect', (_) {
      setState(() {
        isConnected = true;
        connectionError = null;
      });
      socketService.joinGame(widget.gameId, widget.isCreator);
    });

    socketService.socket.on('connect_error', (err) {
      setState(() {
        isConnected = false;
        connectionError = 'Failed to connect to server: $err';
      });
    });

    socketService.socket.on('error', (err) {
      setState(() {
        isConnected = false;
        connectionError = 'Socket error: $err';
      });
    });

    socketService.listenForSymbol((symbol) {
      setState(() {
        mySymbol = symbol;
      });
    });

    socketService.listenForTurn((turn) {
      setState(() {
        currentTurn = turn;
      });
    });

    socketService.listenForMoves((move) {
      setState(() {
        board[move['row']][move['col']] = move['player'];
        checkGameStatus();
      });
    });

    socketService.listenForGameStatus((status, winner) {
      setState(() {
        gameStatus = status;
        gameEnded = status != 'reset';
        gameMessage = null;
        if (status == 'win' && winner == mySymbol) {
          _confettiController.play();
        }
      });
    });

    socketService.listenForGameStarted((data) {
      setState(() {
        gameStarted = true;
        gameMessage = data['message'];
      });
    });

    socketService.listenForWaitingOpponent((data) {
      setState(() {
        gameStarted = false;
        gameMessage = data['message'];
      });
    });

    socketService.listenForOpponentDisconnected((data) {
      setState(() {
        gameStarted = false;
        gameMessage = data['message'];
        gameEnded = true;
      });
    });

    socketService.listenForError((data) {
      setState(() {
        gameMessage = data['message'];
      });
    });
  }

  void makeMove(int row, int col) {
    if (board[row][col] != null ||
        mySymbol != currentTurn ||
        gameEnded ||
        !isConnected ||
        !gameStarted ||
        mySymbol == 'Spectator') {
      return;
    }

    setState(() {
      board[row][col] = mySymbol;
    });

    socketService.makeMove(widget.gameId, {
      'row': row,
      'col': col,
      'player': mySymbol,
    });

    checkGameStatus();
  }

  void checkGameStatus() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != null &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        socketService.emitGameStatus(widget.gameId, 'win', board[i][0]!);
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != null &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        socketService.emitGameStatus(widget.gameId, 'win', board[0][i]!);
        return;
      }
    }

    // Check diagonals
    if (board[0][0] != null &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      socketService.emitGameStatus(widget.gameId, 'win', board[0][0]!);
      return;
    }
    if (board[0][2] != null &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      socketService.emitGameStatus(widget.gameId, 'win', board[0][2]!);
      return;
    }

    // Check for tie
    bool isBoardFull = true;
    for (var row in board) {
      if (row.contains(null)) {
        isBoardFull = false;
        break;
      }
    }
    if (isBoardFull) {
      socketService.emitGameStatus(widget.gameId, 'tie', '');
      return;
    }
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, null));
      gameStatus = null;
      gameEnded = false;
      currentTurn = 'X';
      gameMessage = gameStarted ? null : 'Waiting for another player to join...';
    });
    socketService.resetGame(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe - Room ${widget.gameId}'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isConnected && connectionError != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      connectionError!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (gameMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      gameMessage!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(
                  gameStatus != null
                      ? (gameStatus == 'win'
                          ? (mySymbol == gameStatus ? 'You Win!' : 'You Lose!')
                          : 'Game Tied!')
                      : mySymbol.isEmpty
                          ? (isConnected ? 'Waiting to join...' : 'Connecting to server...')
                          : mySymbol == 'Spectator'
                              ? 'Spectator Mode'
                              : gameStarted
                                  ? (currentTurn == mySymbol
                                      ? 'Your Turn ($mySymbol)'
                                      : 'Opponent\'s Turn ($currentTurn)')
                                  : 'Waiting for opponent...',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: value != null
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
                if (gameEnded) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: const Text('Play Again'),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    socketService.disconnect();
    super.dispose();
    }
}