USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[usp_Get_GeoJson_Counties]    Script Date: 10/8/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Get_GeoJson_Counties](@GeoName VARCHAR(5))
AS
BEGIN
DECLARE @START_TAG VARCHAR(100);
DECLARE @QUERY_TAG VARCHAR(MAX);
DECLARE @END_TAG VARCHAR(5) = '}';


    SET @START_TAG = '{ "type": "FeatureCollection", "features":';

	SET @QUERY_TAG = (SELECT 'Feature' as [type],
						    JSON_QUERY([dbo].[geography2json](P.[Geography] )) as [geometry],
											[FIPS] as 'properties.id',
											[State_Abbr] as 'properties.state_abbr',
											[State] as 'properties.state',
											[County] as 'properties.county',
											--[intptlat] as 'properties.viewportlat',
											--[intptlon] as 'properties.viewportlong',
											[People_in_poverty] as 'properties.People_in_poverty',
											[pct_People_in_poverty] as 'properties.pct_People_in_poverty',
											[Less_than_high_school_diploma_2015_19] as 'properties.Less_than_high_school_diploma',
											[high_school_diploma_only_2015_19] as 'properties.high_school_diploma_only',
											[Some_college_or_associate_degree_2015_19] as 'properties.college_or_associate_degree',
											[Bachelor_degree_or_higher_2015_19] as 'properties.Bachelor_degree_or_higher',
											[Percent_of_adults_with_less_than_a_high_school_diploma_2015_19] as 'properties.Pct_adults_less_than_a_high_school_diploma',
											[Percent_of_adults_with_a_high_school_diploma_only_2015_19] as 'properties.Pct_adults_high_school_diploma_only',
											[Percent_of_adults_completing_some_college_or_associate_degree_2015_19] as 'properties.Pct_adults_some_college_or_associate_degree',
											[Percent_of_adults_with_a_bachelor_s_degree_or_higher_2015_19] as 'properties.Pct_adults_bachelor_degree_or_higher',
											[Pop_Estimate_2019] as 'properties.Population_Estimate_2019',
											[Net_Pop_Change_2019] as 'properties.Net_Pop_Change_2019',
											[Births_2019] as 'properties.Births_2019',
											[Deaths_2019] as 'properties.Deaths_2019',
											[Rate_Birth_2019] as 'properties.Rate_Birth_2019',
											[Rate_Death_2019] as 'properties.Rate_Death_2019'

							FROM (SELECT [FIPS]
								  ,[State_Abbr]
								  ,[State]
								  ,[County]
								  ,[People_in_poverty]
								  ,[pct_People_in_poverty]
								  ,[Less_than_high_school_diploma_2015_19]
								  ,[high_school_diploma_only_2015_19]
								  ,[Some_college_or_associate_degree_2015_19]
								  ,[Bachelor_degree_or_higher_2015_19]
								  ,[Percent_of_adults_with_less_than_a_high_school_diploma_2015_19]
								  ,[Percent_of_adults_with_a_high_school_diploma_only_2015_19]
								  ,[Percent_of_adults_completing_some_college_or_associate_degree_2015_19]
								  ,[Percent_of_adults_with_a_bachelor_s_degree_or_higher_2015_19]
								  ,[Pop_Estimate_2019]
								  ,[Net_Pop_Change_2019]
								  ,[Births_2019]
								  ,[Deaths_2019]
								  ,[Rate_Birth_2019]
								  ,[Rate_Death_2019]
								  ,[Geography]
							  FROM [Geospatial].[dbo].[US_CENSUS_COUNTY_DATA_2019]
							  WHERE [State_Abbr] = @GeoName) P
							FOR JSON PATH);

	SELECT (@START_TAG + @QUERY_TAG + @END_TAG);


END;
GO
