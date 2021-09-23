/***************************
Get the geography of Hungary
****************************/
SELECT  [ogr_fid]
      ,[GEOMETRY]
      ,[country]
  FROM [Geospatial].[dbo].[world_countries]
  WHERE [country] = 'Hungary'

























/***************************
 What geography type is Hungary
****************************/
  SELECT [country]
        ,[Geometry].STGeometryType() As [GeometryType] 
  FROM [Geospatial].[dbo].[world_countries]
  WHERE [country] = 'Hungary';


























/***************************************************************
  What geography Reference system is Us State - Illinois using
  The STSrid returns the SRID for a geography or geometry instance.
******************************************************************/
SELECT [Geography].STSrid As [SRID]
FROM [Geospatial].[dbo].[us_states]
WHERE [statefp] = 17;


























/*********************************************************************************** 
 The STNumGeometries functions return the number of elements in a geography instance. 
************************************************************************************/
SELECT [Geometry].STNumGeometries() As [STNumGeometries]
	  ,[Geometry]
	  ,[Geometry].STGeometryType() As [GeometryType] 
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary';


SELECT [Geometry].STNumGeometries() As [STNumGeometries]
      ,[Geometry]
	  ,[Geometry].STGeometryType() As [GeometryType] 
FROM [Geospatial].[dbo].[us_states]
WHERE [name] = 'Alaska';

GO



















/***********************
 Envelope and ConvexHull
************************/
SELECT [Geometry].STConvexHull()
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary'
UNION ALL
SELECT [Geometry].STEnvelope()
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary'
UNION ALL
SELECT [Geometry]
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary';
GO








































/*****************************************************************
 Get First and Last lat and longs from Geometry and Geography Polygon

  STPointN - Geometry polygon for Hungary
 *****************************************************************************/
SELECT [Geometry].STPointN(1).STY As [Latitude],
       ([Geometry].STPointN(1).STX) As [Longitude]
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary';



 /*****************************************************************************
  Get First and Last lat and longs from Geography Polygon

 
 STNumPoints and STPointN - Geography polygon for Hungary
  *****************************************************************************/

DECLARE @LastPoint int = (SELECT TOP 1 [GEOGRAPHY].STNumPoints()
					      FROM [Geospatial].[dbo].[world_countries]
						  WHERE [country] = 'Hungary');


DECLARE @geographyFirst geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

SELECT 'First Point' AS [Point],
		@geographyFirst.STPointN(1).Lat As [Latitude],
       (@geographyFirst.STPointN(1).Long) As [Longitude]
	   UNION ALL
SELECT 'Last Point' AS [Point],
		@geographyFirst.STPointN(@LastPoint).Lat As [Latitude],
       (@geographyFirst.STPointN(@LastPoint).Long) As [Longitude]
GO























/****************************************************************************************************
Reduce:

This function is used to simplify a geography instance by reducing the number of points in the 
instance. The function expects a single parameter – tolerance, which is measured using the linear unit 
of the geography coordinate system used. For WGS84 the linear distance unit is measured in meters.
For Example:

Let us simplify the shape presentation for Hungary, by using a tolerance parameter of 5,000 meters. 
To do so, we run the following query:
*****************************************************************************************************/
SELECT  GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid().STNumPoints() As [OriginalNumPoints]
	   ,GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid().Reduce(5000).STNumPoints() As [ReducedNumPoints]
FROM [Geospatial].[dbo].[world_countries]
WHERE [country] = 'Hungary';
GO

















/**********************************************************
 Reducing the number of latitude-longitude value pair points 
 for the country of Hungary. 
 First - No Reduction applied - 314 points
***********************************************************/
DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

DECLARE @MaxRow int = (SELECT Top 1 @geography.STNumPoints() As [GeoNumberofPoints] 
					   FROM [Geospatial].[dbo].[world_countries]
					   WHERE [country] = 'Hungary'); 



DECLARE @PointTbl TABLE([RowNum] Int,[Point] geography); 
DECLARE @CurrentRow int;
Declare @Point geography;
BEGIN
	SET @CurrentRow = 1;
	WHILE (@CurrentRow <= @MaxRow)
	BEGIN
		SELECT @Point = @geography.STPointN(@CurrentRow);
		INSERT INTO @PointTbl([RowNum],[Point]) Values(@CurrentRow, @Point);
		SET @CurrentRow = @CurrentRow + 1
	END
	Select 'Hungary' As [GeoName], @geography
	UNION ALL 
	Select	CAST([RowNum] As varchar(50)) As [Geoname], Point.STBuffer(5000) FROM @PointTbl;
END
GO

