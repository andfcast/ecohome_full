const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');
const productRoutes = require('./routes/product.routes');
const messageRoutes = require('./routes/message.routes');
const userRoutes = require('./routes/user.routes');

const app = express();

// Configuración de CORS para peticiones HTTP
app.use(cors({
  origin: [
    'http://localhost:5173', 
    'http://localhost:5000', 
    'http://127.0.0.1:5173', 
    'http://127.0.0.1:5000',
    'http://localhost:3000'
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Middleware para procesar JSON en el cuerpo de las peticiones
app.use(express.json());

// Registro de rutas de la API
app.use('/auth', authRoutes);
app.use('/products', productRoutes);
app.use('/messages', messageRoutes);
app.use('/users', userRoutes)

// Ruta base de verificación
app.get('/', (req, res) => {
  res.json({ message: 'Bienvenido al API de EcoHome Store' });
});

module.exports = app;