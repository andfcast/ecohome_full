### 1. Error de Seguridad por falta de Token (Petición no autenticada)

Intentar crear un producto sin pasar la cabecera `Authorization`.

```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Plato de Bambú Test", "price": 10.00}'

```

* **Respuesta esperada:** `HTTP/1.1 401 Unauthorized`
* **JSON:** `{"message": "Acceso denegado. Se requiere token Bearer."}`

---

### 2. Autenticación y Obtención de Tokens

**a) Registro e Inicio de Sesión como Admin:**

```bash
# Signup Admin
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name": "Admin EcoHome", "email": "admin@ecohome.com", "password": "AdminPassword123", "role": "admin"}'

# Login Admin
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@ecohome.com", "password": "AdminPassword123"}'

```

*(De la respuesta de login del Admin, guarda el valor del campo `"token"` como `$TOKEN_ADMIN`)*

**b) Login como Cliente estándar:**

```bash
# Signup Cliente
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name": "Cliente Prueba", "email": "cliente@ecohome.com", "password": "ClientePassword123", "role": "cliente"}'

# Login Cliente
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "cliente@ecohome.com", "password": "ClientePassword123"}'

```

*(De la respuesta de login del Cliente, guarda el valor del campo `"token"` como `$TOKEN_CLIENTE`)*

---

### 3. Crear Producto (`POST /products`) — Protegido

**a) Validación con datos inválidos (Precio <= 0 o ausente):**

```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -d '{"name": "Producto Inválido"}'

```

* **Respuesta esperada:** `HTTP/1.1 400 Bad Request`
* **JSON:** `{"message": "El nombre y precio son obligatorios."}`

**b) Creación exitosa como Admin:**

```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -d '{"name": "Juego de Cubiertos de Bambú", "price": 14.99}'

```

* **Respuesta esperada:** `HTTP/1.1 201 Created`
* **JSON:** Devuelve el producto con `id: 1`.

---

### 4. Consultar Catálogo (`GET /products` y `GET /products/:id`) — Público

**a) Obtener todos los productos:**

```bash
curl -X GET http://localhost:3000/products

```

* **Respuesta esperada:** `HTTP/1.1 200 OK` (Array JSON con todos los productos).

**b) Obtener un producto por ID existente:**

```bash
curl -X GET http://localhost:3000/products/1

```

* **Respuesta esperada:** `HTTP/1.1 200 OK` (Objeto JSON del producto ID 1).

**c) Obtener un producto por ID inexistente (Error 404):**

```bash
curl -X GET http://localhost:3000/products/999

```

* **Respuesta esperada:** `HTTP/1.1 404 Not Found`
* **JSON:** `{"message": "Producto no encontrado."}`

---

### 5. Actualizar Producto (`PUT` / `PATCH /products/:id`) — Protegido

**a) Actualización Parcial (`PATCH /products/:id`):** Cambiar el precio y marcar agotado.

```bash
curl -X PATCH http://localhost:3000/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -d '{"price": 12.50, "is_available": false}'

```

* **Respuesta esperada:** `HTTP/1.1 200 OK`

**b) Actualización Total (`PUT /products/:id`):** Reemplazar todos los campos.

```bash
curl -X PUT http://localhost:3000/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -d '{"name": "Juego de Cubiertos Reutilizables Bambú", "price": 16.00, "is_available": true}'

```

* **Respuesta esperada:** `HTTP/1.1 200 OK`

---

### 6. Eliminar Producto (`DELETE /products/:id`) — Protegido

```bash
curl -X DELETE http://localhost:3000/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ADMIN"

```

* **Respuesta esperada:** `HTTP/1.1 200 OK`
* **JSON:** `{"message": "Producto eliminado del catálogo exitosamente."}`
