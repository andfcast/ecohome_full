import React, { useState, useEffect } from 'react';
import { getProducts, createProduct } from '../services/product.service';
import { getUserStats } from '../services/user.service';

export default function AdminProducts({ token, currentUser, onLogout }) {
  const [products, setProducts] = useState([]);
  const [userStats, setUserStats] = useState({
    name: currentUser?.name || currentUser?.email?.split('@')[0] || 'Admin',
    totalProducts: 0,
  });

  // Estado del formulario
  const [newProduct, setNewProduct] = useState({
    name: '',
    price: '',
    is_available: true,
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  useEffect(() => {
    if (token) {
      loadInitialData();
    }
  }, [token]);

  // Carga inicial de datos de productos y métricas
  const loadInitialData = async () => {
    try {
      const [productsData, statsData] = await Promise.all([
        getProducts(token),
        getUserStats(token),
      ]);

      setProducts(productsData);
      setUserStats({
        name: statsData.name || currentUser?.name || 'Admin',
        totalProducts: statsData.totalProducts ?? 0,
      });
    } catch (err) {
      console.error('Error al cargar datos:', err);
      setError(err.message || 'Error al cargar información inicial.');
    }
  };

  // Creación del producto y actualización dinámica
  const handleCreateProduct = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccessMsg('');

    try {
      const payload = {
        name: newProduct.name,
        price: parseFloat(newProduct.price),
        is_available: newProduct.is_available,
      };

      await createProduct(payload, token);

      setSuccessMsg('¡Producto creado con éxito!');

      // Resetear el formulario
      setNewProduct({ name: '', price: '', is_available: true });

      // ACTUALIZACIÓN DINÁMICA DEL CONTADOR: Pasa de N a N+1 en la UI
      setUserStats((prev) => ({
        ...prev,
        totalProducts: prev.totalProducts + 1,
      }));

      // Refrescar listado general de productos para traer el nuevo registro con su trazabilidad
      const updatedProducts = await getProducts(token);
      setProducts(updatedProducts);

    } catch (err) {
      setError(err.message || 'Error al crear el producto.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '1000px', margin: '0 auto', padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      
      {/* ENCABEZADO Y CONTADOR DINÁMICO Nombre (N) */}
      <header style={{
            display: 'flex',
            justify: 'space-between',
            alignItems: 'center',
            padding: '15px 20px',
            backgroundColor: '#1e293b',
            color: '#fff',
            borderRadius: '8px',
            marginBottom: '25px',
            width: '100%',
            boxSizing: 'border-box'
            }}>
            <h2 style={{ margin: 0, fontSize: '1.4rem' }}>EcoHome - Panel de Administración</h2>
            
            <div style={{ display: 'flex', alignItems: 'center', gap: '15px', marginLeft: 'auto' }}>
                {/* FORMATO Nombre (N) */}
                <span style={{
                backgroundColor: '#0f766e',
                color: '#ffffff',
                padding: '8px 16px',
                borderRadius: '20px',
                fontWeight: 'bold',
                fontSize: '0.95rem'
                }}>
                👤 {userStats.name} ({userStats.totalProducts})
                </span>

                <button 
                onClick={onLogout}
                style={{
                    backgroundColor: '#ef4444',
                    color: 'white',
                    border: 'none',
                    padding: '8px 14px',
                    borderRadius: '6px',
                    cursor: 'pointer',
                    fontWeight: 'bold'
                }}
                >
                Cerrar Sesión
                </button>
            </div>
        </header>

      {/* FORMULARIO DE CREACIÓN DE PRODUCTOS */}
      <section style={{
        backgroundColor: '#f8fafc',
        border: '1px solid #e2e8f0',
        padding: '20px',
        borderRadius: '8px',
        marginBottom: '30px'
      }}>
        <h3 style={{ marginTop: 0, color: '#334155' }}>Crear Nuevo Producto</h3>

        {error && <div style={{ color: '#dc2626', marginBottom: '10px' }}>{error}</div>}
        {successMsg && <div style={{ color: '#16a34a', marginBottom: '10px' }}>{successMsg}</div>}

        <form onSubmit={handleCreateProduct} style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
          <input
            type="text"
            placeholder="Nombre del producto"
            value={newProduct.name}
            onChange={(e) => setNewProduct({ ...newProduct, name: e.target.value })}
            required
            style={{ padding: '10px', flex: '2', minWidth: '200px', borderRadius: '4px', border: '1px solid #ccc' }}
          />

          <input
            type="number"
            step="0.01"
            placeholder="Precio ($)"
            value={newProduct.price}
            onChange={(e) => setNewProduct({ ...newProduct, price: e.target.value })}
            required
            style={{ padding: '10px', flex: '1', minWidth: '100px', borderRadius: '4px', border: '1px solid #ccc' }}
          />

          <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
            <input
              type="checkbox"
              checked={newProduct.is_available}
              onChange={(e) => setNewProduct({ ...newProduct, is_available: e.target.checked })}
            />
            Disponible
          </label>

          <button
            type="submit"
            disabled={loading}
            style={{
              backgroundColor: loading ? '#94a3b8' : '#2563eb',
              color: 'white',
              border: 'none',
              padding: '10px 20px',
              borderRadius: '4px',
              cursor: loading ? 'not-allowed' : 'pointer',
              fontWeight: 'bold'
            }}
          >
            {loading ? 'Guardando...' : 'Guardar Producto'}
          </button>
        </form>
      </section>

      {/* LISTADO CON TRAZABILIDAD DEL CREADOR */}
      <section>
        <h3 style={{ color: '#334155' }}>Catálogo General de Productos</h3>
        
        <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '10px', textAlign: 'left' }}>
          <thead>
            <tr style={{ backgroundColor: '#f1f5f9', borderBottom: '2px solid #cbd5e1' }}>
              <th style={{ padding: '12px' }}>ID</th>
              <th style={{ padding: '12px' }}>Producto</th>
              <th style={{ padding: '12px' }}>Precio</th>
              <th style={{ padding: '12px' }}>Estado</th>
              <th style={{ padding: '12px' }}>Creado por (Trazabilidad)</th>
            </tr>
          </thead>
          <tbody>
            {products.length === 0 ? (
              <tr>
                <td colSpan="5" style={{ padding: '20px', textAlign: 'center', color: '#64748b' }}>
                  No hay productos registrados.
                </td>
              </tr>
            ) : (
              products.map((prod) => (
                <tr key={prod.id} style={{ borderBottom: '1px solid #e2e8f0' }}>
                  <td style={{ padding: '12px' }}>#{prod.id}</td>
                  <td style={{ padding: '12px', fontWeight: 'bold' }}>{prod.name}</td>
                  <td style={{ padding: '12px' }}>${parseFloat(prod.price).toFixed(2)}</td>
                  <td style={{ padding: '12px' }}>
                    <span style={{
                      padding: '4px 8px',
                      borderRadius: '12px',
                      fontSize: '0.85rem',
                      backgroundColor: prod.is_available ? '#dcfce7' : '#fee2e2',
                      color: prod.is_available ? '#15803d' : '#b91c1c'
                    }}>
                      {prod.is_available ? 'Disponible' : 'Agotado'}
                    </span>
                  </td>
                  <td style={{ padding: '12px', color: '#475569' }}>
                    🏷️ <strong>{prod.creator || 'Sistema'}</strong>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </section>

    </div>
  );
}