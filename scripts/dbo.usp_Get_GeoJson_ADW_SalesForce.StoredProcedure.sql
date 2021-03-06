USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_GeoJson_ADW_SalesForce]    Script Date: 10/8/2021 5:15:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Get_GeoJson_ADW_SalesForce]
AS
BEGIN
DECLARE @START_TAG VARCHAR(100);
DECLARE @QUERY_TAG VARCHAR(MAX);
DECLARE @END_TAG VARCHAR(5) = '}';


    SET @START_TAG = '{ "type": "FeatureCollection", "features":';

	SET @QUERY_TAG = (SELECT 'Feature' as [type],
						   JSON_QUERY([dbo].[geography2json](P.[Geography] )) as [geometry],
											[id] as 'properties.id',									
											[CountryRegionName] as 'properties.CountryRegionName',
											[TerritoryName] as 'properties.TerritoryName',
											[TerritoryGroup] as 'properties.TerritoryGroup',
											[SalesYearToDate] as 'properties.SalesYearToDate',
											[SalesLastYear] as 'properties.SalesLastYear',
											[SalesYTD] as 'properties.SalesYTD',
											[SalesLY] as 'properties.SalesLY'
							  FROM   (SELECT ROW_NUMBER() OVER (ORDER BY X.[TerritoryName]) as [id],
											X.[CountryRegionName],
											X.[TerritoryName],
											X.[TerritoryGroup],
											X.[SalesYearToDate],
											X.[SalesLastYear],
											X.[SalesYTD],
											X.[SalesLY],
											G.[Geography]
								  FROM
								 (SELECT [CountryRegionName]
										,[TerritoryName]
										,[TerritoryGroup]
										,FORMAT(SUM([SalesYTD]), 'C0') AS [SalesYearToDate]
										,FORMAT(SUM([SalesLastYear]), 'C0') AS [SalesLastYear]
										,SUM([SalesYTD]) AS [SalesYTD]
										,SUM([SalesLastYear]) AS [SalesLY]
									FROM [Geospatial].[dbo].[ADW_SalesForce]
									GROUP BY [CountryRegionName]
											,[TerritoryName]
											,[TerritoryGroup]) X
								  INNER JOIN  (SELECT GT.[TerritoryName], 
													  GT.[Geography]
											   FROM 
											   (SELECT ROW_NUMBER() OVER (PARTITION BY [TerritoryName] ORDER BY [TerritoryName]) as [id],
													  [TerritoryName], 
													  [Geography]
											   FROM [Geospatial].[dbo].[ADW_SalesForce]) GT
											   WHERE GT.[id] = 1) G
								  ON X.[TerritoryName] = G.[TerritoryName]
								  ) P
							FOR JSON PATH);

	SELECT (@START_TAG + @QUERY_TAG + @END_TAG);


END;
GO
