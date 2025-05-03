-- 1. Tables:
CREATE TABLE #Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT,
    Price DECIMAL(10,2),
    SaleDate DATE
);


INSERT INTO #Sales (CustomerName, Product, Quantity, Price, SaleDate) VALUES
('Alice', 'Laptop', 1, 1200.00, '2024-01-15'),
('Bob', 'Smartphone', 2, 800.00, '2024-02-10'),
('Charlie', 'Tablet', 1, 500.00, '2024-02-20'),
('David', 'Laptop', 1, 1300.00, '2024-03-05'),
('Eve', 'Smartphone', 3, 750.00, '2024-03-12'),
('Frank', 'Headphones', 2, 100.00, '2024-04-08'),
('Grace', 'Smartwatch', 1, 300.00, '2024-04-25'),
('Hannah', 'Tablet', 2, 480.00, '2024-05-05'),
('Isaac', 'Laptop', 1, 1250.00, '2024-05-15'),
('Jack', 'Smartphone', 1, 820.00, '2024-06-01');

-- Tasks:

-- Find customers who purchased at least one item in March 2024 using EXISTS
SELECT DISTINCT CustomerName
FROM #Sales s
WHERE EXISTS (
    SELECT 1
    FROM #Sales
    WHERE SaleDate BETWEEN '2024-03-01' AND '2024-03-31'
    AND CustomerName = s.CustomerName
);

-- Find the product with the highest total sales revenue using a subquery
SELECT Product
FROM #Sales
GROUP BY Product
HAVING SUM(Quantity * Price) = (
    SELECT MAX(TotalRevenue)
    FROM (
        SELECT SUM(Quantity * Price) AS TotalRevenue
        FROM #Sales
        GROUP BY Product
    ) AS SubQuery
);

-- Find the second highest sale amount using a subquery
SELECT MAX(Quantity * Price) AS SecondHighestSale
FROM #Sales
WHERE Quantity * Price < (
    SELECT MAX(Quantity * Price)
    FROM #Sales
);

-- Find the total quantity of products sold per month using a subquery
SELECT SaleDate, SUM(Quantity) AS TotalQuantity
FROM #Sales
GROUP BY SaleDate
HAVING MONTH(SaleDate) = (
    SELECT MAX(MONTH(SaleDate))
    FROM #Sales
);

-- Find customers who bought the same products as another customer using EXISTS
SELECT DISTINCT s1.CustomerName
FROM #Sales s1, #Sales s2
WHERE s1.Product = s2.Product
  AND s1.CustomerName <> s2.CustomerName
  AND EXISTS (
      SELECT 1
      FROM #Sales s3
      WHERE s3.CustomerName = s1.CustomerName AND s3.Product = s2.Product
  );

-- Return how many fruits does each person have in individual fruit level
SELECT CustomerName, Product, SUM(Quantity) AS TotalQuantity
FROM #Sales
WHERE Product IN ('Apple', 'Banana', 'Orange')  -- Adjust based on actual fruit products
GROUP BY CustomerName, Product;

-- table:
CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY,
    ProductID  INT,
    Quantity   INT,
    OrderDate  DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Orders (OrderID, ProductID, Quantity, OrderDate) VALUES
(1, 1, 2, '2024-03-01'),
(2, 3, 5, '2024-03-05'),
(3, 2, 3, '2024-03-07'),
(4, 5, 4, '2024-03-10'),
(5, 8, 1, '2024-03-12'),
(6, 10, 2, '2024-03-15'),
(7, 12, 10, '2024-03-18'),
(8, 7, 6, '2024-03-20'),
(9, 6, 2, '2024-03-22'),
(10, 4, 3, '2024-03-25'),
(11, 9, 2, '2024-03-28'),
(12, 11, 1, '2024-03-30'),
(13, 14, 4, '2024-04-02'),
(14, 15, 5, '2024-04-05'),
(15, 13, 20, '2024-04-08');


-- tasks:
-- 1. Find the products that have been ordered at least once
SELECT DISTINCT p.ProductName
FROM Products p
WHERE EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.ProductID = p.ProductID
);

-- 2. Retrieve the names of products that have been ordered more than the average quantity ordered
SELECT p.ProductName
FROM Products p
JOIN Orders o ON p.ProductID = o.ProductID
GROUP BY p.ProductName
HAVING SUM(o.Quantity) > (
    SELECT AVG(TotalQuantity)
    FROM (
        SELECT SUM(Quantity) AS TotalQuantity
        FROM Orders
        GROUP BY ProductID
    ) AS SubQuery
);

-- 3. Find the products that have never been ordered
SELECT p.ProductName
FROM Products p
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.ProductID = p.ProductID
);

-- 4. Retrieve the product with the highest total quantity ordered
SELECT TOP 1 p.ProductName
FROM Products p
JOIN Orders o ON p.ProductID = o.ProductID
GROUP BY p.ProductName
ORDER BY SUM(o.Quantity) DESC;

-- 5. Find the products that have been ordered more times than the average number of orders placed
SELECT p.ProductName
FROM Products p
JOIN Orders o ON p.ProductID = o.ProductID
GROUP BY p.ProductName
HAVING COUNT(o.OrderID) > (
    SELECT AVG(OrderCount)
    FROM (
        SELECT COUNT(OrderID) AS OrderCount
        FROM Orders
        GROUP BY ProductID
    ) AS SubQuery
);
