import { io } from 'socket.io-client';

const SOCKET_URL = import.meta.env.VITE_SOCKET_URL; // URL de tu backend Express

export const createSocketConnection = (token) => {
  const cleanToken = token ? token.replace(/^Bearer\s+/i, '') : '';
  return io(SOCKET_URL, {
    auth: {
      token: `Bearer ${token}`
    },
    transports: ['websocket', 'polling'],
    autoConnect: true
  });
};