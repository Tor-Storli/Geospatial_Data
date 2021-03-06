USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_GeographyPOI]    Script Date: 9/23/2021 12:07:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Get_GeographyPOI](@GeoName VARCHAR(75))
AS
BEGIN
SELECT [ID]
      ,[Restaurant] AS [GeoName]
	  ,[Flag]
	  ,([Address] + ' <br/>' + [City] + ', ' + [State] + ' ' + [Zip] + ' <br/>'  + (CASE WHEN [Phone] IS NULL THEN ' ' ELSE [Phone] END))  AS [Description]
      ,[Lat] AS [Latitude]
      ,[Lon] AS [Longitude]
	  --,'latitude: ' + CAST([Lat] AS VARCHAR(20)) + ',' + 'longitude: ' + CAST([Lon]  AS VARCHAR(20)) As [Point]
	  ,('{"Lat":' + CAST([Lat] AS VARCHAR(20)) + ', ' + '"Lon":' + CAST([Lon]  AS VARCHAR(20)) + '}') As [Point]

  FROM [Geospatial].[dbo].[us_fast_food]
  WHERE [Restaurant] LIKE @GeoName;
END
GO
