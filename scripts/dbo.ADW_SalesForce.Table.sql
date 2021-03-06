USE [Geospatial]
GO
/****** Object:  Table [dbo].[ADW_SalesForce]    Script Date: 10/8/2021 7:04:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADW_SalesForce](
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[JobTitle] [nvarchar](50) NOT NULL,
	[PhoneNumber] [nvarchar](25) NULL,
	[PhoneNumberType] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailPromotion] [int] NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvinceName] [nvarchar](50) NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL,
	[CountryRegionName] [nvarchar](50) NOT NULL,
	[TerritoryName] [nvarchar](50) NULL,
	[TerritoryGroup] [nvarchar](50) NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[Geometry] [geometry] NULL,
	[Geography] [geography] NULL,
	[ADW_SalesForce_ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_ADW_SalesForce] PRIMARY KEY CLUSTERED 
(
	[ADW_SalesForce_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
