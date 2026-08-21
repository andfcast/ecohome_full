require('dotenv').config();
const http = require('http'); // 1. Importar módulo HTTP nativo
const { Server } = require('socket.io'); // 2. Importar Server de socket.io
const jwt = require('jsonwebtoken');
const registerChatSocket = require('./src/sockets/chat.socket');
const app = require('./src/app');

const PORT = process.env.PORT || 3000;

// 3. Crear el servidor HTTP envolviendo la app de Express
const server = http.createServer(app);

// 4. Inicializar Socket.IO sobre el servidor HTTP
const io = new Server(server, {
  cors: {
    origin: '*', // Permite conexiones desde el frontend en React
    methods: ['GET', 'POST']
  }
});

registerChatSocket(io); // 5. Registrar la lógica de chat con Socket.IO

// 6. Cambiar app.listen por server.listen
server.listen(PORT, () => {
  console.log(`🚀 Servidor de EcoHome Store corriendo con WebSockets en http://localhost:${PORT}`);
});