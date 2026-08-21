const jwt = require('jsonwebtoken');

// Validar que exista un JWT válido
const authJWT = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Acceso denegado. Se requiere token Bearer.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secreto_super_seguro_ecohome_2026');
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Token inválido o expirado.' });
  }
};

// Autorización basada en Roles (RBAC)
const authorizeRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: 'Acceso denegado: Permisos insuficientes para esta acción.' 
      });
    }
    next();
  };
};

module.exports = { authJWT, authorizeRole };