/**********************************************************
 Reducing the shape instance – tolerance 5,000 meters
 Reduction Hungary - 50 ponts (Tolerance parameter set to 5,000 meters)
 **********************************************************/
DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid().Reduce(5000) 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

DECLARE @MaxRow1 int = (SELECT Top 1 @geography.Reduce(5000).STNumPoints() As [GeoNumberofPoints] 
						 FROM [Geospatial].[dbo].[world_countries]
							  WHERE [country] = 'Hungary'); 


DECLARE @PointTbl1 TABLE([RowNum] Int,[Point] geography); 
DECLARE @CurrentRow1 int;
Declare @Point1 geography;
BEGIN
	SET @CurrentRow1 = 1;
	WHILE (@CurrentRow1 <= @MaxRow1)
	BEGIN
		SELECT @Point1 = @geography.STPointN(@CurrentRow1);
		INSERT INTO @PointTbl1([RowNum],[Point]) Values(@CurrentRow1, @Point1);
		SET @CurrentRow1 = @CurrentRow1 + 1
	END
	Select 'Hungary' As [GeoName], @geography
	UNION ALL 
	Select	CAST([RowNum] As varchar(50)) As [Geoname], Point.STBuffer(5000) FROM @PointTbl1;
END
GO




/*************************************************************************************
Here is how to list all the individual WKT Points that make up the the Hungary polygon
**************************************************************************************/
DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

DECLARE @MaxRow int = (SELECT Top 1 @geography.STNumPoints() As [GeoNumberofPoints] 
					   FROM [Geospatial].[dbo].[world_countries]
					   WHERE [country] = 'Hungary'); 

DECLARE @PointTbl TABLE([RowNum] Int,[Point] geography); 

DECLARE @CurrentRow int;
Declare @Point geography;
BEGIN
	SET @CurrentRow = 1;

	WHILE (@CurrentRow <= @MaxRow)
	BEGIN
		SELECT @Point = @geography.STPointN(@CurrentRow);
		INSERT INTO @PointTbl([RowNum],[Point]) Values(@CurrentRow, @Point);
		SET @CurrentRow = @CurrentRow + 1
	END

	Select CAST([RowNum] As varchar(50)) As [Geoname],[Point].STAsText() As PointWKT 
FROM @PointTbl;

END
GO




/**********************************************
--Envelope, East, West, Center, North and South
***********************************************/
;WITH CTE_GEO
	AS(SELECT [country]
			 ,(MIN([Geometry].STEnvelope().STPointN(1).STX) ) as [west]
			 ,(MIN([Geometry].STEnvelope().STPointN(1).STY) )as [south]  
			 ,(MAX([Geometry].STEnvelope().STPointN(3).STX) ) as [east]
			 ,(MAX([Geometry].STEnvelope().STPointN(3).STY) ) as [north]	
	  FROM [Geospatial].[dbo].[world_countries]
	  WHERE [country] = 'Hungary'
	  GROUP BY [country])
  SELECT [Geometry].STEnvelope() AS [Envelope]
		,[Geometry].STCentroid().STAsText() As [Centroid]
        ,[Geometry].STCentroid().STBuffer(10) As [Centroid]
	    ,CTE_GEO.[west]
		,CTE_GEO.[south]  
		,CTE_GEO.[east]
	    ,CTE_GEO.[north]	
  FROM [Geospatial].[dbo].[world_countries] W, CTE_GEO
  WHERE W.[country] = CTE_GEO.[country]
GO









/**********************************************************
 Centroid Polygon
 What geography type is Hungary
**********************************************************/
DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

  SELECT 'Hungary' AS [country]
        ,@geography.STGeometryType() As [GeometryType] 
GO

DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'Hungary'); 

DECLARE @CenterPoint geography = (SELECT GEOGRAPHY::STGeomFromWKB([Geometry].STCentroid().STAsBinary(),4326) As [Geography]
								  FROM [Geospatial].[dbo].[world_countries] WHERE [country] = 'Hungary');

SELECT 'Hungary' AS [country], 'C' As GeoDescription, @CenterPoint.STBuffer(5000) As [Geography] 
UNION ALL
SELECT 'Hungary' AS [country], 'C' As GeoDescription, @geography
GO







/**********************************************************
   Centroid MultiPolygon
   What geography type is the United States
 **********************************************************/

 DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'United States'); 

  SELECT 'United States' AS [country]
        ,@geography.STGeometryType() As [GeometryType] 
GO

DECLARE @geography geography = (SELECT Top 1 GEOGRAPHY::STGeomFromWKB([Geometry].STAsBinary(),4326).MakeValid() 
								FROM [Geospatial].[dbo].[world_countries]
								WHERE [country] = 'United States'); 

