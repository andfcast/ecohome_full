const express = require('express');
const router = express.Router();
const { getUserStats } = require('../controllers/user.controller');
const { authJWT } = require('../middlewares/auth.middleware');

router.get('/me/stats', authJWT, getUserStats);

module.exports = router;