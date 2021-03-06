USE [Geospatial]
GO
/****** Object:  Table [dbo].[US_CENSUS_COUNTY_DATA_2019]    Script Date: 10/8/2021 7:04:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[US_CENSUS_COUNTY_DATA_2019](
	[FIPS] [int] NOT NULL,
	[State_Abbr] [nvarchar](50) NOT NULL,
	[statefp] [nvarchar](2) NULL,
	[State] [nvarchar](100) NULL,
	[intptlat] [nvarchar](12) NULL,
	[intptlon] [nvarchar](12) NOT NULL,
	[County] [nvarchar](50) NOT NULL,
	[People_in_poverty] [int] NOT NULL,
	[pct_People_in_poverty] [float] NULL,
	[Less_than_high_school_diploma_2015_19] [int] NULL,
	[high_school_diploma_only_2015_19] [int] NULL,
	[Some_college_or_associate_degree_2015_19] [int] NULL,
	[Bachelor_degree_or_higher_2015_19] [int] NULL,
	[Percent_of_adults_with_less_than_a_high_school_diploma_2015_19] [float] NULL,
	[Percent_of_adults_with_a_high_school_diploma_only_2015_19] [float] NULL,
	[Percent_of_adults_completing_some_college_or_associate_degree_2015_19] [float] NULL,
	[Percent_of_adults_with_a_bachelor_s_degree_or_higher_2015_19] [float] NULL,
	[Pop_Estimate_2019] [float] NULL,
	[Net_Pop_Change_2019] [float] NULL,
	[Births_2019] [float] NULL,
	[Deaths_2019] [float] NULL,
	[Rate_Birth_2019] [float] NULL,
	[Rate_Death_2019] [float] NULL,
	[Geography] [geography] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
