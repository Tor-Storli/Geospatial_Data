/*
Fast Foods:
============  
https://hub.arcgis.com/datasets/UrbanObservatory::fast-food-restaurants/explore?layer=1&location=30.309946%2C-100.162460%2C4.00&showTable=true

Target Stores:
=============
https://www.kaggle.com/ben1989/target-store-dataset?select=targets.csv

World Airports:
===========
https://openflights.org/data.html#airport


*/

















USE [TestDB]
GO

---------------------------------------------------
-- Find All Target Stores Stores in Lake County, IL
-- Add a 500 meter buffer around the points
-- So it is easy to spot on the spatial display
---------------------------------------------------
SELECT W.[FormattedAddress]
      ,W.[Geography].STBuffer(500) As [Geography]
   FROM [Geospatial].[Target_Stores] W,
  (SELECT [Geography] FROM [TestDB].[Geospatial].[Target_Stores]
   WHERE County = 'Lake'
   AND SubDivision = 'IL'
   ) C
  WHERE W.[Geography].STIntersects(C.[Geography]) = 1

 GO 



















------------------------------------------
--Find All Airports in the Lake County, IL
------------------------------------------
DECLARE @LakeCountyIL Geography;

SET @LakeCountyIL = (SELECT [Geography]
					 FROM [TestDB].[Geospatial].[us_il_counties]
                     WHERE NAME = 'LAKE');

SELECT A.[Airport_ID]
      ,A.[Name]
      ,A.[City]
      ,A.[Country]
      ,A.[IATA]
      ,A.[ICAO]
      ,A.[Latitude]
      ,A.[Longitude]
      ,A.[Altitude]
      ,A.[Timezone]
      ,A.[DST]
      ,A.[Tz_database_time_zone]
      ,A.[Type]
  FROM [TestDB].[Geospatial].[World_Airports] A
  WHERE Type = 'airport'
  AND Country = 'United States'
  AND CITY = 'Chicago'
  AND A.[Geography].STIntersects(@LakeCountyIL) = 1;
  GO




















---------------------------------------------------------------
-- Distance (Straight Line) From Oslo to the White House in DC
-- Go to Google and search like this:  "distance white house to Oslo Norway"
---------------------------------------------------------------

DECLARE @Oslo geography = 'POINT(10.735167958162599 60.008613307377935)';
DECLARE @WhiteHouseDC geography = 'POINT(-76.80389221878407 39.00853751204748)';

SELECT  ROUND(@Oslo.STDistance(@WhiteHouseDC),0) As [DistanceInMeters],
	   ROUND((@Oslo.STDistance(@WhiteHouseDC)/1609.344),0) As [DistanceInMiles];




















--------------------------------------------------------
--Find the distance from Navy Pier, Chicago to 
-- O'HARE INTL Airport, Chicago (Direct line)  
--------------------------------------------------------
DECLARE @NavyPierChicago Geography;

SET @NavyPierChicago = geography::STGeomFromText('POINT(-87.60583478315172 41.891971216030065)', 4326);

SELECT A.[Airport_ID]
      ,A.[Name]
	  ,ROUND(A.[Geography].STDistance(@NavyPierChicago),0) As [DistanceInMeters]
      ,ROUND((A.[Geography].STDistance(@NavyPierChicago) * (1/1609.344)),2) As [DistanceInMiles]
      ,A.[City]
      ,A.[Country]
      ,A.[IATA]
      ,A.[ICAO]
      ,A.[Latitude]
      ,A.[Longitude]
      ,A.[Altitude]
      ,A.[Timezone]
      ,A.[DST]
      ,A.[Tz_database_time_zone]
      ,A.[Type]
  FROM [TestDB].[Geospatial].[World_Airports] A
  WHERE A.IATA = 'ORD'
  ORDER BY (A.[Geography].STDistance(@NavyPierChicago) * (1/1609.344)) Asc;
  GO
  






--------------------------------------------------------
--Find All Train Stations within 5 miles of Navy Pier
--------------------------------------------------------
DECLARE @NavyPierChicago Geography;

SET @NavyPierChicago = geography::STGeomFromText('POINT(-87.60583478315172 41.891971216030065)', 4326);

SELECT A.[Airport_ID]
      ,A.[Name]
	  ,ROUND(A.[Geography].STDistance(@NavyPierChicago),0) As [DistanceInMeters]
      ,ROUND((A.[Geography].STDistance(@NavyPierChicago) * (1/1609.344)),2) As [DistanceInMiles]
      ,A.[City]
      ,A.[Country]
      ,A.[Latitude]
      ,A.[Longitude]
      ,A.[Altitude]
      ,A.[Timezone]
      ,A.[DST]
      ,A.[Tz_database_time_zone]
      ,A.[Type]
  FROM [TestDB].[Geospatial].[World_Airports] A
  WHERE A.Type = 'station'
  AND A.[Geography].STDistance(@NavyPierChicago) <= (10 * 1609.344)
  ORDER BY (A.[Geography].STDistance(@NavyPierChicago) * (1/1609.344)) Asc;
  GO
  


















----------------------------------------------------
-- Find All Target Stores within
-- a 5 Mile radius of O'Haire INTL Airport, Chicago
---------------------------------------------------
DECLARE @OHareChicago Geography;

SET @OHareChicago = (SELECT [Geography]  
					 FROM [TestDB].[Geospatial].[World_Airports] 
                     WHERE IATA = 'ORD');

SELECT [FormattedAddress],
       ROUND([Geography].STDistance(@OHareChicago),0) As [DistanceInMeters],
       ROUND(([Geography].STDistance(@OHareChicago) * (1/1609.344)),2) As [DistanceInMiles],
       [Geography].STBuffer(1000)
  FROM [TestDB].[Geospatial].[Target_Stores] W
  WHERE [Geography].STDistance(@OHareChicago) <= (5 * 1609.344)  
  ORDER BY ([Geography].STDistance(@OHareChicago) * (1/1609.344)) Asc;















---------------------------------------------------
--Find All zip codes that intersects, Touches and 
--that are Within Mason County, IL
---------------------------------------------------
DECLARE @geometry Geometry = (SELECT Top 1 [Geometry] FROM [TestDB].[Geospatial].[us_il_counties]
							   WHERE [name] = 'Mason')

SELECT  @geometry

--Intersects
SELECT Z.[geoid10], Z.[ogr_Geometry] FROM [TestDB].[Geospatial].[us_zip_codes] Z
WHERE Z.[ogr_Geometry].STIntersects(@geometry) = 1
UNION ALL
SELECT 'Mason' AS [geoid10], @geometry AS [ogr_Geometry];

--Within
SELECT Z.[geoid10], Z.[ogr_Geometry] FROM [TestDB].[Geospatial].[us_zip_codes] Z
WHERE Z.[ogr_Geometry].STWithin(@geometry) = 1
UNION ALL
SELECT 'Mason' AS [geoid10], @geometry AS [ogr_Geometry];

--Touches
SELECT Z.[geoid10], Z.[ogr_Geometry] FROM [TestDB].[Geospatial].[us_zip_codes] Z
WHERE Z.[ogr_Geometry].STTouches(@geometry) = 1
UNION ALL
SELECT 'Mason' AS [geoid10], @geometry AS [ogr_Geometry];
GO




/***************  END OF SCRIPT *************************/