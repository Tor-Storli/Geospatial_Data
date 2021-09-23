USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[Create_ADW_SalesForce_GeoJson_Files]    Script Date: 9/23/2021 12:07:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Create_ADW_SalesForce_GeoJson_Files] 
AS
BEGIN
		DECLARE @filename VARCHAR(1000);
		DECLARE @GeoName varchar(5);
		DECLARE @SQL VARCHAR(8000) = ''

		DECLARE PC_Cursor CURSOR
		FOR SELECT DISTINCT [State_Abbr]
			FROM [Geospatial].[dbo].[US_CENSUS_COUNTY_DATA_2019]
			WHERE State_Abbr IS NOT NULL
			AND State_Abbr IN('IL', 'MI');
		
		OPEN PC_Cursor

		Fetch NEXT from PC_Cursor into @GeoName
		
		WHILE (@@FETCH_STATUS <> -1)
			
		BEGIN
			IF LEN(@GeoName) = 2
				BEGIN

					SET @filename = 'C:\tmp\json\ADW_SalesForce.json'
					
					SET @SQL = 'DECLARE @SQLOUT VARCHAR(8000) ' +
				               'SET @SQLOUT = ''bcp "EXEC [dbo].[usp_Get_GeoJson_ADW_SalesForce] ' + 
							    '" queryout "' + @filename + 
								'" -c -T -d Geospatial -S' + @@SERVERNAME + '''' +
								' PRINT @SQLOUT; EXEC master..xp_cmdshell @SQLOUT'
					EXEC(@SQL)
				END

			FETCH NEXT FROM PC_Cursor into @GeoName
		END

		-- Close the cursor and remove reference to memmory allocationn
		CLOSE PC_Cursor
		DEALLOCATE PC_Cursor
		
END
GO
