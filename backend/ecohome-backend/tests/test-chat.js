const { io } = require('socket.io-client');

// Ajusta la URL de tu API REST de backend
const API_URL = 'http://localhost:3000/auth/login'; 

// Datos de dos usuarios existentes en tu BD
const userVentas = {
  email: 'cliente1@ecohome.com', // Reemplaza por un email real de tu BD
  password: 'PasswordSegura123'      // Reemplaza por su contraseña
};

const userLogistica = {
  email: 'cliente2@ecohome.com', // Reemplaza por otro email real de tu BD
  password: 'PasswordSegura123'
};

async function ejecutarPruebaChat() {
  try {
    console.log('1. Autenticando usuario de Ventas...');
    const resVentas = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userVentas)
    });
    const dataVentas = await resVentas.json();
    const tokenVentas = dataVentas.token || dataVentas.data?.token;

    console.log('2. Autenticando usuario de Logística...');
    const resLogistica = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userLogistica)
    });
    const dataLogistica = await resLogistica.json();
    const tokenLogistica = dataLogistica.token || dataLogistica.data?.token;

    if (!tokenVentas || !tokenLogistica) {
      console.error('❌ Error: No se obtuvieron los tokens. Revisa credenciales o la ruta del login.');
      return;
    }

    console.log('✅ Tokens JWT obtenidos exitosamente.');

    // 3. Conectar Cliente 1 (Ventas)
    const socketVentas = io('http://localhost:3000', {
      auth: { token: `Bearer ${tokenVentas}` }
    });

    // 4. Conectar Cliente 2 (Logística)
    const socketLogistica = io('http://localhost:3000', {
      auth: { token: `Bearer ${tokenLogistica}` }
    });

    // Escuchar eventos en Cliente 2 (Logística)
    socketLogistica.on('connect', () => {
      console.log('🟢 Cliente Logística conectado al WebSocket');
    });

    socketLogistica.on('receive-message', (data) => {
      console.log('\n📩 [LOGÍSTICA RECIBIÓ MENSAJE EN TIEMPO REAL]:');
      console.log(data);
      console.log('\n✨ ¡Prueba funcional de broadcast en tiempo real EXITOSA!');
      
      // Cerrar conexiones al terminar la prueba
      socketVentas.disconnect();
      socketLogistica.disconnect();
      process.exit(0);
    });

    // Cuando Ventas se conecte, envía el mensaje
    socketVentas.on('connect', () => {
      console.log('🟢 Cliente Ventas conectado al WebSocket');
      
      setTimeout(() => {
        console.log('\n🚀 Ventas enviando mensaje: "Confirmado stock para orden #1024"...');
        socketVentas.emit('new-message', {
          content: 'Confirmado stock para orden #1024'
        });
      }, 1000);
    });

  } catch (error) {
    console.error('❌ Error durante la prueba:', error.message);
  }
}

ejecutarPruebaChat();