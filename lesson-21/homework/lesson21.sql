-- 1. Table:
CREATE TABLE ProductSales (
    SaleID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    SaleDate DATE NOT NULL,
    SaleAmount DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    CustomerID INT NOT NULL
);

INSERT INTO ProductSales (SaleID, ProductName, SaleDate, SaleAmount, Quantity, CustomerID)
VALUES 
(1, 'Product A', '2023-01-01', 150.00, 2, 101),
(2, 'Product B', '2023-01-02', 200.00, 3, 102),
(3, 'Product C', '2023-01-03', 250.00, 1, 103),
(4, 'Product A', '2023-01-04', 150.00, 4, 101),
(5, 'Product B', '2023-01-05', 200.00, 5, 104),
(6, 'Product C', '2023-01-06', 250.00, 2, 105),
(7, 'Product A', '2023-01-07', 150.00, 1, 101),
(8, 'Product B', '2023-01-08', 200.00, 8, 102),
(9, 'Product C', '2023-01-09', 250.00, 7, 106),
(10, 'Product A', '2023-01-10', 150.00, 2, 107),
(11, 'Product B', '2023-01-11', 200.00, 3, 108),
(12, 'Product C', '2023-01-12', 250.00, 1, 109),
(13, 'Product A', '2023-01-13', 150.00, 4, 110),
(14, 'Product B', '2023-01-14', 200.00, 5, 111),
(15, 'Product C', '2023-01-15', 250.00, 2, 112),
(16, 'Product A', '2023-01-16', 150.00, 1, 113),
(17, 'Product B', '2023-01-17', 200.00, 8, 114),
(18, 'Product C', '2023-01-18', 250.00, 7, 115),
(19, 'Product A', '2023-01-19', 150.00, 3, 116),
(20, 'Product B', '2023-01-20', 200.00, 4, 117),
(21, 'Product C', '2023-01-21', 250.00, 2, 118),
(22, 'Product A', '2023-01-22', 150.00, 5, 119),
(23, 'Product B', '2023-01-23', 200.00, 3, 120),
(24, 'Product C', '2023-01-24', 250.00, 1, 121),
(25, 'Product A', '2023-01-25', 150.00, 6, 122),
(26, 'Product B', '2023-01-26', 200.00, 7, 123),
(27, 'Product C', '2023-01-27', 250.00, 3, 124),
(28, 'Product A', '2023-01-28', 150.00, 4, 125),
(29, 'Product B', '2023-01-29', 200.00, 5, 126),
(30, 'Product C', '2023-01-30', 250.00, 2, 127);


-- Tasks:

-- 1. Assign a row number to each sale based on the SaleDate
SELECT SaleID, ProductName, SaleDate, SaleAmount, ROW_NUMBER() OVER (ORDER BY SaleDate) AS RowNum
FROM ProductSales;

-- 2. Rank products based on the total quantity sold (use DENSE_RANK())
SELECT ProductName, SUM(Quantity) AS TotalQuantity, DENSE_RANK() OVER (ORDER BY SUM(Quantity) DESC) AS Rank
FROM ProductSales
GROUP BY ProductName;

-- 3. Identify the top sale for each customer based on the SaleAmount
WITH RankedSales AS (
    SELECT SaleID, CustomerID, SaleAmount, RANK() OVER (PARTITION BY CustomerID ORDER BY SaleAmount DESC) AS SaleRank
    FROM ProductSales
)
SELECT SaleID, CustomerID, SaleAmount
FROM RankedSales
WHERE SaleRank = 1;

-- 4. Display each sale's amount along with the next sale amount in the order of SaleDate using the LEAD() function
SELECT SaleID, ProductName, SaleAmount, LEAD(SaleAmount) OVER (ORDER BY SaleDate) AS NextSaleAmount
FROM ProductSales;

