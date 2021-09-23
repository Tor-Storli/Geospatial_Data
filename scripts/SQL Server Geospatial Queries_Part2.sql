/*********************************************

 Spatial Indexes:

 Please refer to these posts for more information:
	https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-indexes-overview?view=sql-server-ver15
	https://docs.microsoft.com/en-us/sql/t-sql/statements/create-spatial-index-transact-sql?view=sql-server-ver15
	https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-spatial-indexes/

*********************************************/
















/*********************************************
  GEOMETRY

 SQL:	STIntersects - WITHOUT INDEX
 QGIS:	Intersection
*********************************************/
USE [TestDB]
GO

/****** DROP GEOMETRY INDEX - IF IT EXISTS ******/
DROP INDEX [SPATIAL_us_zip_codes] ON [Geospatial].[us_zip_codes]
GO

/*****  RUN QUERY WITHOUT INDEX ******/
DECLARE @US_IL_Geometry Geometry = (SELECT [GEOMETRY] 
									 FROM [Geospatial].[dbo].[us_states] 
									 WHERE [statefp] = 17);

SELECT [geoid10], 
       [OGR_GEOMETRY]
FROM [TestDB].[Geospatial].[us_zip_codes]
WHERE [OGR_GEOMETRY].STIntersects(@US_IL_Geometry) = 1
GO


USE [TestDB]
GO

/*****  CREATE GEOMETRY INDEX ******/
CREATE SPATIAL INDEX [SPATIAL_us_zip_codes] ON [Geospatial].[us_zip_codes]
(
	[ogr_geometry]
)USING  GEOMETRY_GRID 
 WITH 
	(BOUNDING_BOX =(-180, -90, 180, 90), 
	 GRIDS =(LEVEL_1 = MEDIUM,
			 LEVEL_2 = MEDIUM,
			 LEVEL_3 = MEDIUM,
			 LEVEL_4 = MEDIUM), 
CELLS_PER_OBJECT = 16);
GO




/*****  RUN QUERY WITH INDEX ******/
DECLARE @US_IL_Geometry Geometry = (SELECT [GEOMETRY] 
									 FROM [Geospatial].[dbo].[us_states] 
									 WHERE [statefp] = 17);

SELECT [geoid10], 
       [OGR_GEOMETRY]
FROM [TestDB].[Geospatial].[us_zip_codes] --WITH(INDEX(SPATIAL_us_zip_codes))
WHERE [OGR_GEOMETRY].STIntersects(@US_IL_Geometry) = 1
GO






















/***************************************
  SQL:	STDifference and UnionAggregate
  QGIS:	Difference and Disolve
***************************************/
DECLARE @DIFFERENCE Geometry;

DECLARE @IL_NORTHEAST Geometry = (SELECT Geometry::UnionAggregate([Geometry])
										  FROM [Geospatial].[dbo].[us_counties]
										  WHERE [statefp] = 17
										  AND [countyfp] IN(007,111,097,037,089,043,031));

DECLARE @ILLINOIS_COUNTIES Geometry = (SELECT GEOMETRY::UnionAggregate([Geometry])
										 FROM [Geospatial].[dbo].[us_counties]
										 WHERE [statefp] = 17);
--Seperate and show difference
SELECT @IL_NORTHEAST
SELECT @ILLINOIS_COUNTIES
SELECT @ILLINOIS_COUNTIES.STDifference(@IL_NORTHEAST)

--Put it together again
SELECT @IL_NORTHEAST
UNION ALL
SELECT @ILLINOIS_COUNTIES.STDifference(@IL_NORTHEAST)

GO

















/*************************************************
--Reference system that are not measured in meters
**************************************************/
SELECT * FROM SYS.spatial_reference_systems
WHERE unit_of_measure <> 'metre'

/**************************
--Unit_of_measure for WGS84 
***************************/
SELECT * FROM SYS.spatial_reference_systems
WHERE [spatial_reference_id] = 4326;
GO
























/***************************************
  SQL:	Reduce
  QGIS:	Simplify
***************************************/

SELECT [Geography].STNumPoints() AS [GeoPoints],
	   [Geography]