DECLARE @CenterPoint geography = (SELECT GEOGRAPHY::STGeomFromWKB([Geometry].STCentroid().STAsBinary(),4326) As [Geography]
								  FROM [Geospatial].[dbo].[world_countries] WHERE [country] = 'United States');

SELECT 'C' AS [country], @CenterPoint.STBuffer(50000) As [Geography] 
FROM [Geospatial].[dbo].[world_countries] WHERE [country] = 'United States'
UNION ALL
SELECT 'United States' AS [country], @geography
GO





/***************************
 Union Aggregate Polygons
 ***************************/
SELECT [name], [Geometry] As [GeometryAgg]
FROM Geospatial.dbo.us_states WHERE [statefp] IN('17','55', '18','26')

SELECT 'Aggregated' AS [name], GEOMETRY::UnionAggregate([Geometry]) As [GeometryAgg]
FROM Geospatial.dbo.us_states WHERE [statefp] IN('17','55', '18','26')









/***********************
 Inspect Geometry Type
 *********************/
SELECT ogr_fid,region, division, statefp, [name], 
	   [GEOMETRY].STNumPoints() AS [Number_of_Points],
       [GEOMETRY].STGeometryType() as [type], 
	   [GEOMETRY] 
FROM [Geospatial].[dbo].[us_states]
ORDER BY [name]

/***********************
 Inspect Geography Type
 *********************/
SELECT ogr_fid,region, division, statefp, [name], 
	   [GEOGRAPHY].STNumPoints() AS [Number_of_Points],
	   [GEOGRAPHY].STIsValid() as [IsValid],
       [GEOGRAPHY].STGeometryType() as [type], 
	   [GEOGRAPHY] 
FROM [Geospatial].[dbo].[us_states]
ORDER BY [name]
















/***********************************************************
 Create a 3 mile radius around O'Hare Airport ILLINOIS, USA
 Convert Between Geography and Geometry
 ************************************************************/
  SELECT GEOMETRY::STGeomFromWKB([Geography].STAsBinary(),4326) AS [Geometry]
  FROM
		  (SELECT GEOGRAPHY::STGeomFromText('POINT(' + [Longitude] + ' ' + [Latitude] + ')', 4326).STBuffer(3 * 1609.344) AS [Geography]
		  FROM [TestDB].[Geospatial].[US_Airports]
		  WHERE [IATA] like 'ORD'
		  AND Country = 'United States') X

  UNION ALL

  SELECT [Geometry]
  FROM [Geospatial].[dbo].[airports]
  WHERE [loc_id] like 'ORD'
  GO

/*
   UPDATE [TestDB].[Geospatial].[US_Airports]
   SET [Geography] = GEOGRAPHY::STGeomFromText('POINT(' + [Longitude] + ' ' + [Latitude] + ')', 4326).MakeValid()
   WHERE [Longitude] IS NOT NULL
   AND [Latitude] IS NOT NULL
   AND Country = 'United States'
*/

   SELECT  [Airport_ID]
      ,[Name]
      ,[City]
      ,[Country]
      ,[IATA]
      ,[ICAO]
      ,[Latitude]
      ,[Longitude]
	  ,[Geography].STGeometryType() As [GeomType]
      ,[Geography]
      ,[Altitude]
      ,[Timezone]
      ,[DST]
      ,[Tz_database_time_zone]
      ,[Type]
      ,[Source]
  FROM [TestDB].[Geospatial].[US_Airports]
  WHERE [Country] = 'United States';


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
	Area Calculation - Geometry
****************************************/

  SELECT TOP (1000) [ogr_fid]
      ,[GEOMETRY]
      ,[objectid]
      ,[name]
      ,[feattype]
      ,[mnfc]
      ,[loc_id]
      ,[shape_leng]
      ,[shape_area]
	  ,[GEOMETRY].STArea() As [CALC_AREA]
  FROM [Geospatial].[dbo].[airports]
  WHERE loc_id = 'ORD'
  GO

/***************************************
	Area Calculation - Geography
    https://en.wikipedia.org/wiki/Germany
****************************************/

SELECT [ogr_fid]
      ,[country]
	  ,[Geography].STArea() AS [Area]
	  ,ROUND(([Geography].STArea()/1000000),2)  AS [Area_sqr_kilometers]
	  ,ROUND(([Geography].STArea() * 0.00000038610),2)  AS [Area_sqr_miles]
	  ,[GEOMETRY]
  FROM [Geospatial].[dbo].[world_countries]
  WHERE [country] = 'Germany'
  GO


  /***************  END OF SCRIPT *************************/