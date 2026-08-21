const jwt = require('jsonwebtoken');
const db = require('../config/database');

const getUserStats = async (req, res) => {
  try {
    // req.user.id viene inyectado por el middleware authJWT
    const userId = req.user?.id;

    if (!userId) {
      return res.status(400).json({ message: 'Usuario no identificado en el token.' });
    }

    // Consulta que trae los datos del usuario y realiza el COUNT de sus productos
    const query = `
      SELECT 
        u.id,
        u.name,
        u.email,
        u.role,
        COUNT(p.id)::INT AS total_products
      FROM users u
      LEFT JOIN products p ON u.id = p.created_by
      WHERE u.id = $1
      GROUP BY u.id, u.name, u.email, u.role;
    `;

    const { rows } = await db.query(query, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }

    const userStats = rows[0];

    return res.status(200).json({
      id: userStats.id,
      name: userStats.name,
      email: userStats.email,
      role: userStats.role,
      totalProducts: userStats.total_products, // Contador dinámico (N)
    });
  } catch (error) {
    console.error('Error al obtener estadísticas del usuario:', error);
    return res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  getUserStats,
};