FROM [Geospatial].[dbo].[us_states] 
WHERE[statefp] = 17;

--Tolerance is set to 5,000 meters
SELECT [Geography].Reduce(5000).STNumPoints() AS [GeoPointsReduced],
	   [Geography].Reduce(5000) AS [GeographyReduced]
FROM [Geospatial].[dbo].[us_states] 
WHERE[statefp] = 17;
GO






/**************************************************************

CONTINUE PART 5 (NO_INDEXES) of VIDEO FROM HERE:

***************************************************************/












--===========================================================
-- Create a table of Points for the State of Illinois shape file
--===========================================================
DECLARE @MaxRow int = (SELECT TOP 1 [GEOGRAPHY].STNumPoints()
					   FROM [Geospatial].[dbo].[us_states] 
					   WHERE[statefp] = 17);

DECLARE @US_IL_GEOGRAPHY GEOGRAPHY = (SELECT TOP 1 [GEOGRAPHY]
									  FROM [Geospatial].[dbo].[us_states] 
									  WHERE[statefp] = 17);

DECLARE @PointTable TABLE([RowNum] int, [Point] GEOGRAPHY);
DECLARE @Point GEOGRAPHY

DECLARE @CurrentRow int = 1;
BEGIN
	WHILE (@CurrentRow <= @MaxRow)
	BEGIN
		SELECT @Point = @US_IL_GEOGRAPHY.STPointN(@CurrentRow);
		INSERT INTO @PointTable([RowNum],[Point]) VALUES(@CurrentRow,@Point);
		SET @CurrentRow += 1;
	END

	SELECT [RowNum] AS [GeoName],
		   [Point].STAsText() AS PointWKT
	FROM @PointTable;
END

GO











--===========================================================
-- Display the state of Illinois Polygon
--===========================================================
DECLARE @MaxRow int = (SELECT TOP 1 [GEOGRAPHY].STNumPoints()
					   FROM [Geospatial].[dbo].[us_states] 
					   WHERE[statefp] = 17);

DECLARE @US_IL_GEOGRAPHY GEOGRAPHY = (SELECT TOP 1 [GEOGRAPHY]
									  FROM [Geospatial].[dbo].[us_states] 
									  WHERE[statefp] = 17);

DECLARE @PointTable TABLE([RowNum] int, [Point] GEOGRAPHY);
DECLARE @Point GEOGRAPHY

DECLARE @CurrentRow int = 1;
BEGIN
	WHILE (@CurrentRow <= @MaxRow)
	BEGIN
		SELECT @Point = @US_IL_GEOGRAPHY.STPointN(@CurrentRow);
		INSERT INTO @PointTable([RowNum],[Point]) VALUES(@CurrentRow,@Point);
		SET @CurrentRow += 1;
	END

	SELECT 'ILLINOIS' AS [GeoName], @US_IL_GEOGRAPHY
	UNION ALL
	SELECT CAST([RowNum] AS VARCHAR(50)) AS [GeoName], [Point].STBuffer(5000) 
	FROM @PointTable;
END

GO











--===========================================================
-- Simplify (Reduce) the number of points in the Polygon
-- Tolerance 5000 Meters
--===========================================================

DECLARE @MaxRow int = (SELECT TOP 1 [GEOGRAPHY].Reduce(5000).STNumPoints()
					   FROM [Geospatial].[dbo].[us_states] 
					   WHERE[statefp] = 17);

DECLARE @US_IL_GEOGRAPHY GEOGRAPHY = (SELECT TOP 1 [GEOGRAPHY].Reduce(5000)
									  FROM [Geospatial].[dbo].[us_states] 
									  WHERE[statefp] = 17);

DECLARE @PointTable TABLE([RowNum] int, [Point] GEOGRAPHY);
DECLARE @Point GEOGRAPHY

