CREATE TABLE purchases (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER,
  customer_id INTEGER,
  product_id INTEGER,
  sale_date DATE,
  sale_amount MONEY,
  units_sold INTEGER,
  invoice_no INTEGER,
  invoice_frequency_id INTEGER
);

CREATE TABLE employee (
  id SERIAL PRIMARY KEY,
  employee VARCHAR(255),
  employee_email VARCHAR(255)
);

CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  customer VARCHAR(255),
  customer_account_no VARCHAR(255)
);

CREATE TABLE product (
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(255)
);

CREATE TABLE invoice_frequency (
  id SERIAL PRIMARY KEY,
  invoice_frequency VARCHAR(255)
);