-- 5. Display each sale's amount along with the previous sale amount in the order of SaleDate using the LAG() function
SELECT SaleID, ProductName, SaleAmount, LAG(SaleAmount) OVER (ORDER BY SaleDate) AS PreviousSaleAmount
FROM ProductSales;

-- 6. Rank each sale amount within each product category
SELECT SaleID, ProductName, SaleAmount, DENSE_RANK() OVER (PARTITION BY ProductName ORDER BY SaleAmount DESC) AS SaleRank
FROM ProductSales;

-- 7. Identify sales amounts that are greater than the previous sale's amount
SELECT SaleID, ProductName, SaleAmount
FROM (
    SELECT SaleID, ProductName, SaleAmount, LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate) AS PreviousSaleAmount
    FROM ProductSales
) AS SubQuery
WHERE SaleAmount > PreviousSaleAmount;

-- 8. Calculate the difference in sale amount from the previous sale for every product
SELECT SaleID, ProductName, SaleAmount, SaleAmount - LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate) AS AmountDifference
FROM ProductSales;

-- 9. Compare the current sale amount with the next sale amount in terms of percentage change
SELECT SaleID, ProductName, SaleAmount,
       (LEAD(SaleAmount) OVER (ORDER BY SaleDate) - SaleAmount) / SaleAmount * 100 AS PercentageChange
FROM ProductSales;

-- 10. Calculate the ratio of the current sale amount to the previous sale amount within the same product
SELECT SaleID, ProductName, SaleAmount,
       SaleAmount / LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate) AS SaleAmountRatio
FROM ProductSales;

-- 11. Calculate the difference in sale amount from the very first sale of that product
WITH FirstSale AS (
    SELECT ProductName, MIN(SaleDate) AS FirstSaleDate
    FROM ProductSales
    GROUP BY ProductName
)
SELECT ps.SaleID, ps.ProductName, ps.SaleAmount, 
       ps.SaleAmount - (SELECT SaleAmount FROM ProductSales WHERE ProductName = ps.ProductName AND SaleDate = fs.FirstSaleDate) AS AmountDifferenceFromFirstSale
FROM ProductSales ps
JOIN FirstSale fs ON ps.ProductName = fs.ProductName;

-- 12. Find sales that have been increasing continuously for a product (i.e., each sale amount is greater than the previous sale amount for that product)
SELECT SaleID, ProductName, SaleAmount
FROM (
    SELECT SaleID, ProductName, SaleAmount,
           LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate) AS PreviousSaleAmount
    FROM ProductSales
) AS SubQuery
WHERE SaleAmount > PreviousSaleAmount;

-- 13. Calculate a "closing balance" for sales amounts which adds the current sale amount to a running total of previous sales
SELECT SaleID, ProductName, SaleAmount,
       SUM(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate) AS ClosingBalance
FROM ProductSales;

-- 14. Calculate the moving average of sales amounts over the last 3 sales
SELECT SaleID, ProductName, SaleAmount,
       AVG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAverage
FROM ProductSales;

-- 15. Show the difference between each sale amount and the average sale amount
SELECT SaleID, ProductName, SaleAmount,
       SaleAmount - (SELECT AVG(SaleAmount) FROM ProductSales) AS DifferenceFromAverage
FROM ProductSales;

-- 2. Table:
CREATE TABLE Employees1 (
    EmployeeID   INT PRIMARY KEY,
    Name         VARCHAR(50),
    Department   VARCHAR(50),
    Salary       DECIMAL(10,2),
    HireDate     DATE
);

