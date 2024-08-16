--Find customers who have placed orders in more than one country.

        SELECT CUS.CustomerName, CUS.CustomerID, COUNT(DISTINCT S.Country) AS CountCountry
        FROM Customers CUS
        JOIN Orders O ON CUS.CustomerID = O.CustomerID
        JOIN Orderdetails OD ON O.OrderID  = OD.OrderID
        JOIN Products P ON OD.ProductID = P.ProductID
        JOIN Suppliers S ON P.SupplierID = S.SupplierID
        GROUP BY CUS.CustomerID, CUS.CustomerName
        HAVING CountCountry > 1
        ORDER BY CountCountry DESC
        LIMIT 10


--Finds employees who have processed more than 20 orders and displays their full names and total orders processed.
  
        SELECT FirstName || " " || LastName AS Employee, COUNT(OrderID) AS CountOrder
        FROM Orders O
        JOIN Employees e ON e.EmployeeID = o.EmployeeID
        GROUP BY o.EmployeeID
        HAVING CountOrder > 20
        ORDER BY CountOrder DESC


--find the 10 employees who collected the most

    SELECT 
        e.EmployeeID,
        e.LastName || ', ' || e.FirstName AS EmployeeName,
        SUM(od.Quantity * p.Price) AS TotalRevenue
    FROM 
        Employees e
    JOIN 
        Orders o ON e.EmployeeID = o.EmployeeID
    JOIN 
        OrderDetails od ON o.OrderID = od.OrderID
    JOIN 
        Products p ON od.ProductID = p.ProductID
    GROUP BY 
        e.EmployeeID, EmployeeName
    ORDER BY 
        TotalRevenue DESC
    LIMIT 10;


--List products that have never been ordered
    
        SELECT P.ProductName
        FROM Products P
        LEFT JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        WHERE OD.ProductID IS NULL;


 --Calcula los ingresos totales generados por cada categoría de productos
   
        SELECT C.CategoryName, SUM(P.Price * OD.Quantity) AS Revenue
        FROM OrderDetails OD
        JOIN Products P ON P.ProductID = OD.ProductID
        JOIN Categories C ON P.CategoryID = C.CategoryID
        GROUP BY C.CategoryID, C.CategoryName
        ORDER BY Revenue DESC;
   
   

--Encuentra los 10 productos más caros
  
        SELECT ProductName, Price
        FROM Products
        ORDER BY Price DESC
        LIMIT 10;
  
  

  --Encuentra los 5 clientes con más pedidos
  
        SELECT COUNT(O.OrderID) AS CountOrder, C.CustomerName
        FROM Customers C
        JOIN Orders O ON O.CustomerID = C.CustomerID
        GROUP BY CustomerName
        ORDER BY CountOrder DESC
        LIMIT 5;
    

 --Encuentra las ventas totales por país
   
        SELECT C.Country, SUM(OD.Quantity * P.Price) AS TotalSales
        FROM Customers C
        JOIN Orders O ON C.CustomerID = O.CustomerID
        JOIN OrderDetails OD ON O.OrderID = OD.OrderID
        JOIN Products P ON OD.ProductID = P.ProductID
        GROUP BY C.Country
        ORDER BY TotalSales DESC;
   

 --Obtén el precio promedio de los productos por categoría
   
        SELECT CAT.CategoryName, AVG(P.Price) AS AveragePrice
        FROM Products P
        JOIN Categories CAT ON P.CategoryID = CAT.CategoryID
        GROUP BY CAT.CategoryName
        ORDER BY AveragePrice DESC;
    

  --Lista los 10 productos más vendidos (por cantidad)
    
        SELECT P.ProductName, SUM(OD.Quantity) AS CountQuantity
        FROM Products P
        JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        GROUP BY P.ProductName
        ORDER BY CountQuantity DESC
        LIMIT 10;
    

  --Lista los productos que tienen un precio mayor que el precio promedio de todos los productos
    
        SELECT ProductName, Price
        FROM Products
        WHERE Price > (SELECT AVG(Price) FROM Products)
        LIMIT 10;
    

   --Encuentra el cliente con el mayor gasto total
   
        SELECT C.CustomerName, SUM(OD.Quantity * P.Price) AS TotalSpent
        FROM Customers C
        JOIN Orders O ON C.CustomerID = O.CustomerID
        JOIN OrderDetails OD ON O.OrderID = OD.OrderID
        JOIN Products P ON OD.ProductID = P.ProductID
        GROUP BY C.CustomerName
        ORDER BY TotalSpent DESC
        LIMIT 1;
   

   --Lista proveedores que suministran productos en más de una categoría
        SELECT S.SupplierName, COUNT(DISTINCT P.CategoryID) AS CategoryCount
        FROM Suppliers S
        JOIN Products P ON S.SupplierID = P.SupplierID
        GROUP BY S.SupplierName
        HAVING CategoryCount > 1;
  

   -- Encuentra el total de productos vendidos por empleado
   
        SELECT E.FirstName, E.LastName, SUM(OD.Quantity) AS TotalQuantitySold
        FROM Employees E
        JOIN Orders O ON E.EmployeeID = O.EmployeeID
        JOIN OrderDetails OD ON O.OrderID = OD.OrderID
        GROUP BY E.FirstName, E.LastName
        ORDER BY TotalQuantitySold DESC;
 

  --Lista los clientes que han hecho más de 5 compras
        SELECT C.CustomerName, COUNT(O.OrderID) AS NumberOfOrders
        FROM Customers C
        JOIN Orders O ON C.CustomerID = O.CustomerID
        GROUP BY C.CustomerName
        HAVING NumberOfOrders > 5;
  

-- Obtén la lista de productos pedidos en enero de 1997

        SELECT DISTINCT P.ProductName
        FROM Products P
        JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        JOIN Orders O ON OD.OrderID = O.OrderID
        WHERE strftime('%Y-%m', O.OrderDate) = '1997-01';
   

 --Encuentra el proveedor con la mayor cantidad de productos suministrados
 
        SELECT S.SupplierName, COUNT(P.ProductID) AS NumberOfProducts
        FROM Suppliers S
        JOIN Products P ON S.SupplierID = P.SupplierID
        GROUP BY S.SupplierName
        ORDER BY NumberOfProducts DESC
        LIMIT 1;


  --Lista todos los productos que se venden por menos de $10
   
        SELECT ProductName, Price
        FROM Products
        WHERE Price < 10;
  
    