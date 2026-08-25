#EcoHome Store

EcoHome Store es una plataforma integral para la comercializaci車n de productos ecol車gicos y sostenibles. 
El proyecto cuenta con un sistema backend en **Node.js**, un cliente web interactivo en **React**, y una aplicaci車n m車vil nativa en **Flutter**, 
integrando comunicaci車n en tiempo real v穩a **WebSockets (Socket.IO)** y persistencia relacional con **PostgreSQL**.

---

## Tabla de Contenidos

- [Requisitos Previos](#-requisitos-previos)
- [Variables de Entorno](#-variables-de-entorno)
- [Instalaci車n y Configuraci車n](#-instalaci車n-y-configuraci車n)
- [Ejecuci車n del Proyecto](#-ejecuci車n-del-proyecto)
  - [Backend (Node.js + Express)](#1-backend-nodejs--express)
  - [Frontend Web (React)](#2-frontend-web-react)
  - [App M車vil (Flutter)](#3-app-m車vil-flutter)
- [Credenciales de Prueba](#-credenciales-de-prueba)
- [API Endpoints & Eventos Socket.IO](#-api-endpoints--eventos-socketio)

---

## Requisitos Previos

Aseg迆rate de tener instaladas las siguientes herramientas en tu entorno de desarrollo:

* **Node.js**: `v18.x` o superior
* **npm**: `v9.x` o superior (o `yarn` / `pnpm`)
* **PostgreSQL**: `v14.x` o superior
* **Flutter SDK**: `v3.x` o superior
* **Dart**: Incluido en Flutter SDK
* **Android Studio / Xcode** (Para emuladores o dispositivos f穩sicos)

---

## Variables de Entorno

Antes de ejecutar la aplicaci車n, debes configurar los archivos `.env` en cada m車dulo correspondiente.

### 1. Backend (`/backend/.env`)

```env
# Configuraci車n del Servidor
PORT=3000
NODE_ENV=development

# Configuraci車n de PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_contrase?a_postgres
DB_NAME=ecohomeBD

# Configuraci車n de Pool de Conexiones
DB_MAX_CONNECTIONS=20
DB_IDLE_TIMEOUT=30000
DB_CONNECTION_TIMEOUT=2000

# Seguridad JWT
JWT_SECRET=secreto_super_seguro_ecohome_2026
JWT_EXPIRES_IN=24h
```

### 2. Frontend Web (`/frontend-web/.env`)

```env
VITE_API_URL=http://localhost:3000
VITE_SOCKET_URL=http://localhost:3000
```

---

## Instalaci車n y Configuraci車n

### 1. Clonar el Repositorio
```bash
git clone https://github.com/andfcast/ecohome_full.git
cd ecohome_full
```

### 2. Base de Datos (PostgreSQL)
Crea la base de datos en PostgreSQL e ejecuta los scripts de migraci車n y datos iniciales (seeds):
Ejecutar el script que se encuentra en la carpeta DB

---

## Ejecuci車n del Proyecto

### 1. Backend (Node.js + Express)
```bash
# Navegar al directorio del backend
cd backend/ecohome-backend

# Instalar dependencias
npm install

# Iniciar servidor en modo desarrollo
npm run dev

# El servidor iniciar芍 en: http://localhost:3000
```

### 2. Frontend Web (React)
```bash
# Navegar al directorio web
cd web-react/ecohome-frontend

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev -- --open

# La aplicaci車n abrir芍 en: http://localhost:5173
```

### 3. App M車vil (Flutter)
```bash
# Navegar al directorio mobile
cd mobile

# Obtener dependencias de pub.dev
flutter pub get

# Verificar dispositivos/emuladores disponibles
flutter devices

# Ejecutar app en emulador seleccionado
flutter run -d web-server --web-port 5000

# La aplicaci車n abrir芍 en: http://localhost:5000
```

##4 Generar APK de Android

```bash
cd mobile
flutter pub get

# Para generar la APK de lanzamiento (Release)
flutter build apk --release

# El archivo .apk se encontrar芍 en:
# mobile/build/app/outputs/flutter-apk/app-release.apk
```
---

## Credenciales de Prueba

Puedes usar las siguientes cuentas preconfiguradas para probar la autenticaci車n y los distintos roles de usuario:

| Rol | Correo Electr車nico | Contrase?a | Permisos / Acceso |
| :--- | :--- | :--- | :--- |
| **Administrador** | `admin@ecohome.com` | `PasswordSegura123` | Gestor de inventario, panel web de administraci車n |
| **Cliente** | `cliente1@ecohome.com` | `PasswordSegura123` | Cat芍logo de productos, chat de soporte m車vil/web |
| **Cliente** | `cliente2@ecohome.com` | `PasswordSegura123` | Cat芍logo de productos, chat de soporte m車vil/web |
| **Cliente** | `cliente3@ecohome.com` | `PasswordSegura123` | Cat芍logo de productos, chat de soporte m車vil/web |

---

## API Endpoints & Eventos Socket.IO

### Endpoints REST HTTP Base

#### Autenticaci車n (`/auth`)
* `POST /auth/signup` - Registro de nuevos usuarios.
* `POST /auth/login` - Iniciar sesi車n y obtener token JWT.

#### Productos (`/products`)
* `GET /products` - Listar productos ecol車gicos (con paginaci車n y filtros).
* `GET /products/:id` - Obtener detalle de un producto espec穩fico.
* `POST /products` - Crear nuevo producto *(Solo Admin)*.
* `PUT /products/:id` - Actualizar producto *(Solo Admin)*.
* `PATCH /products/:id` - Actualizar producto *(Solo Admin)*.
* `DELETE /products/:id` - Eliminar producto *(Solo Admin)*.

#### Usuarios (`/users`)
*  GET /me/stats` - Obtener estad赤sticas de creaci車n de productos

#### Mensajes (`/messages`)
* `GET /history` - Listar hist車rico de mensajes

---

###  Eventos de Socket.IO (Soporte en Tiempo Real)

El servidor de Socket.IO maneja la comunicaci車n de soporte entre clientes y administradores.

#### **Eventos Emitidos por el Cliente (Client -> Server)**

* `send_message`
  * **Payload:** `{ senderId: string, receiverId: string, message: string, timestamp: string }`
  * **Descripci車n:** Env穩a un mensaje de soporte en tiempo real.


#### **Eventos Escuchados por el Cliente (Server -> Client)**

* `receive_message`
  * **Payload:** `{ messageId: string, senderId: string, message: string, timestamp: string }`
  * **Descripci車n:** Recibe un nuevo mensaje entrante de soporte.
*
