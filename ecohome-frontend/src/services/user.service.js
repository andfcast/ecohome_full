const API_URL = import.meta.env.VITE_API_URL;

// Obtener estadísticas y contador de productos del usuario autenticado
export const getUserStats = async (token) => {
  const response = await fetch(`${API_URL}/users/me/stats`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || 'Error al obtener estadísticas del usuario');
  }

  return data;
};