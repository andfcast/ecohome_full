const express = require('express');
const router = express.Router();
const { getMessageHistory } = require('../controllers/message.controller');

// GET /messages/history
router.get('/history', getMessageHistory);

module.exports = router;