DECLARE @CurrentRow int = 1;
BEGIN
	WHILE (@CurrentRow <= @MaxRow)
	BEGIN
		SELECT @Point = @US_IL_GEOGRAPHY.STPointN(@CurrentRow);
		INSERT INTO @PointTable([RowNum],[Point]) VALUES(@CurrentRow,@Point);
		SET @CurrentRow += 1;
	END

	SELECT 'ILLINOIS' AS [GeoName], Null As [LatLong], @US_IL_GEOGRAPHY
	UNION ALL
	SELECT CAST([RowNum] AS VARCHAR(50)) AS [GeoName],[Point].STAsText() AS [LatLong], [Point].STBuffer(5000) 
	FROM @PointTable;

	SELECT [GEOMETRY] FROM [Geospatial].[dbo].[us_states] WHERE [statefp] = 17;
END

GO







--===============================================
-- Find Center Point of Illinois shape file
--===============================================

DECLARE @CenterPoint GEOGRAPHY = 
			(SELECT GEOGRAPHY::STGeomFromWKB([GEOMETRY].STCentroid().STAsBinary(),4326)
			 FROM [Geospatial].[dbo].[us_states]
			 WHERE [statefp] = 17);

SELECT 'ILLINOIS' AS [GeoName], @CenterPoint.STBuffer(15000) AS [GEOMETRY] 
FROM [Geospatial].[dbo].[us_states] WHERE [statefp] = 17
UNION ALL
SELECT 'ILLINOIS' AS [GeoName],[GEOGRAPHY] 
FROM [Geospatial].[dbo].[us_states] WHERE [statefp] = 17;
GO






















--===============================================
-- Create a bounding box around Illinois shape
--===============================================

DECLARE @CenterPoint GEOGRAPHY = 
			(SELECT GEOGRAPHY::STGeomFromWKB([GEOMETRY].STCentroid().STAsBinary(),4326)
			 FROM [Geospatial].[dbo].[us_states]
			 WHERE [statefp] = 17);

SELECT 'ILLINOIS' AS [GeoName], @CenterPoint.STBuffer(15000) AS [GEOMETRY] 
FROM [Geospatial].[dbo].[us_states] WHERE [statefp] = 17
UNION ALL
SELECT 'ILLINOIS' AS [GeoName],[GEOGRAPHY] 
FROM [Geospatial].[dbo].[us_states] WHERE [statefp] = 17;












--===================================
-- Disolve four states into one shape
--===================================
SELECT [name],[statefp],[Geometry]
FROM Geospatial.dbo.us_states 
WHERE [statefp] IN('17','55', '18','26')

SELECT 'Disolved' as [name], GEOMETRY::UnionAggregate([Geometry]) As [GeometryAgg]
FROM Geospatial.dbo.us_states 
WHERE [statefp] IN('17','55', '18','26')
GO













/****************************************
  Nearest Neighbor Search
*****************************************/

DECLARE @GreatAmericaEntrance Geography;
DECLARE @FastFoodSearchArea Geography;
DECLARE @MileinMeters int = 1609.334;
DECLARE @SearchZoneinMiles int = 3;

BEGIN
	SET @GreatAmericaEntrance = Geography::STPointFromText('POINT (-87.93622748016882  42.370812970954404)', 4326);
	SET @FastFoodSearchArea = @GreatAmericaEntrance.STBuffer(@SearchZoneinMiles * @MileinMeters)

	--Simple Filter Search
	;WITH FF_Restaurants AS 
		(SELECT [ID]
		  ,[Restaurant]
		  ,[Flag]
		  ,[Address]
		  ,[Geography].STDistance(@GreatAmericaEntrance) AS [Distance_Meters]
		  ,([Geography].STDistance(@GreatAmericaEntrance)/ @MileinMeters) AS [Distance_Miles]
		  ,[City]
		  ,[State]
		  ,[Zip]
		  ,[Phone]
		  ,[Lat]
		  ,[Lon]
		  ,[Geography].STBuffer(50) AS [Geography]
	  FROM [Geospatial].[dbo].[us_fast_food]
	  WHERE [City] = 'Gurnee'
	  AND [Geography].Filter(@FastFoodSearchArea) = 1)
	  SELECT TOP 10 * From FF_Restaurants ORDER BY [Distance_Meters] 
END

GO

/***************  END OF SCRIPT *************************/