import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService() {
    socket = IO.io(
      'http:// 192.168.0.104:3000', // Replace with your actual server IP
      IO.OptionBuilder()
          .setTransports(['websocket']) // Required for Flutter or Dart VM
          .disableAutoConnect() // We'll manually control connection
          .enableReconnection() // Enable auto-reconnection
          .setReconnectionAttempts(5) // Optional: max retries
          .setReconnectionDelay(1000) // Optional: delay in ms
          .setReconnectionDelayMax(5000) // Optional: max delay between retries
          .build(),
    );
  }

  void connect() {
    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to server');
    });

    socket.onDisconnect((_) {
      print('❌ Disconnected from server');
    });

    socket.onConnectError((err) {
      print('⚠️ Connect error: $err');
    });

    socket.onError((err) {
      print('🔥 General socket error: $err');
    });

    socket.onReconnect((attempt) {
      print('🔄 Reconnecting: Attempt $attempt');
    });

    socket.onReconnectError((err) {
      print('⚠️ Reconnect error: $err');
    });

    // Fixing the error here by accepting dynamic function callback
    socket.onReconnectFailed((_) {
      print('⚠️ Reconnection failed');
    });
  }

  void joinGame(String gameId) {
    socket.emit('joinGame', [gameId]);
  }

  void makeMove(String gameId, Map<String, dynamic> move) {
    socket.emit('makeMove', [gameId, move]);
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

  void disconnect() {
    socket.clearListeners(); // Remove all listeners
    socket.disconnect();
    socket.dispose(); // Dispose socket to free up resources
  }
}
