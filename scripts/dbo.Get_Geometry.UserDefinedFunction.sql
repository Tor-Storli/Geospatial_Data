USE [Geospatial]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_Geometry]    Script Date: 9/23/2021 12:07:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Get_Geometry] (@SalesRegion varchar(50))
RETURNS Geometry
AS 
BEGIN
Declare @Geometry Geometry
	SELECT @Geometry = [GEOMETRY] FROM [Geospatial].[dbo].[world_countries] WHERE [country] = @SalesRegion;
	RETURN @Geometry 
END;
GO
