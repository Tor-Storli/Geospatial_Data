USE [Geospatial]
GO
/****** Object:  StoredProcedure [dbo].[Create_County_Census_GeoJson_Files]    Script Date: 10/8/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Create_County_Census_GeoJson_Files] 
AS
BEGIN
		DECLARE @filename VARCHAR(1000);
		DECLARE @GeoName varchar(5);
		DECLARE @SQL VARCHAR(8000) = ''

		DECLARE PC_Cursor CURSOR
		FOR SELECT DISTINCT [State_Abbr]
			FROM [Geospatial].[dbo].[US_CENSUS_COUNTY_DATA_2019]
			WHERE State_Abbr IS NOT NULL;
			--AND State_Abbr = 'IL';

		OPEN PC_Cursor

		Fetch NEXT from PC_Cursor into @GeoName
		
		WHILE (@@FETCH_STATUS <> -1)
			
		BEGIN
			IF LEN(@GeoName) = 2
				BEGIN

		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
	--	SET NOCOUNT ON;

					SET @filename = 'C:\tmp\json\' + @GeoName + '_Counties_Census.json'
					
					SET @SQL = 'DECLARE @SQLOUT VARCHAR(8000) ' +
				               'SET @SQLOUT = ''bcp "EXEC dbo.usp_Get_GeoJson_Counties ' + 
							    @GeoName + '" queryout "' + @filename + 
								'" -c -T -d Geospatial -S' + @@SERVERNAME + '''' +
								' PRINT @SQLOUT; EXEC master..xp_cmdshell @SQLOUT'
				--	PRINT(@SQL)
					EXEC(@SQL)
				END

			FETCH NEXT FROM PC_Cursor into @GeoName
		END

		-- Close the cursor and remove reference to memmory allocationn
		CLOSE PC_Cursor
		DEALLOCATE PC_Cursor
		
END
GO
