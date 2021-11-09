/* Read JSON data in MS SQL */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* OPENJSON with default schema */

USE [WideWorldImporters];
GO
-- Not well formated JSON
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name: "John Doe",
"BlogURL": "http:\\blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data);
GO

-- Good example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data);

-- Help Function
CREATE OR ALTER FUNCTION dbo.GetJSONDataType
(
    @JSONDataType TINYINT
)
RETURNS VARCHAR(32)
AS
BEGIN
    RETURN CASE
        WHEN @JSONDataType = 0 THEN 'null'
        WHEN @JSONDataType = 1 THEN 'string'
        WHEN @JSONDataType = 2 THEN 'int'
        WHEN @JSONDataType = 3 THEN 'true/false'
        WHEN @JSONDataType = 4 THEN 'array'
        WHEN @JSONDataType = 5 THEN 'object'
    END
END

-- Again
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data);

-- Selecting "Parents" node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Parents');

-- Selecting non existing "Friends" node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Friends');

-- Selecting non existing "Friends" node, with strict option
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, 'strict $.Friends');

-- Selecting Favorite drinks node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.FavoriteDrinks');

-- Spaces in the key part
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data);

-- Wrong path
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Favorite drinks');

-- Correct path
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$."Favorite drinks"');









































/* OPENJSON with explicit schema */
-- Example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents NVARCHAR(MAX) '$.Parents' AS JSON
) Data;

-- Not specified AS JSON
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks',
    Parents NVARCHAR(MAX) '$.Parents' 
) Data;

-- Wrong data type in AS JSON columns
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] VARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents VARCHAR(MAX) '$.Parents' AS JSON
) Data;

-- Get favorite drink details -- nested hierarchy
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents NVARCHAR(MAX) '$.Parents' AS JSON
) Data
CROSS APPLY OPENJSON([Favorite drinks])
WITH
(
    Name NVARCHAR(256) '$.Name',
    Drink NVARCHAR(256) '$.Drink'
)DrinkData;





























/* JSON_VALUE */

-- Example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT
JSON_VALUE(@JSON_data, '$.Name') AS Name,
JSON_VALUE(@JSON_data, '$.BlogURL') AS BlogURL,
JSON_VALUE(@JSON_data, '$.Spouse') AS Spouse,
JSON_VALUE(@JSON_data, '$.BornAfterWoodstock') AS BornAfterWoodstock,
JSON_VALUE(@JSON_data, '$.FavoriteDrinks[0].Name') AS FavoriteDrink,
JSON_VALUE(@JSON_data, '$.NonExistingNode') AS NonExistingNode,
JSON_VALUE(@JSON_data, '$.Parents') AS Parents;

-- Example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT
JSON_VALUE(@JSON_data, '$.Name') AS Name,
JSON_VALUE(@JSON_data, '$.BlogURL') AS BlogURL,
JSON_VALUE(@JSON_data, '$.Spouse') AS Spouse,
JSON_VALUE(@JSON_data, '$.FavoriteDrinks[0].Name') AS FavoriteDrink,
JSON_VALUE(@JSON_data, 'strict $.NonExistingNode') AS NonExistingNode;


-- Large JSON - property value or string more than 4000
DECLARE @LargeJSON NVARCHAR(MAX) = CONCAT('{"data":"', REPLICATE('0',4096), '",}')
SELECT
    JSON_VALUE(@LargeJSON, '$.data') AS LargeData;

-- Large JSON - property value or string more than 4000 strict
DECLARE @LargeJSON NVARCHAR(MAX) = CONCAT('{"data":"', REPLICATE('0',4096), '",}')
SELECT
    JSON_VALUE(@LargeJSON, 'strict $.data') AS LargeData;






/* JSON_QUERY */

DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT
    JSON_QUERY(@JSON_data, '$.Name') AS Name
    , JSON_QUERY(@JSON_data, '$.BornAfterWoodstock') AS BornAfterWoodstock
    , JSON_QUERY(@JSON_data, '$.FavoriteColors') AS FavoriteColors 
    , JSON_QUERY(@JSON_data, '$.FavoriteColors[1]') AS SecondColor

-- strict
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\\www.microsoft.com",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteColors": ["Red", "Purple", "Green"]
}';
SELECT
    JSON_QUERY(@JSON_data, 'strict $.Name') AS Name
    , JSON_QUERY(@JSON_data, 'strict $.BornAfterWoodstock') AS BornAfterWoodstock
    , JSON_QUERY(@JSON_data, 'strict $.FavoriteColors') AS FavoriteColors 
    , JSON_QUERY(@JSON_data, 'strict $.FavoriteColors[1]') AS SecondColor
