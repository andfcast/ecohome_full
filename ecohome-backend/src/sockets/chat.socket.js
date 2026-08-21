const jwt = require('jsonwebtoken');
const db = require('../config/database');

module.exports = (io) => {
  // Middleware de autenticación JWT para Sockets
  io.use((socket, next) => {
    // Extraer token desde auth o headers
    const rawToken = socket.handshake.auth?.token || socket.handshake.headers?.authorization;

    if (!rawToken) {
      console.error('❌ [Socket Auth] No se recibió ningún token');
      return next(new Error('Authentication error: Token no proporcionado'));
    }

    try {
      // Remover "Bearer " sin importar cuántas veces aparezca o si hay espacios extra
      const cleanToken = rawToken.replace(/^Bearer\s+/i, '').replace(/^Bearer\s+/i, '').trim();

      // Clave secreta (debe coincidir exactamente con la que usas en auth.controller.js)
      const secret = process.env.JWT_SECRET || 'secreto_super_seguro_ecohome_2026';

      const decoded = jwt.verify(cleanToken, secret);
      socket.user = decoded; // Guardar usuario decodificado en la instancia del socket
      next();
    } catch (err) {
      console.error('❌ [Socket Auth Error Detallado]:', err.message);
      return next(new Error(`Authentication error: Token inválido (${err.message})`));
    }
  });

  // Manejo de eventos
  io.on('connection', (socket) => {
    console.log(`🟢 [Socket.IO] Usuario conectado: ${socket.user.email} (ID: ${socket.user.id})`);

    socket.on('new-message', async (data) => {
      try {
        const userId = socket.user.id || socket.user.userId;
        const text = data.content || data.text;

        // 1. Guardar en Base de Datos (Persistencia)
        const insertQuery = `
          INSERT INTO messages (user_id, text, created_at)
          VALUES ($1, $2, NOW())
          RETURNING id, created_at;
        `;
        const result = await db.query(insertQuery, [userId, text]);
        const savedMsg = result.rows[0];

        // 2. Construir payload
        const messagePayload = {
          id: savedMsg.id,
          user_id: userId,
          user_email: socket.user.email,
          text: text,
          created_at: savedMsg.created_at
        };

        // 3. Broadcast a todos los clientes
        io.emit('receive-message', messagePayload);
        console.log(`💾 Mensaje #${savedMsg.id} guardado en BD y transmitido`);

      } catch (error) {
        console.error('❌ Error guardando mensaje:', error.message);
        socket.emit('error-message', { message: 'Error al procesar mensaje' });
      }
    });

    socket.on('disconnect', () => {
      console.log(`🔴 [Socket.IO] Desconectado: ${socket.user.email}`);
    });
  });
};