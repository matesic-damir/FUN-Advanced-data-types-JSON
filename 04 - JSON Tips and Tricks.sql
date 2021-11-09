/* MS SQL JSON T&T */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* ISJSON */

-- NULL
SELECT ISJSON(NULL) AS Result
UNION
-- Invalid
SELECT ISJSON(N'"Name": "John Doe"')
UNION
-- Valid
SELECT ISJSON(N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}');

-- Valid?
SELECT ISJSON(N'{
"Name": "John Doe",
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}')  AS Result;

-- Check constraint

USE WideWorldImporters;
GO
DROP TABLE IF EXISTS dbo.TestUserSettings;
GO
CREATE TABLE dbo.TestUserSettings(
	[Key] NVARCHAR(256) NOT NULL,
	App_Settings NVARCHAR(MAX) NULL CONSTRAINT CK_user_settings CHECK (ISJSON(App_Settings) = 1)
);
GO
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES ('key1', NULL);
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES  ('key1', N'"Name": "John Doe"');
INSERT INTO dbo.TestUserSettings ([Key], App_Settings) VALUES  ('key1', N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}');
GO
SELECT * FROM dbo.TestUserSettings;
GO
DROP TABLE IF EXISTS dbo.TestUserSettings;
GO

/* Import JSON data from a file */

SELECT [key], [value], [type]
FROM OPENROWSET (BULK 'C:\Temp\JSON_data.json', SINGLE_CLOB) AS x
CROSS APPLY OPENJSON(BulkColumn);

/* Indexing JSON data */

USE WideWorldImporters;
GO
DROP TABLE IF EXISTS dbo.JSONIndexing;
GO
CREATE TABLE dbo.JSONIndexing(
    [CustomerID] INT NOT NULL,
    [CustomerData] NVARCHAR(2000) NULL,
    CONSTRAINT PK_JSONIndexing PRIMARY KEY CLUSTERED([CustomerID])
);
GO
INSERT INTO dbo.JSONIndexing ([CustomerID], [CustomerData])
SELECT 
    [CustomerID]
    , ( SELECT 
		  C1.[CustomerName] AS Name
		  , PC1.FullName AS PrimaryContact
		  , C1.PhoneNumber AS 'Contact.Phone'
		  , C1.FaxNumber AS 'Contact.Fax'
		  , C1.WebsiteURL
		  , C1.DeliveryAddressLine1 AS 'Delivery.AddressLine1'
		  , C1.DeliveryAddressLine2 AS 'Delivery.AddressLine2'
		  , C1.DeliveryPostalCode AS 'Delivery.PostalCode'
		  , DC.CityName AS'Delivery.CityName'
		  , C1.PostalAddressLine1 'Postal.AddressLine1'
		  , C1.PostalAddressLine2 'Postal.AddressLine2'
		  , C1.PostalPostalCode AS 'Postal.PostalCode'
		  , PC.CityName AS'Postal.CityName'
	   FROM 
		  [Sales].[Customers] C1 
		  LEFT JOIN [Application].[People] PC1 ON C1.PrimaryContactPersonID = PC1.PersonID
		  LEFT JOIN [Application].[Cities] DC ON C1.DeliveryCityID = DC.CityID
		  LEFT JOIN [Application].[Cities] PC ON C1.PostalCityID = PC.CityID
	   WHERE 
		  C1.CustomerID = C.CustomerID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
FROM [Sales].[Customers] C
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- Select Idaho City customers
SELECT *
FROM dbo.JSONIndexing
WHERE JSON_VALUE([CustomerData],'$.Postal.CityName') LIKE '%Idaho City%';
GO

-- Add computed column with index
ALTER TABLE dbo.JSONIndexing ADD Customer_City AS JSON_VALUE([CustomerData], '$.Postal.CityName');
CREATE INDEX IDX_Customer_City ON dbo.JSONIndexing(Customer_City);
GO

-- Repeat
SELECT *
FROM dbo.JSONIndexing
WHERE JSON_VALUE([CustomerData],'$.Postal.CityName') LIKE '%Idaho City%';
GO

-- Drop index 
DROP INDEX [IDX_Customer_City] ON [dbo].[JSONIndexing]
GO

-- FullText
CREATE FULLTEXT CATALOG FullTextCatalog AS DEFAULT;
CREATE FULLTEXT INDEX ON [dbo].[JSONIndexing]([CustomerData]) KEY INDEX PK_JSONIndexing ON FullTextCatalog;

SELECT [CustomerID], [CustomerData]
FROM dbo.JSONIndexing
WHERE CONTAINS([CustomerData],'NEAR(Name,"Idaho City")');

SELECT [CustomerID], [CustomerData]
FROM dbo.JSONIndexing
WHERE CONTAINS([CustomerData],'Huiting');

-- Clean

DROP TABLE dbo.JSONIndexing;
DROP FULLTEXT CATALOG FullTextCatalog
GO

/* Compare two table rows using JSON */

-- Master and model from SELECT * FROM sys.databases -- 86 columns!!!!
SELECT d1.[key], d1.[value] AS d1_value, d2.[value] AS d2_value  FROM
OPENJSON ((SELECT * FROM sys.databases WHERE database_id = 1 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER))
d1 INNER JOIN
OPENJSON ((SELECT * FROM sys.databases WHERE database_id = 3 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER))
d2 ON d1.[key] = d2.[key] 
WHERE d1.[value] <> d2.[value]


/* Processing data from a comma-separated list of values */

DECLARE @Ids AS VARCHAR(MAX) = '1,3,7,8,9,11';
SELECT value FROM OPENJSON('[' + @Ids + ']' )

DECLARE @Ids AS VARCHAR(MAX) = '1,3,7,8,9,11,';
SELECT value FROM OPENJSON('[' + @Ids + ']' )


USE AdventureWorks2017;
GO

/*Hash row value*/
SELECT
	P.[BusinessEntityID]
	, P.[PersonType]
	, P.[NameStyle]
	, P.[Title]
	, P.[FirstName]
	, P.[MiddleName]
	, P.[LastName]
	, P.[Suffix]
	, P.[EmailPromotion]
	, P.[AdditionalContactInfo]
	, ColumnHashCode =  HASHBYTES ('SHA2_512', (SELECT J.* FROM [Person].[Person] J WHERE J.BusinessEntityID = P.BusinessEntityID FOR JSON AUTO)) 
FROM 
	[Person].[Person] P
