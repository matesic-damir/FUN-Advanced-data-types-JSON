/* MS SQL JSON_MODIFY */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* JSON_MODIFY */

-- Adding a new JSON property

-- Adding currently presenting - 1 (number)
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
}';
PRINT JSON_MODIFY(@JSON_data, '$."Currently presenting"', 1)

-- Adding currently presenting - 1 (bool)
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
}';
PRINT JSON_MODIFY(@JSON_data, '$."Currently presenting"', CAST(1 AS BIT))

-- Adding currently presenting - using strict
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
}';
PRINT JSON_MODIFY(@JSON_data, 'strict $."Currently presenting"', CAST(1 AS BIT))

-- Adding MS SQL meetups - string
DECLARE @MeetupList NVARCHAR(256) = N'["New SQL 2016/2017 functions","SQL & JSON"]';
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
}';
PRINT JSON_MODIFY(@JSON_data, '$.Meetups', @MeetupList);

-- Adding MS SQL meetups - array
DECLARE @MeetupList NVARCHAR(256) = N'["New SQL 2016/2017 functions","SQL & JSON"]';
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
}';
PRINT JSON_MODIFY(@JSON_data, '$.Meetups', JSON_QUERY(@MeetupList));

-- Removing a JSON property

-- Removing FavoriteDrinks node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com",
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}]
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, '$.FavoriteDrinks', NULL);

-- Removing first meetup from array (null)
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, '$.Meetups[0]', NULL);

-- Removing  first meetup from array
DECLARE @MeetupList NVARCHAR(256) = N'["SQL & JSON"]';
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, '$.Meetups', JSON_QUERY(@MeetupList));

-- Updating the value of a JSON property

-- Change first array element in Meetups node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, '$.Meetups[0]', 'Something about new SQL functions');

-- Change first array element in non existing Lectures node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, '$.Lectures[0]', 'Something about new SQL functions');

-- Append an element in Meetups node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, 'append $.Meetups', 'Something about new SQL functions');

-- Append an element in non existing Lectures node ???
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, 'append $.Lectures', 'Something about new SQL functions');

-- Change first array element in non existing Lectures node - strict
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com"
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, 'strict $.Lectures[0]', 'Something about new SQL functions');

-- Update JSON property to NULL instead of remove - strict!
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com",
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}]
,"Meetups":["New SQL 2016/2017 functions","SQL & JSON"]}';
PRINT JSON_MODIFY(@JSON_data, 'strict $.FavoriteDrinks', NULL);

-- Multiple changes -> multiple calls

-- Add meetup list and remove FavoriteDrinks node
DECLARE @MeetupList NVARCHAR(256) = N'["New SQL 2016/2017 functions","SQL & JSON"]';
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BlogURL": "http:\/\/www.microsoft.com",
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}]
}';
PRINT JSON_MODIFY(JSON_MODIFY(@JSON_data, '$.Meetups', JSON_QUERY(@MeetupList)), '$.FavoriteDrinks', NULL);


-- REPLACE(REPLACE(.....