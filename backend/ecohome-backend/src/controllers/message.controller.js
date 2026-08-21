const db = require('../config/database');

const getMessageHistory = async (req, res) => {
  try {
    const query = `
      SELECT m.id, m.user_id, u.email AS user_email, m.text, m.created_at
      FROM messages m
      JOIN users u ON m.user_id = u.id
      ORDER BY m.created_at DESC
      LIMIT 10;
    `;
    const result = await db.query(query);

    // Los devolvemos en orden cronológico (del más antiguo al más reciente)
    return res.json({
      status: 'success',
      data: result.rows.reverse()
    });
  } catch (error) {
    console.error('Error al obtener historial:', error);
    return res.status(500).json({ status: 'error', message: 'Error interno del servidor' });
  }
};

module.exports = {
  getMessageHistory
};