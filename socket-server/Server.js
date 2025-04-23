    const express = require('express');
    const http = require('http');
    const socketIo = require('socket.io');

    const app = express();
    const server = http.createServer(app);
    const io = socketIo(server, {
        cors: {
            origin: "*", // Update with Flutter app's URL if needed
            methods: ["GET", "POST"]
        }
    });

    let games = {}; // To hold active game states

    io.on('connection', (socket) => {
        console.log(`✅ User connected: ${socket.id}`);

        socket.on('joinGame', (gameId) => {
            socket.join(gameId);
            console.log(`🎮 User ${socket.id} joined game: ${gameId}`);
        });

        socket.on('makeMove', (gameId, move) => {
            console.log(`📤 Received move from ${socket.id} in game ${gameId}:`, move);
            io.to(gameId).emit('moveMade', move);
            console.log(`📢 Emitted move to game ${gameId}`);
        });

        socket.on('disconnect', () => {
            console.log(`❌ User disconnected: ${socket.id}`);
        });
    });

    server.listen(3000, () => {
        console.log('🚀 Server running on http://localhost:3000');
    });
