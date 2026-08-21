const db = require('../config/database');

// 1. Obtener todos los productos (GET /products)
const getAllProducts = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT p.id, p.name, p.price, p.is_available, p.created_at, p.updated_at, u.name AS creator '
      + 'FROM products p INNER JOIN users u ON p.created_by = u.id ORDER BY p.created_at DESC'
    );
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener productos:', error);
    res.status(500).json({ message: 'Error interno del servidor al consultar el catálogo.' });
  }
};

// 2. Obtener un producto por ID (GET /products/:id)
const getProductById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.query(
      'SELECT p.id, p.name, p.price, p.is_available, p.created_at, p.updated_at, u.name AS creator '
      + ' FROM products p INNER JOIN users u ON p.created_by = u.id WHERE p.id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado.' });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error al obtener el producto:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// 3. Crear un nuevo producto (POST /products) - Requiere Admin
const createProduct = async (req, res) => {
  const { name, price, is_available } = req.body;

  const created_by = req.user?.id;

  if (!created_by) {
    return res.status(400).json({ message: 'No se pudo identificar el usuario creador en el token.' });
  }

  if (!name || price === undefined) {
    return res.status(400).json({ message: 'El nombre y el precio del producto son obligatorios.' });
  }

  try {
    const availability = is_available !== undefined ? is_available : true;

    const result = await db.query(
      `INSERT INTO products (name, price, is_available, created_by) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id, name, price, is_available, created_at, updated_at, created_by`,
      [name, price, availability, created_by]
    );

    res.status(201).json({
      message: 'Producto creado exitosamente.',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Error al crear producto:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// 4. Actualización completa de producto (PUT /products/:id) - Requiere Admin
const updateProduct = async (req, res) => {
  const { id } = req.params;
  const { name, price, is_available } = req.body;

  if (!name || price === undefined || is_available === undefined) {
    return res.status(400).json({ 
      message: 'Todos los campos (name, price, is_available) son requeridos para actualización completa (PUT).' 
    });
  }

  try {
    const result = await db.query(
      `UPDATE products 
       SET name = $1, price = $2, is_available = $3
       WHERE id = $4
       RETURNING id, name, price, is_available, created_at, updated_at`,
      [name, price, is_available, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado para actualizar.' });
    }

    res.status(200).json({
      message: 'Producto actualizado correctamente.',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Error al actualizar producto:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// 5. Actualización parcial de producto (PATCH /products/:id) - Requiere Admin
const patchProduct = async (req, res) => {
  const { id } = req.params;
  const { name, price, is_available } = req.body;

  // Construcción dinámica del query para actualizar solo los campos enviados
  const fields = [];
  const values = [];
  let index = 1;

  if (name !== undefined) {
    fields.push(`name = $${index++}`);
    values.push(name);
  }
  if (price !== undefined) {
    fields.push(`price = $${index++}`);
    values.push(price);
  }
  if (is_available !== undefined) {
    fields.push(`is_available = $${index++}`);
    values.push(is_available);
  }

  if (fields.length === 0) {
    return res.status(400).json({ message: 'Proporcione al menos un campo para actualizar.' });
  }

  values.push(id); // ID siempre va al final para el WHERE

  try {
    const queryText = `
      UPDATE products 
      SET ${fields.join(', ')} 
      WHERE id = $${index} 
      RETURNING id, name, price, is_available, created_at, updated_at
    `;

    const result = await db.query(queryText, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado.' });
    }

    res.status(200).json({
      message: 'Producto modificado parcialmente.',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Error al modificar parcialmente el producto:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// 6. Eliminar producto (DELETE /products/:id) - Requiere Admin
const deleteProduct = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.query(
      'DELETE FROM products WHERE id = $1 RETURNING id, name',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado para eliminar.' });
    }

    res.status(200).json({
      message: 'Producto eliminado del catálogo exitosamente.',
      deletedProduct: result.rows[0]
    });
  } catch (error) {
    console.error('Error al eliminar producto:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  patchProduct,
  deleteProduct
};