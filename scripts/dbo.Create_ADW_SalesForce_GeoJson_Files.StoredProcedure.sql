USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[Create_ADW_SalesForce_GeoJson_Files]    Script Date: 10/8/2021 5:15:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Create_ADW_SalesForce_GeoJson_Files] 
AS
BEGIN
		DECLARE @filename VARCHAR(1000);
		DECLARE @SQL VARCHAR(8000) = ''

				BEGIN

					SET @filename = 'C:\tmp\json\ADW_SalesForce.json'
					
					SET @SQL = 'DECLARE @SQLOUT VARCHAR(8000) ' +
				               'SET @SQLOUT = ''bcp "EXEC [dbo].[usp_Get_GeoJson_ADW_SalesForce]" queryout "' + @filename + 
								'" -c -T -d Geospatial -S' + @@SERVERNAME + '''' +
								' PRINT @SQLOUT; EXEC master..xp_cmdshell @SQLOUT'
					PRINT(@SQL)
					EXEC(@SQL)
				END
		
END
GO
