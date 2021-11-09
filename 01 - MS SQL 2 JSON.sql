/* Format MS SQL data in JSON format */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* FOR JSON AUTO*/

-- Select a random data and not using a table -> fail
SELECT 'Gin tonic' AS Drink FOR JSON AUTO;

USE [WideWorldImporters];

-- Select all data from table -> fail because of CLR object (geography)
SELECT C.* FROM [Sales].[Customers] AS C FOR JSON AUTO;
-- Compare to XML
SELECT C.* FROM [Sales].[Customers] AS C FOR XML AUTO;

-- Select data from table with additional column -> fail for not using alias
SELECT 
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber
    , C.FaxNumber
    , C.WebsiteURL
    , GETDATE() 
FROM 
    [Sales].[Customers] AS C 
FOR JSON AUTO;

-- Finally a good example
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber
    , C.FaxNumber
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
FROM 
    [Sales].[Customers] AS C 
FOR JSON AUTO;

-- Finally a good example - tabular
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber
    , C.FaxNumber
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
FROM 
    [Sales].[Customers] AS C;


-- Finally a good example - XML AUTO (check the length!!!)
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber
    , C.FaxNumber
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
FROM 
    [Sales].[Customers] AS C 
FOR XML AUTO;

SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber
    , C.FaxNumber
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
FROM 
    [Sales].[Customers] AS C 
FOR XML AUTO, ELEMENTS;

/* FOR JSON PATH*/

-- Not using a table works with JSON PATH 
SELECT 'Gin tonic' AS Drink FOR JSON PATH;

-- Nested object - Contact
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber AS 'Contact.Phone'
    , C.FaxNumber AS 'Contact.Fax'
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
FROM 
    [Sales].[Customers] AS C 
FOR JSON PATH;

SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.PhoneNumber AS 'Contact.Phone'
    , C.FaxNumber AS 'Contact.Fax'
    , C.WebsiteURL
    , GETDATE() AS DataDateTime 
	, C.PhoneNumber AS 'Contact.GSM'
FROM 
    [Sales].[Customers] AS C 
FOR JSON PATH;

-- NULL value

-- Select data in JSON format with NULL values
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
     , CASE WHEN CustomerID IN (2, 5) THEN NULL ELSE C.WebsiteURL END AS WebsiteURL
FROM 
    [Sales].[Customers] AS C 
FOR JSON AUTO;

-- Using INCLUDE_NULL_VALUES 
SELECT  TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
     , CASE WHEN CustomerID IN (2, 5) THEN NULL ELSE C.WebsiteURL END AS WebsiteURL
FROM 
    [Sales].[Customers] AS C 
FOR JSON AUTO, INCLUDE_NULL_VALUES;

-- Adding ROOT node
SELECT TOP(5)
    C.[CustomerID]
    , C.[CustomerName]
    , C.WebsiteURL
FROM 
    [Sales].[Customers] AS C 
FOR JSON PATH, ROOT ('Customers');

-- Single object
SELECT 
    C.[CustomerID]
    , C.[CustomerName]
    , C.WebsiteURL
FROM 
    [Sales].[Customers] AS C 
WHERE
	CustomerID = 1
FOR JSON PATH;

-- Single object using WITHOUT_ARRAY_WRAPPER
SELECT 
    C.[CustomerID]
    , C.[CustomerName]
    , C.WebsiteURL
FROM 
    [Sales].[Customers] AS C 
WHERE
	CustomerID = 1
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

-- Multiple object using WITHOUT_ARRAY_WRAPPER
SELECT 
    C.[CustomerID]
    , C.[CustomerName]
    , C.WebsiteURL
FROM 
    [Sales].[Customers] AS C 
WHERE
	CustomerID IN (1, 2)
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

-- Multiple object using WITHOUT_ARRAY_WRAPPER with ROOT
SELECT 
    C.[CustomerID]
    , C.[CustomerName]
    , C.WebsiteURL
FROM 
    [Sales].[Customers] AS C 
WHERE
	CustomerID IN (1, 2)
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, ROOT ('Customers');