-- Midterm Group Project SQL
-- Business: "SweetScoops" Ice Cream Shop
-- Author: Reza Safari, Eda Er, 

DROP DATABASE IF EXISTS midterm_icecream_db;
CREATE DATABASE midterm_icecream_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE midterm_icecream_db;

/* =======================
   TABLES
   ======================= */

-- Employees (1→Many Orders)
CREATE TABLE employees (
  employee_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name  VARCHAR(50) NOT NULL,
  last_name   VARCHAR(50) NOT NULL,
  email       VARCHAR(100) NOT NULL,
  role        VARCHAR(20)  NOT NULL,
  hire_date   DATE         NOT NULL,
  hourly_rate DECIMAL(6,2) NOT NULL,
  CONSTRAINT UQ_employees_email UNIQUE (email),
  CONSTRAINT CK_employees_role   CHECK (role IN ('CASHIER','MANAGER','STAFFER')),
  CONSTRAINT CK_employees_pay    CHECK (hourly_rate > 0)
) ENGINE=InnoDB;

-- Customers
CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name  VARCHAR(50) NOT NULL,
  last_name   VARCHAR(50) NOT NULL,
  email       VARCHAR(100) NOT NULL,
  phone       VARCHAR(20),
  status      VARCHAR(10)  NOT NULL DEFAULT 'ACTIVE',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT UQ_customers_email UNIQUE (email),
  CONSTRAINT CK_customers_status CHECK (status IN ('ACTIVE','INACTIVE'))
) ENGINE=InnoDB;

-- Products (menu items)
CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(80) NOT NULL,
  category   VARCHAR(30) NOT NULL,
  price      DECIMAL(6,2) NOT NULL,
  is_active  TINYINT      NOT NULL DEFAULT 1,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT UQ_products_name UNIQUE (name),
  CONSTRAINT CK_products_price CHECK (price > 0)
) ENGINE=InnoDB;

-- Orders (parent of order_items)
CREATE TABLE orders (
  order_id    INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  employee_id INT NOT NULL,
  order_date  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status      VARCHAR(12) NOT NULL DEFAULT 'NEW',
  CONSTRAINT CK_orders_status CHECK (status IN ('NEW','PAID','CANCELLED')),
  CONSTRAINT FK_orders_customers FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT FK_orders_employees FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Associative table: Orders ↔ Products
CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  quantity      INT NOT NULL,
  unit_price    DECIMAL(6,2) NOT NULL,
  CONSTRAINT FK_order_items_orders   FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FK_order_items_products FOREIGN KEY (product_id)
    REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT CK_order_items_qty   CHECK (quantity BETWEEN 1 AND 20),
  CONSTRAINT CK_order_items_price CHECK (unit_price > 0),
  CONSTRAINT UQ_order_items_order_product UNIQUE (order_id, product_id)
) ENGINE=InnoDB;

/* =======================
   SEED DATA
   ======================= */

-- Employees (5)
INSERT INTO employees (first_name,last_name,email,role,hire_date,hourly_rate) VALUES
('Ava','Nguyen','ava.nguyen@sweetscoops.local','MANAGER','2023-01-10',28.50),
('Leo','Martinez','leo.martinez@sweetscoops.local','CASHIER','2024-03-02',20.25),
('Maya','Singh','maya.singh@sweetscoops.local','STAFFER','2024-04-15',18.75),
('Noah','Brooks','noah.brooks@sweetscoops.local','STAFFER','2024-05-21',18.25),
('Ivy','Chen','ivy.chen@sweetscoops.local','CASHIER','2024-06-05',19.50);

-- Customers (10)
INSERT INTO customers (first_name,last_name,email,phone,status) VALUES
('Reza','Safari','reza.safari@example.com','206-555-1001','ACTIVE'),
('Eda','Er','eda.er@example.com','206-555-1002','ACTIVE'),
('Sam','Lee','sam.lee@example.com','206-555-1003','ACTIVE'),
('Nora','Kim','nora.kim@example.com','206-555-1004','ACTIVE'),
('Omar','Ali','omar.ali@example.com','206-555-1005','ACTIVE'),
('Liam','Wright','liam.wright@example.com','206-555-1006','ACTIVE'),
('Ella','Price','ella.price@example.com','206-555-1007','ACTIVE'),
('Zoe','Rivera','zoe.rivera@example.com','206-555-1008','ACTIVE'),
('Kai','Johnson','kai.johnson@example.com','206-555-1009','INACTIVE'),
('Mila','Young','mila.young@example.com','206-555-1010','ACTIVE');

