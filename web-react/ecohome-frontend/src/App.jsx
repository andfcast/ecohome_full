import { useState, useEffect } from 'react';
import Login from './components/Login';
import Chat from './components/Chat';
import AdminProducts from './components/AdminProducts';

export default function App() {
  const [authData, setAuthData] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem('token');
    const email = localStorage.getItem('userEmail');
    const role = localStorage.getItem('userRole');

    if (token && email && role) {
      setAuthData({ token, email, role });
    }
  }, []);

  const handleLoginSuccess = (data) => {
    setAuthData(data);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    setAuthData(null);
  };

  return (
    <div>
      {!authData ? (
        <Login onLoginSuccess={handleLoginSuccess} />
      ) : authData.role === 'admin' ? (
        <AdminProducts
          token={authData.token}
          currentUserEmail={authData.email}
          onLogout={handleLogout}
        />
      ) :(
        <Chat
          token={authData.token}
          currentUserEmail={authData.email}
          onLogout={handleLogout}
        />
      )}
    </div>
  );
}