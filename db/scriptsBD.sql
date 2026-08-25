-- CREACIÓN DE DATABASE ecohomeBD

DROP DATABASE IF EXISTS "ecohomeBD";

CREATE DATABASE "ecohomeBD"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Colombia.1252'
    LC_CTYPE = 'Spanish_Colombia.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- CREACIÓN DE OBJETOS EN LA BASE DE DATOS "ecohomeBD"
-- 1. Tabla de Usuarios (users)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'cliente', -- Preparado para RBAC ('admin', 'cliente')
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index para acelerar búsquedas por email en el login
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);


-- 2. Tabla de Productos (products)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER NOT NULL,
    CONSTRAINT fk_products_created_by 
        FOREIGN KEY (created_by) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- Función y Trigger para actualizar automáticamente el campo `updated_at` en productos
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

--- Creación de la tabla de mensajes (messages) para el chat
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO users (name, email, password_hash, role) VALUES ('Administrador', 'admin@ecohome.com', '$2b$10$AyfbZ/4L4REUO2Z77FSBQeMXZzdcrlQStj.JK9qhbP76EdV9gxKcK', 'admin');
INSERT INTO users (name, email, password_hash, role) VALUES ('Cliente 1', 'cliente1@ecohome.com', '$2b$10$6Qhx6CoCiduzw3CKbr.eT.KCFBRgnQYcd5.VVLpalq1kys2YhmtkS', 'cliente');
INSERT INTO users (name, email, password_hash, role) VALUES ('Cliente 2', 'cliente2@ecohome.com', '$2b$10$TYl3lqj.dNd1jPJfNVc68.Ex4BWl0nnwCB1lbQG1GnqufOT1rIAG6', 'cliente');
INSERT INTO users (name, email, password_hash, role) VALUES ('Cliente 3', 'cliente3@ecohome.com', '$2b$10$V7TIh55r06lHTimujdd6NuKh3Zge81FpwJBk31lqohfqBK8Z1hHWW', 'cliente');