-- Products (12)
INSERT INTO products (name,category,price) VALUES
('Vanilla Scoop','Scoop',3.50),
('Chocolate Scoop','Scoop',3.75),
('Strawberry Scoop','Scoop',3.75),
('Mint Chip Scoop','Scoop',3.95),
('Cookie Dough Scoop','Scoop',4.25),
('Waffle Cone','AddOn',1.25),
('Sprinkles','AddOn',0.50),
('Hot Fudge','AddOn',0.95),
('Banana Split','Sundae',7.50),
('Brownie Sundae','Sundae',6.95),
('Milkshake Vanilla','Drink',5.25),
('Affogato','Drink',4.95);

-- Orders (12)
INSERT INTO orders (customer_id, employee_id, status, order_date) VALUES
(1,1,'PAID','2025-10-01 13:05:00'),
(2,2,'PAID','2025-10-01 13:10:00'),
(3,2,'PAID','2025-10-02 11:00:00'),
(4,3,'PAID','2025-10-02 19:15:00'),
(5,4,'PAID','2025-10-03 12:40:00'),
(6,5,'PAID','2025-10-03 20:20:00'),
(7,2,'PAID','2025-10-04 14:55:00'),
(8,3,'PAID','2025-10-04 15:05:00'),
(9,4,'CANCELLED','2025-10-05 10:20:00'),
(10,5,'PAID','2025-10-05 16:45:00'),
(1,2,'PAID','2025-10-06 12:30:00'),
(2,1,'NEW','2025-10-06 12:45:00');

-- Order Items (≥1 per order)
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,1,2,3.50), (1,6,1,1.25),
(2,9,1,7.50),
(3,10,1,6.95), (3,7,1,0.50),
(4,11,1,5.25),
(5,5,1,4.25), (5,6,1,1.25), (5,8,1,0.95),
(6,12,1,4.95),
(7,2,1,3.75), (7,6,1,1.25),
(8,3,1,3.75), (8,7,1,0.50),
(9,4,1,3.95),
(10,10,1,6.95),
(11,1,1,3.50), (11,8,1,0.95),
(12,2,1,3.75);

/* =======================
   VERIFICATION QUERIES
   ======================= */

SET @db := DATABASE();

-- Primary Keys
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE CONSTRAINT_NAME = 'PRIMARY'
  AND TABLE_SCHEMA = @db;

-- Foreign Keys
SELECT
  kcu.TABLE_NAME   AS `Table`,
  kcu.COLUMN_NAME  AS `Column`,
  kcu.CONSTRAINT_NAME AS `Constraint`,
  kcu.REFERENCED_TABLE_NAME AS `Referenced Table`,
  kcu.REFERENCED_COLUMN_NAME AS `Referenced Column`
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
WHERE kcu.REFERENCED_TABLE_NAME IS NOT NULL
  AND kcu.TABLE_SCHEMA = @db;

-- Unique Constraints
SELECT
  tc.TABLE_NAME,
  kcu.COLUMN_NAME,
  tc.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
  AND tc.TABLE_NAME = kcu.TABLE_NAME
WHERE tc.CONSTRAINT_TYPE = 'UNIQUE'
  AND tc.TABLE_SCHEMA = @db;

-- Check Constraints
SELECT
  tc.TABLE_NAME,
  cc.CONSTRAINT_NAME,
  cc.CHECK_CLAUSE
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
  ON cc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'CHECK'
  AND cc.CONSTRAINT_SCHEMA = @db;

-- Default Constraints (columns with defaults)
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_DEFAULT IS NOT NULL
  AND TABLE_SCHEMA = @db;

-- Step 7: Counts + sample rows (parents first)
SELECT 'employees' AS table_name, COUNT(*) AS row_count FROM employees; SELECT * FROM employees;
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers; SELECT * FROM customers;
SELECT 'products'  AS table_name, COUNT(*) AS row_count FROM products;  SELECT * FROM products;
SELECT 'orders'    AS table_name, COUNT(*) AS row_count FROM orders;    SELECT * FROM orders;
SELECT 'order_items' AS table_name, COUNT(*) AS row_count FROM order_items; SELECT * FROM order_items;
