const API_URL = import.meta.env.VITE_API_URL;

// Obtener la lista general de productos (con creador)
export const getProducts = async (token) => {
  const response = await fetch(`${API_URL}/products`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || 'Error al obtener los productos');
  }

  return data;
};

// Crear un nuevo producto
export const createProduct = async (productData, token) => {
  const response = await fetch(`${API_URL}/products`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify(productData),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || 'Error al crear el producto');
  }

  return data;
};