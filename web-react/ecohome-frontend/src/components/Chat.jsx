import { useState, useEffect, useRef } from 'react';
import {
  Box, Paper, Typography, TextField, Button,
  List, ListItem, Divider, Container, Avatar,
  AppBar, Toolbar, Chip
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import LogoutIcon from '@mui/icons-material/Logout';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import { createSocketConnection } from '../services/socket';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export default function Chat({ token, currentUserEmail, onLogout }) {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const socketRef = useRef(null);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

useEffect(() => {
  // 1. Cargar historial
  fetch(`${API_URL}/messages/history`, {
    headers: { Authorization: `Bearer ${token}` }
  })
    .then((res) => res.json())
    .then((data) => {
      const list = Array.isArray(data) ? data : data.data || [];
      setMessages(list);
    })
    .catch((err) => console.error('Error al cargar historial:', err));

  // 2. Crear instancia del Socket
  const socket = createSocketConnection(token);
  socketRef.current = socket;

  // 3. Escuchar evento de conexión exitosa
  socket.on('connect', () => {
    console.log('🟢 Conectado exitosamente al servidor Socket.IO');
  });

  socket.on('connect_error', (err) => {
    console.error('❌ Error de conexión en Socket.IO:', err.message);
  });

  // 4. Escuchar mensajes del servidor
  const handleReceiveMessage = (message) => {
    setMessages((prev) => [...prev, message]);
  };

  socket.on('receive-message', handleReceiveMessage);

  // 5. Limpieza al desmontar el componente
  return () => {
    socket.off('receive-message', handleReceiveMessage);
    socket.off('connect');
    socket.off('connect_error');
    socket.disconnect();
  };
}, [token]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = (e) => {
    e.preventDefault();
    const socket = socketRef.current;

    // Diagnósticos de conexión
    if (!socket) {
      console.error('Error: El objeto socket no está inicializado.');
      return;
    }

    if (!socket.connected) {
      console.error('Error: El socket no está conectado. Revisa la autenticación o el servidor.');
      return;
    }

    if (!newMessage.trim()) return;

    const messageText = newMessage.trim();

    // Enviar evento al backend
    socket.emit('new-message', { content: messageText });

    /* 
      NOTA DE DEPURACIÓN:
      Si en el backend usas `socket.broadcast.emit` en lugar de `io.emit`, 
      el servidor NO te devolverá tu propio mensaje. Si es tu caso, 
      descomenta las siguientes líneas para agregarlo localmente de inmediato:

      const localMessage = {
        id: Date.now(),
        user_email: currentUserEmail,
        content: messageText,
        created_at: new Date().toISOString()
      };
      setMessages((prev) => [...prev, localMessage]);
    */

    setNewMessage('');
  };

  return (
    <Box sx={{ flexGrow: 1 }}>
      {/* BARRA SUPERIOR CON USUARIO Y BOTÓN DE LOGOUT */}
      <AppBar position="static" color="primary" elevation={3}>
        <Toolbar sx={{ justifyContent: 'space-between' }}>
          <Typography variant="h6" component="div" fontWeight="bold">
            EcoHome Store - Chat Corporativo
          </Typography>

          {/* SECCIÓN SUPERIOR DERECHA */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Chip
              icon={<AccountCircleIcon style={{ color: '#fff' }} />}
              label={`USUARIO ACTIVO: ${currentUserEmail}`}
              sx={{
                bgcolor: 'rgba(255, 255, 255, 0.2)',
                color: 'white',
                fontWeight: 'bold',
                fontSize: '0.85rem'
              }}
            />

            {/* BOTÓN DE LOGOUT */}
            <Button
              variant="contained"
              color="error"
              size="small"
              startIcon={<LogoutIcon />}
              onClick={onLogout}
              sx={{
                fontWeight: 'bold',
                textTransform: 'none',
                boxShadow: 2
              }}
            >
              Cerrar Sesión
            </Button>
          </Box>
        </Toolbar>
      </AppBar>

      {/* CONTENEDOR DEL CHAT */}
      <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
        <Paper elevation={3} sx={{ p: 3, borderRadius: 3 }}>
          <Box sx={{ mb: 2 }}>
            <Typography variant="subtitle1" fontWeight="bold" color="text.secondary">
              Canal General de Coordinación Interdepartamental
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Ventas • Logística • Soporte
            </Typography>
          </Box>

          <Divider />

          {/* Área de mensajes */}
          <Box
            sx={{
              height: '400px',
              overflowY: 'auto',
              bgcolor: '#f8f9fa',
              p: 2,
              my: 2,
              borderRadius: 2,
              border: '1px solid #e0e0e0'
            }}
          >
            <List>
              {messages.map((msg, index) => {
                const senderEmail = msg.user_email || msg.user || 'Usuario';
                const isMe = senderEmail === currentUserEmail;

                return (
                  <ListItem
                    key={msg.id || index}
                    sx={{
                      flexDirection: 'column',
                      alignItems: isMe ? 'flex-end' : 'flex-start',
                      mb: 1.5,
                      p: 0
                    }}
                  >
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
                      <Avatar
                        sx={{
                          width: 22,
                          height: 22,
                          fontSize: '0.7rem',
                          bgcolor: isMe ? '#1976d2' : '#2e7d32'
                        }}
                      >
                        {senderEmail[0]?.toUpperCase() || 'U'}
                      </Avatar>
                      <Typography variant="caption" fontWeight="bold">
                        {senderEmail}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {msg.created_at
                          ? new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                          : ''}
                      </Typography>
                    </Box>

                    <Paper
                      elevation={1}
                      sx={{
                        p: 1.5,
                        bgcolor: isMe ? '#e3f2fd' : '#ffffff',
                        maxWidth: '75%',
                        borderRadius: isMe ? '16px 16px 2px 16px' : '16px 16px 16px 2px',
                        border: isMe ? 'none' : '1px solid #e0e0e0'
                      }}
                    >
                      <Typography variant="body2" color="text.primary">
                        {msg.content || msg.text || msg.message}
                      </Typography>
                    </Paper>
                  </ListItem>
                );
              })}
              <div ref={messagesEndRef} />
            </List>
          </Box>

          {/* Formulario de envío */}
          <Box component="form" onSubmit={handleSendMessage} sx={{ display: 'flex', gap: 1 }}>
            <TextField
              fullWidth
              size="small"
              placeholder="Escribe un mensaje para el equipo..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
            />
            <Button type="submit" variant="contained" endIcon={<SendIcon />}>
              Enviar
            </Button>
          </Box>
        </Paper>
      </Container>
    </Box>
  );
}