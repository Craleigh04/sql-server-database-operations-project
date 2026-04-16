USE [Insurance]
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 2/25/2025 10:20:40 AM ******/

CREATE TABLE [dbo].[Customer](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[FName] [nvarchar](50) NOT NULL,
	[LName] [nvarchar](50) NOT NULL,
	[DOB] [date] NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Rate]    Script Date: 2/25/2025 10:20:47 AM ******/

CREATE TABLE [dbo].[Rate](
	[RateID] [int] IDENTITY(1,1) NOT NULL,
	[BegAge] [int] NOT NULL,
	[EndAge] [int] NOT NULL,
	[Rate] [decimal](9, 2) NULL,
 CONSTRAINT [PK_Rate] PRIMARY KEY CLUSTERED 
(
	[RateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



