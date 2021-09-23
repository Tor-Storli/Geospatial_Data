USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_GeoJson_ADW_SalesForce]    Script Date: 9/23/2021 12:07:53 PM ******/
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
											[ADW_SalesForce_ID] as 'properties.id',
											[FirstName] as 'properties.FirstName',
											[MiddleName] as 'properties.MiddleName',
											[LastName]  as 'properties.LastName',
											[JobTitle]  as 'properties.JobTitle',
											[PhoneNumber]  as 'properties.PhoneNumber',
											[PhoneNumberType]  as 'properties.PhoneNumberType',
											[EmailAddress]  as 'properties.EmailAddress',
											[EmailPromotion]  as 'properties.EmailPromotion',
											[AddressLine1]  as 'properties.AddressLine1',
											[City]  as 'properties.City',
											[StateProvinceName] as 'properties.StateProvinceName',
											[PostalCode] as 'properties.PostalCode',
											[CountryRegionName] as 'properties.CountryRegionName',
											[TerritoryName] as 'properties.TerritoryName',
											[TerritoryGroup] as 'properties.TerritoryGroup',
											[SalesYTD] as 'properties.SalesYTD',
											[SalesLastYear] as 'properties.SalesLastYear'
							  FROM (SELECT [ADW_SalesForce_ID]
										  ,[FirstName]
										  ,[MiddleName]
										  ,[LastName]
										  ,[JobTitle]
										  ,[PhoneNumber]
										  ,[PhoneNumberType]
										  ,[EmailAddress]
										  ,[EmailPromotion]
										  ,[AddressLine1]
										  ,[City]
										  ,[StateProvinceName]
										  ,[PostalCode]
										  ,[CountryRegionName]
										  ,[TerritoryName]
										  ,[TerritoryGroup]
										  ,[SalesYTD]
										  ,[SalesLastYear]
										  ,[Geography]
									  FROM [Geospatial].[dbo].[ADW_SalesForce]) P
							FOR JSON PATH);

	SELECT (@START_TAG + @QUERY_TAG + @END_TAG);


END;
GO
