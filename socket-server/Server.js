const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

let games = {};

io.on('connection', (socket) => {
    console.log(`✅ User connected: ${socket.id}`);

    socket.on('joinGame', (data) => {
        const { gameId, isCreator } = data;
        socket.join(gameId);
        console.log(`🎮 User ${socket.id} joined game: ${gameId}`);

        if (!games[gameId]) {
            games[gameId] = {
                players: [],
                board: Array(3).fill().map(() => Array(3).fill(null)),
                currentTurn: 'X',
                started: false
            };
        }

        if (games[gameId].players.length < 2) {
            games[gameId].players.push(socket.id);
            const symbol = isCreator ? 'X' : 'O';
            socket.emit('playerSymbol', symbol);
            console.log(`Assigned ${symbol} to ${socket.id}`);

            if (games[gameId].players.length === 2) {
                games[gameId].started = true;
                io.to(gameId).emit('gameStarted', { message: 'Game started!' });
                io.to(gameId).emit('turn', games[gameId].currentTurn);
            } else {
                socket.emit('waitingForOpponent', { message: 'Waiting for another player to join...' });
            }
        } else {
            socket.emit('playerSymbol', 'Spectator');
            socket.emit('error', { message: 'Game is full' });
        }
    });

    socket.on('makeMove', (gameId, move) => {
        if (!games[gameId] || !games[gameId].started) return;
        if (games[gameId].players.length !== 2) return;
        console.log(`📤 Received move from ${socket.id} in game ${gameId}:`, move);
        if (games[gameId].board[move.row][move.col] === null && move.player === games[gameId].currentTurn) {
            games[gameId].board[move.row][move.col] = move.player;
            games[gameId].currentTurn = move.player === 'X' ? 'O' : 'X';
            io.to(gameId).emit('moveMade', move);
            io.to(gameId).emit('turn', games[gameId].currentTurn);
        }
    });

    socket.on('gameStatus', (data) => {
        const { gameId, status, winner } = data;
        io.to(gameId).emit('gameStatus', { status, winner });
    });

    socket.on('resetGame', (gameId) => {
        if (games[gameId]) {
            games[gameId].board = Array(3).fill().map(() => Array(3).fill(null));
            games[gameId].currentTurn = 'X';
            games[gameId].started = games[gameId].players.length === 2;
            io.to(gameId).emit('gameStatus', { status: 'reset', winner: '' });
            io.to(gameId).emit('turn', 'X');
        }
    });

    socket.on('disconnect', () => {
        console.log(`❌ User disconnected: ${socket.id}`);
        for (const gameId in games) {
            const index = games[gameId].players.indexOf(socket.id);
            if (index !== -1) {
                games[gameId].players.splice(index, 1);
                games[gameId].started = false;
                io.to(gameId).emit('opponentDisconnected', { message: 'Opponent disconnected. Game paused.' });
                if (games[gameId].players.length === 0) {
                    delete games[gameId];
                }
            }
        }
    });
});

server.listen(3000, () => {
    console.log('🚀 Server running on http://localhost:3000');
});