INSERT INTO Employees1 (EmployeeID, Name, Department, Salary, HireDate) VALUES
(1, 'John Smith', 'IT', 60000.00, '2020-03-15'),
(2, 'Emma Johnson', 'HR', 50000.00, '2019-07-22'),
(3, 'Michael Brown', 'Finance', 75000.00, '2018-11-10'),
(4, 'Olivia Davis', 'Marketing', 55000.00, '2021-01-05'),
(5, 'William Wilson', 'IT', 62000.00, '2022-06-12'),
(6, 'Sophia Martinez', 'Finance', 77000.00, '2017-09-30'),
(7, 'James Anderson', 'HR', 52000.00, '2020-04-18'),
(8, 'Isabella Thomas', 'Marketing', 58000.00, '2019-08-25'),
(9, 'Benjamin Taylor', 'IT', 64000.00, '2021-11-17'),
(10, 'Charlotte Lee', 'Finance', 80000.00, '2016-05-09'),
(11, 'Ethan Harris', 'IT', 63000.00, '2023-02-14'),
(12, 'Mia Clark', 'HR', 53000.00, '2022-09-05'),
(13, 'Alexander Lewis', 'Finance', 78000.00, '2015-12-20'),
(14, 'Amelia Walker', 'Marketing', 57000.00, '2020-07-28'),
(15, 'Daniel Hall', 'IT', 61000.00, '2018-10-13'),
(16, 'Harper Allen', 'Finance', 79000.00, '2017-03-22'),
(17, 'Matthew Young', 'HR', 54000.00, '2021-06-30'),
(18, 'Ava King', 'Marketing', 56000.00, '2019-04-16'),
(19, 'Lucas Wright', 'IT', 65000.00, '2022-12-01'),
(20, 'Evelyn Scott', 'Finance', 81000.00, '2016-08-07');
-- 2. Tasks:

-- 1. Find Employees Who Have the Same Salary Rank
SELECT EmployeeID, Name, Department, Salary, DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank
FROM Employees1
ORDER BY Department, Salary DESC;

-- 2. Identify the Top 2 Highest Salaries in Each Department
WITH RankedSalaries AS (
    SELECT EmployeeID, Name, Department, Salary, RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
    FROM Employees1
)
SELECT EmployeeID, Name, Department, Salary
FROM RankedSalaries
WHERE Rank <= 2
ORDER BY Department, Salary DESC;

-- 3. Find the Lowest-Paid Employee in Each Department
WITH MinSalaries AS (
    SELECT Department, MIN(Salary) AS MinSalary
    FROM Employees1
    GROUP BY Department
)
SELECT e.EmployeeID, e.Name, e.Department, e.Salary
FROM Employees1 e
JOIN MinSalaries ms ON e.Department = ms.Department
WHERE e.Salary = ms.MinSalary;

-- 4. Calculate the Running Total of Salaries in Each Department
SELECT EmployeeID, Name, Department, Salary,
       SUM(Salary) OVER (PARTITION BY Department ORDER BY HireDate) AS RunningTotalSalary
FROM Employees1
ORDER BY Department, HireDate;

-- 5. Find the Total Salary of Each Department Without GROUP BY
SELECT Department,
       SUM(Salary) OVER (PARTITION BY Department) AS TotalSalary
FROM Employees1
ORDER BY Department;

-- 6. Calculate the Average Salary in Each Department Without GROUP BY
SELECT Department,
       AVG(Salary) OVER (PARTITION BY Department) AS AverageSalary
FROM Employees1
ORDER BY Department;

-- 7. Find the Difference Between an Employee’s Salary and Their Department’s Average
SELECT EmployeeID, Name, Department, Salary,
       Salary - AVG(Salary) OVER (PARTITION BY Department) AS SalaryDifferenceFromAverage
FROM Employees1;

-- 8. Calculate the Moving Average Salary Over 3 Employees (Including Current, Previous, and Next)
SELECT EmployeeID, Name, Department, Salary,
       AVG(Salary) OVER (ORDER BY HireDate ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS MovingAverageSalary
FROM Employees1
ORDER BY HireDate;

-- 9. Find the Sum of Salaries for the Last 3 Hired Employees
SELECT SUM(Salary) AS SumOfLast3Salaries
FROM (
    SELECT Salary
    FROM Employees1
    ORDER BY HireDate DESC
    LIMIT 3
) AS Last3Salaries;
