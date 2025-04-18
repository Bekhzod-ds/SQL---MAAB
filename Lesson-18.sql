-- =============================================
-- SQL Homework: Subqueries & Aggregations
-- Name: Ergashov Bekhzod
-- =============================================

-- Level 1: Basic Subqueries
-- Find Employees with Minimum Salary
-- Tables: employees (columns: id, name, salary)

CREATE TABLE employees ( id INT PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10, 2) );
INSERT INTO employees (id, name, salary) VALUES (1, 'Alice', 50000), (2, 'Bob', 60000), (3, 'Charlie', 50000);

-- Query:
SELECT * FROM employees WHERE salary = (SELECT MIN(salary) FROM employees);

-- Find Products Above Average Price, Task: Retrieve products priced above the average price.
-- Tables: products (columns: id, product_name, price)

CREATE TABLE products ( id INT PRIMARY KEY, product_name VARCHAR(100), price DECIMAL(10, 2) );
INSERT INTO products (id, product_name, price) VALUES (1, 'Laptop', 1200), (2, 'Tablet', 400), (3, 'Smartphone', 800), (4, 'Monitor', 300);

-- query:
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Level 2: Nested Subqueries with Conditions
-- Task: Retrieve employees who work in the "Sales" department.

CREATE TABLE departments ( id INT PRIMARY KEY, department_name VARCHAR(100) );
CREATE TABLE employees ( id INT PRIMARY KEY, name VARCHAR(100), department_id INT, FOREIGN KEY (department_id) REFERENCES departments(id) );
INSERT INTO departments (id, department_name) VALUES (1, 'Sales'), (2, 'HR');
INSERT INTO employees (id, name, department_id) VALUES (1, 'David', 1), (2, 'Eve', 2), (3, 'Frank', 1);

-- Query:
SELECT id, name, (SELECT department_name FROM departments WHERE department_name = 'Sales') AS department_name
FROM employees WHERE department_id = (SELECT id FROM departments WHERE department_name = 'Sales');

-- Find Customers with No Orders

CREATE TABLE customers ( customer_id INT PRIMARY KEY, name VARCHAR(100) );
CREATE TABLE orders ( order_id INT PRIMARY KEY, customer_id INT, FOREIGN KEY (customer_id) REFERENCES customers(customer_id) );
INSERT INTO customers (customer_id, name) VALUES (1, 'Grace'), (2, 'Heidi'), (3, 'Ivan');
INSERT INTO orders (order_id, customer_id) VALUES (1, 1), (2, 1);

-- Query:
SELECT * FROM customers WHERE customer_id NOT IN (SELECT customer_id FROM orders);

-- Level 3: Aggregation and Grouping in Subqueries
-- Task: Retrieve products with the highest price in each category.

CREATE TABLE products ( id INT PRIMARY KEY, product_name VARCHAR(100), price DECIMAL(10, 2), category_id INT );
INSERT INTO products (id, product_name, price, category_id) VALUES (1, 'Tablet', 400, 1), (2, 'Laptop', 1500, 1), (3, 'Headphones', 200, 2), (4, 'Speakers', 300, 2);

-- QUERY:
SELECT * FROM products p WHERE price = (SELECT MAX(price) FROM products WHERE category_id = p.category_id);

-- Task: Retrieve employees working in the department with the highest average salary.

CREATE TABLE departments ( id INT PRIMARY KEY, department_name VARCHAR(100) );
CREATE TABLE employees ( id INT PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10, 2), department_id INT, FOREIGN KEY (department_id) REFERENCES departments(id) );
INSERT INTO departments (id, department_name) VALUES (1, 'IT'), (2, 'Sales');
INSERT INTO employees (id, name, salary, department_id) VALUES (1, 'Jack', 80000, 1), (2, 'Karen', 70000, 1), (3, 'Leo', 60000, 2);

-- query:
SELECT * FROM employees
WHERE department_id = (SELECT TOP 1 department_id FROM employees GROUP BY department_id ORDER BY AVG(salary) DESC);

-- Level 4: Correlated Subqueries
-- Task: Retrieve employees earning more than the average salary in their department.

CREATE TABLE employees ( id INT PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10, 2), department_id INT );
INSERT INTO employees (id, name, salary, department_id) VALUES (1, 'Mike', 50000, 1), (2, 'Nina', 75000, 1), (3, 'Olivia', 40000, 2), (4, 'Paul', 55000, 2);

-- query:
SELECT E.* FROM employees E WHERE E.salary >= (SELECT AVG(e.salary) FROM employees e WHERE e.department_id = E.department_id );

-- Task: Retrieve students who received the highest grade in each course.

CREATE TABLE students ( student_id INT PRIMARY KEY, name VARCHAR(100) );
CREATE TABLE grades ( student_id INT, course_id INT, grade DECIMAL(4, 2), FOREIGN KEY (student_id) REFERENCES students(student_id) );
INSERT INTO students (student_id, name) VALUES (1, 'Sarah'), (2, 'Tom'), (3, 'Uma');
INSERT INTO grades (student_id, course_id, grade) VALUES (1, 101, 95), (2, 101, 85), (3, 102, 90), (1, 102, 80);

-- QUery:
SELECT s.* FROM students s WHERE EXISTS (SELECT 1 FROM grades g WHERE g.student_id = s.student_id AND g.grade = (
    SELECT MAX(g2.grade) FROM grades g2 WHERE g2.course_id = g.course_id));

-- Level 5: Subqueries with Ranking and Complex Conditions
-- Task: Retrieve products with the third-highest price in each category.

CREATE TABLE products ( id INT PRIMARY KEY, product_name VARCHAR(100), price DECIMAL(10, 2), category_id INT );
INSERT INTO products (id, product_name, price, category_id) VALUES (1, 'Phone', 800, 1), (2, 'Laptop', 1500, 1), (3, 'Tablet', 600, 1), (4, 'Smartwatch', 300, 1), (5, 'Headphones', 200, 2), (6, 'Speakers', 300, 2), (7, 'Earbuds', 100, 2);

-- query:
SELECT * FROM products;
WITH products_rank AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY product_name ORDER BY price DESC) AS RNK FROM products)
    SELECT * FROM products_rank WHERE RNK = 3;

-- Task: Retrieve employees with salaries above the company average but below the maximum in their department.

CREATE TABLE employees ( id INT PRIMARY KEY, name VARCHAR(100), salary DECIMAL(10, 2), department_id INT );
INSERT INTO employees (id, name, salary, department_id) VALUES (1, 'Alex', 70000, 1), (2, 'Blake', 90000, 1), (3, 'Casey', 50000, 2), (4, 'Dana', 60000, 2), (5, 'Evan', 75000, 1);

-- query:
SELECT * FROM employees;
SELECT * FROM employees WHERE salary > (SELECT AVG(e1.salary) FROM employees e1) AND
salary < (SELECT MAX(e2.salary) FROM employees e2 WHERE e2.department_id = department_id);


