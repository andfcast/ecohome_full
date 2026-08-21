const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// Endpoints de autenticación
router.post('/signup', authController.signup);
router.post('/login', authController.login);

// IMPORTANTE: Exportar el router
module.exports = router;