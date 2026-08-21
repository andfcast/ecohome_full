import { useState } from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  TextField,
  Typography,
  Alert,
  CircularProgress
} from '@mui/material';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import { loginUser } from '../services/auth.service';

export default function Login({ onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const data = await loginUser(email, password);
      // Asumimos que el backend retorna el token en data.token o data.data.token
      const token = data.token || data.data?.token;

      if (token) {
        // Guardamos el token en localStorage para persistencia
        localStorage.setItem('token', token);
        localStorage.setItem('userEmail', email);
        localStorage.setItem('userRole', data.user.role || '');
        console.log(data.user.role);
        // Notificamos al componente padre
        onLoginSuccess({ token, email, role });
      } else {
        setError('Respuesta del servidor no válida (Token no recibido).');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="xs" sx={{ mt: 8 }}>
      <Card elevation={4} sx={{ borderRadius: 3, p: 2 }}>
        <CardContent>
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              mb: 3
            }}
          >
            <Box
              sx={{
                bgcolor: 'primary.main',
                color: 'white',
                p: 1.5,
                borderRadius: '50%',
                mb: 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}
            >
              <LockOutlinedIcon />
            </Box>
            <Typography component="h1" variant="h5" fontWeight="bold" color="primary">
              EcoHome Store
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Acceso al Chat Corporativo
            </Typography>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={handleSubmit} noValidate>
            <TextField
              margin="normal"
              required
              fullWidth
              id="email"
              label="Correo Electrónico"
              name="email"
              autoComplete="email"
              autoFocus
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Contraseña"
              type="password"
              id="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{ mt: 3, mb: 2, py: 1.2, borderRadius: 2 }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Ingresar'}
            </Button>
          </Box>
        </CardContent>
      </Card>
    </Container>
  );
}