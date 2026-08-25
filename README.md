# 🌿 EcoHome Store

EcoHome Store es una plataforma integral para la comercialización de productos ecológicos y sostenibles. El proyecto cuenta con un sistema backend en **Node.js**, un cliente web interactivo en **React**, y una aplicación móvil nativa en **Flutter**, integrando comunicación en tiempo real vía **WebSockets (Socket.IO)** y persistencia relacional con **PostgreSQL**.

---

## 📋 Tabla de Contenidos

- [Requisitos Previos](#-requisitos-previos)
- [Variables de Entorno](#-variables-de-entorno)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Ejecución del Proyecto](#-ejecución-del-proyecto)
  - [Backend (Node.js + Express)](#1-backend-nodejs--express)
  - [Frontend Web (React)](#2-frontend-web-react)
  - [App Móvil (Flutter)](#3-app-móvil-flutter)
- [Credenciales de Prueba](#-credenciales-de-prueba)
- [API Endpoints & Eventos Socket.IO](#-api-endpoints--eventos-socketio)

---

## 🛑 Requisitos Previos

Asegúrate de tener instaladas las siguientes herramientas en tu entorno de desarrollo:

* **Node.js**: `v18.x` o superior
* **npm**: `v9.x` o superior (o `yarn` / `pnpm`)
* **PostgreSQL**: `v14.x` o superior
* **Flutter SDK**: `v3.x` o superior
* **Dart**: Incluido en Flutter SDK
* **Android Studio / Xcode** (Para emuladores o dispositivos físicos)

---

## 🔑 Variables de Entorno

Antes de ejecutar la aplicación, debes configurar los archivos `.env` en cada módulo correspondiente.

### 1. Backend (`/backend/.env`)

```env
# Configuración del Servidor
PORT=5000
NODE_ENV=development

# Configuración de PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_contraseña_postgres
DB_NAME=ecohome_db

# Seguridad JWT
JWT_SECRET=EcoHomeSecretKey_2026_SecureKey
JWT_EXPIRES_IN=24h

# Configuración CORS
CORS_ORIGIN=http://localhost:3000
```

### 2. Frontend Web (`/frontend-web/.env`)

```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_SOCKET_URL=http://localhost:5000
```

### 3. App Móvil (`/mobile/lib/config/environment.dart` o `.env`)

```env
API_BASE_URL=http://10.0.2.2:5000/api   # Para emulador Android
# API_BASE_URL=http://localhost:5000/api # Para simulador iOS
SOCKET_BASE_URL=http://10.0.2.2:5000
```

---

## ⚙️ Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/ecohome-store.git
cd ecohome-store
```

### 2. Base de Datos (PostgreSQL)
Crea la base de datos en PostgreSQL e ejecuta los scripts de migración y datos iniciales (seeds):
```bash
# Crear base de datos en psql o pgAdmin
CREATE DATABASE ecohome_db;

# (Opcional) Ejecutar migraciones si se usa un ORM/Query Builder
cd backend
npm run db:migrate
npm run db:seed
```

---

## 🚀 Ejecución del Proyecto

### 1. Backend (Node.js + Express)
```bash
# Navegar al directorio del backend
cd backend

# Instalar dependencias
npm install

# Iniciar servidor en modo desarrollo
npm run dev

# El servidor iniciará en: http://localhost:5000
```

### 2. Frontend Web (React)
```bash
# Navegar al directorio web
cd frontend-web

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm start

# La aplicación abrirá en: http://localhost:3000
```

### 3. App Móvil (Flutter)
```bash
# Navegar al directorio mobile
cd mobile

# Obtener dependencias de pub.dev
flutter pub get

# Verificar dispositivos/emuladores disponibles
flutter devices

# Ejecutar app en emulador seleccionado
flutter run
```

##4 ?? Generar APK de Android

```bash
cd mobile
flutter pub get

# Para generar la APK de lanzamiento (Release)
flutter build apk --release

# El archivo .apk se encontrar�� en:
# mobile/build/app/outputs/flutter-apk/app-release.apk
```
---

## 👥 Credenciales de Prueba

Puedes usar las siguientes cuentas preconfiguradas para probar la autenticación y los distintos roles de usuario:

| Rol | Correo Electrónico | Contraseña | Permisos / Acceso |
| :--- | :--- | :--- | :--- |
| **Administrador** | `admin@ecohome.com` | `Admin123!` | Gestor de inventario, usuarios, panel web de administración |
| **Cliente** | `cliente@ecohome.com` | `Cliente123!` | Catálogo de productos, carrito de compras, chat de soporte móvil/web |

---

## 📡 API Endpoints & Eventos Socket.IO

### 🌐 Endpoints REST HTTP Base (`/api`)

#### Autenticación (`/api/auth`)
* `POST /api/auth/register` - Registro de nuevos usuarios.
* `POST /api/auth/login` - Iniciar sesión y obtener token JWT.
* `GET /api/auth/profile` - Obtener datos del perfil actual *(requiere JWT)*.

#### Productos (`/api/products`)
* `GET /api/products` - Listar productos ecológicos (con paginación y filtros).
* `GET /api/products/:id` - Obtener detalle de un producto específico.
* `POST /api/products` - Crear nuevo producto *(Solo Admin)*.
* `PUT /api/products/:id` - Actualizar producto *(Solo Admin)*.
* `DELETE /api/products/:id` - Eliminar producto *(Solo Admin)*.

#### Solicitudes y Pedidos (`/api/orders`)
* `POST /api/orders` - Crear una nueva orden de compra.
* `GET /api/orders/user` - Consultar el historial de pedidos del cliente.
* `GET /api/orders` - Obtener todas las órdenes *(Solo Admin)*.
* `PATCH /api/orders/:id/status` - Actualizar el estado del pedido *(Solo Admin)*.

---

### 🔌 Eventos de Socket.IO (Soporte en Tiempo Real)

El servidor de Socket.IO maneja la comunicación de soporte entre clientes y administradores.

#### **Eventos Emitidos por el Cliente (Client -> Server)**

* `join_chat`
  * **Payload:** `{ userId: string, room: string }`
  * **Descripción:** Se conecta al canal de soporte o sala de chat privada.
* `send_message`
  * **Payload:** `{ senderId: string, receiverId: string, message: string, timestamp: string }`
  * **Descripción:** Envía un mensaje de soporte en tiempo real.
* `typing`
  * **Payload:** `{ room: string, isTyping: boolean }`
  * **Descripción:** Notifica que el usuario está escribiendo un mensaje.

#### **Eventos Escuchados por el Cliente (Server -> Client)**

* `receive_message`
  * **Payload:** `{ messageId: string, senderId: string, message: string, timestamp: string }`
  * **Descripción:** Recibe un nuevo mensaje entrante de soporte.
* `user_typing_status`
  * **Payload:** `{ userId: string, isTyping: boolean }`
  * **Descripción:** Recibe indicación en vivo si la contraparte está escribiendo.
* `notification_order_updated`
  * **Payload:** `{ orderId: string, status: string, message: string }`
  * **Descripción:** Emite una notificación en tiempo real cuando cambia el estado de un pedido.
