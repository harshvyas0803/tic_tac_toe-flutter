import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  late IO.Socket socket;
  final String serverUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.197.113:3000'; // Updated IP

  SocketService() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(5000)
          .build(),
    );
  }

  void connect() {
    socket.connect();

    socket.on('connect', (_) {
      print('✅ Connected to server');
    });

    socket.on('disconnect', (_) {
      print('❌ Disconnected from server');
    });

    socket.on('connect_error', (err) {
      print('⚠️ Connect error: $err');
    });

    socket.on('error', (err) {
      print('🔥 General socket error: $err');
    });

    socket.on('reconnect', (attempt) {
      print('🔄 Reconnecting: Attempt $attempt');
    });

    socket.on('reconnect_error', (err) {
      print('⚠️ Reconnect error: $err');
    });

    socket.on('reconnect_failed', (_) {
      print('⚠️ Reconnection failed');
    });
  }

  void joinGame(String gameId, bool isCreator) {
    socket.emit('joinGame', {'gameId': gameId, 'isCreator': isCreator});
  }

  void makeMove(String gameId, Map<String, dynamic> move) {
    socket.emit('makeMove', [gameId, move]);
  }

  void emitGameStatus(String gameId, String status, String winner) {
    socket.emit('gameStatus', {'gameId': gameId, 'status': status, 'winner': winner});
  }

  void resetGame(String gameId) {
    socket.emit('resetGame', gameId);
  }

  void listenForMoves(Function(Map<String, dynamic>) onMoveMade) {
    socket.on('moveMade', (data) {
      try {
        if (data is Map<String, dynamic>) {
          onMoveMade(data);
        } else if (data is Map) {
          onMoveMade(Map<String, dynamic>.from(data));
        } else {
          print("⚠️ Invalid move data: $data");
        }
      } catch (e) {
        print("❌ Error parsing moveMade data: $e");
      }
    });
  }

  void listenForSymbol(Function(String) onSymbolAssigned) {
    socket.on('playerSymbol', (data) {
      if (data is String) {
        onSymbolAssigned(data);
      } else {
        print("⚠️ Invalid symbol data: $data");
      }
    });
  }

  void listenForTurn(Function(String) onTurnChanged) {
    socket.on('turn', (data) {
      if (data is String) {
        onTurnChanged(data);
      } else {
        print("⚠️ Invalid turn data: $data");
      }
    });
  }

  void listenForGameStatus(Function(String, String) onGameStatus) {
    socket.on('gameStatus', (data) {
      if (data is Map<String, dynamic>) {
        onGameStatus(data['status'], data['winner']);
      } else {
        print("⚠️ Invalid game status data: $data");
      }
    });
  }

  void listenForGameStarted(Function(Map<String, dynamic>) onGameStarted) {
    socket.on('gameStarted', (data) {
      if (data is Map<String, dynamic>) {
        onGameStarted(data);
      } else {
        print("⚠️ Invalid game started data: $data");
      }
    });
  }

  void listenForWaitingOpponent(Function(Map<String, dynamic>) onWaiting) {
    socket.on('waitingForOpponent', (data) {
      if (data is Map<String, dynamic>) {
        onWaiting(data);
      } else {
        print("⚠️ Invalid waiting opponent data: $data");
      }
    });
  }

  void listenForOpponentDisconnected(Function(Map<String, dynamic>) onDisconnected) {
    socket.on('opponentDisconnected', (data) {
      if (data is Map<String, dynamic>) {
        onDisconnected(data);
      } else {
        print("⚠️ Invalid opponent disconnected data: $data");
      }
    });
  }

  void listenForError(Function(Map<String, dynamic>) onError) {
    socket.on('error', (data) {
      if (data is Map<String, dynamic>) {
        onError(data);
      } else {
        print("⚠️ Invalid error data: $data");
      }
    });
  }

  void disconnect() {
    socket.clearListeners();
    socket.disconnect();
    socket.dispose();
  }
}