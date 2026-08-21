const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const { authJWT, authorizeRole } = require('../middlewares/auth.middleware');

// Rutas Públicas
router.get('/', productController.getAllProducts);
router.get('/:id', productController.getProductById);

// Rutas Protegidas (Solo Admin)
router.post('/', authJWT, authorizeRole('admin'), productController.createProduct);
router.put('/:id', authJWT, authorizeRole('admin'), productController.updateProduct);
router.patch('/:id', authJWT, authorizeRole('admin'), productController.patchProduct);
router.delete('/:id', authJWT, authorizeRole('admin'), productController.deleteProduct);

module.exports = router;