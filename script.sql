USE [master]
GO
/****** Object:  Database [BSDB]    Script Date: 11/29/2020 12:58:46 PM ******/
CREATE DATABASE [BSDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BSDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BSDB.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BSDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BSDB_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BSDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BSDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BSDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BSDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BSDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BSDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BSDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [BSDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BSDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [BSDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BSDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BSDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BSDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BSDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BSDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BSDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BSDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BSDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BSDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BSDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BSDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BSDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BSDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BSDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BSDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BSDB] SET RECOVERY FULL 
GO
ALTER DATABASE [BSDB] SET  MULTI_USER 
GO
ALTER DATABASE [BSDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BSDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BSDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BSDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'BSDB', N'ON'
GO
USE [BSDB]
GO
/****** Object:  StoredProcedure [dbo].[GetAllCommentsByPost]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetAllCommentsByPost] 
	-- Add the parameters for the stored procedure here
	@PostId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TEMP_Table TABLE
	(
	    commentid INT ,
		 postid INT ,
		 
		CommentDesc varchar(128) NULL,
		UserId varchar(128) NULL,
		Name varchar(128) NULL,
		likeyes INT ,
		 likeno INT ,
		 localtime varchar(128) NULL
	);

	insert into @TEMP_Table
	(
		commentid,
		 postid,
		 
		CommentDesc,
		UserId,
		Name ,
		likeyes,
		 likeno ,
		 localtime 
	)
    select commentid,postid,CommentDesc,UserId,userName as Name,sum(likeyes) as likeyes,sum(likeno) as likeno
	,(select convert(varchar, (SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),SetTime) ), 0)) as localtime
	  from
	(select c.commentid,c.postid,c.CommentDesc,c.UserId,u.Name as userName,count(v.islike) as likeyes,0 as likeno
	,max(c.SetTime) as settime
	from Comment c
	join UserInfo u on u.UserId=c.UserId
	join vote v on c.commentid = v.commentid
	where PostId =@PostId
	and v.islike=1
	group by c.commentid,c.postid,c.CommentDesc,c.UserId,u.Name
	union
	select c.commentid,c.postid,c.CommentDesc,c.UserId,u.Name as userName,0 as likeyes,count(v.islike) as likeno
	,max(c.SetTime) as settime
	from Comment c
	join UserInfo u on u.UserId=c.UserId
	join vote v on c.commentid = v.commentid
	where PostId =@PostId
	and v.islike=0
	group by c.commentid,c.postid,c.CommentDesc,c.UserId,u.Name) tbl1
	GROUP BY  commentid,postid,CommentDesc,UserId,userName,SetTime

	DECLARE @COUNT INT = (SELECT COUNT(*) FROM @TEMP_Table)
	IF(@COUNT>0)
	BEGIN
		SELECT * FROM @TEMP_Table
	END
	ELSE
	BEGIN
	select c.*, u.Name,(select convert(varchar, (SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),c.SetTime) ), 0))
       AS LocalTime , 0 AS LIKEYES , 0 AS LIKENO from Comment c 
	join UserInfo u on u.UserId=c.UserId
	where PostId =@PostId
	END
END


GO
/****** Object:  StoredProcedure [dbo].[GetInformationByName]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetInformationByName] 
	@Name varchar(150)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from UserInfo where Name=@Name
END

GO
/****** Object:  StoredProcedure [dbo].[GetPostByID]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetPostByID] 
	@Id int,
	@page int,
	@itemsperpage int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT COUNT(*) OVER () as totalPages,* , (select convert(varchar, (SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),p.SetTime) ), 100))
       AS LocalTime from Post p 
	join UserInfo u on p.UserId=u.UserId
	where p.UserId=@Id
	order by p.PostId asc
	OFFSET (( @page -1)* @itemsPerPage) ROWS FETCH NEXT  @itemsPerPage  ROWS ONLY ;
END

GO
/****** Object:  Table [dbo].[Comment]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Comment](
	[CommentId] [int] IDENTITY(1,1) NOT NULL,
	[PostId] [int] NULL,
	[CommentDesc] [varchar](150) NULL,
	[UserId] [int] NULL,
	[SetTime] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Comment] PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Post]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Post](
	[PostId] [int] IDENTITY(1,1) NOT NULL,
	[PostDesc] [varchar](150) NULL,
	[UserId] [int] NULL,
	[SetTime] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED 
(
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserInfo]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserInfo](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](150) NOT NULL,
	[Type] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Vote]    Script Date: 11/29/2020 12:58:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vote](
	[VoteId] [int] IDENTITY(1,1) NOT NULL,
	[CommentId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[SetTime] [datetimeoffset](7) NOT NULL,
	[islike] [bit] NOT NULL,
 CONSTRAINT [PK_Vote] PRIMARY KEY CLUSTERED 
(
	[VoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Comment] ON 

INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (1, 1, N'This is a comment', 2, CAST(0x07D031E4B117DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (2, 1, N'This is the 2nd Comment', 3, CAST(0x0790EA90B917DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (3, 1, N'This is the 3rd comment', 4, CAST(0x07B0D708C117DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (4, 2, N'I am not a good commenter ', 3, CAST(0x07F0D128D517DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (5, 2, N'This is another bad commentor ', 4, CAST(0x073038D2E417DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (6, 2, N'Hello Post', 5, CAST(0x0710FEF1EC17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (7, 3, N'this is boring', 3, CAST(0x0770748EF217DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (8, 3, N'wow', 4, CAST(0x07508043FC17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (9, 4, N'this is wrong', 5, CAST(0x076099C20318DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (10, 4, N'this is not wrong', 2, CAST(0x07506A3A0C18DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (11, 4, N'ok bye', 3, CAST(0x07B023B71118DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (12, 4, N'this is 123', 4, CAST(0x0770FACF1B18DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (13, 10, N'THIS IS LAST COMMENT', 6, CAST(0x071018CEE933DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Comment] ([CommentId], [PostId], [CommentDesc], [UserId], [SetTime]) VALUES (14, 9, N'WAIT A MINITUE', 6, CAST(0x07406A6A0C34DD410B0000 AS DateTimeOffset))
SET IDENTITY_INSERT [dbo].[Comment] OFF
SET IDENTITY_INSERT [dbo].[Post] ON 

INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (1, N'Hello World', 1, CAST(0x07A07A071C17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (2, N'This is the 1st Test', 1, CAST(0x07A002322D17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (3, N'Default Text', 1, CAST(0x07C0842F3317DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (4, N'This is a Test Text', 1, CAST(0x07B06D135317DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (5, N'Another Text', 1, CAST(0x071029E35817DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (6, N'This is a another Text', 1, CAST(0x0790E3336417DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (7, N'Hello from here ', 1, CAST(0x07E047706E17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (8, N'Another Hello World', 1, CAST(0x07705A987B17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (9, N'Hello from DB', 1, CAST(0x07103DF58C17DD410B0000 AS DateTimeOffset))
INSERT [dbo].[Post] ([PostId], [PostDesc], [UserId], [SetTime]) VALUES (10, N'This is last', 1, CAST(0x0790AEFB9417DD410B0000 AS DateTimeOffset))
SET IDENTITY_INSERT [dbo].[Post] OFF
SET IDENTITY_INSERT [dbo].[UserInfo] ON 

INSERT [dbo].[UserInfo] ([UserId], [Name], [Type]) VALUES (1, N'admin', N'1')
INSERT [dbo].[UserInfo] ([UserId], [Name], [Type]) VALUES (2, N'naim', N'2')
INSERT [dbo].[UserInfo] ([UserId], [Name], [Type]) VALUES (3, N'user', N'2')
INSERT [dbo].[UserInfo] ([UserId], [Name], [Type]) VALUES (5, N'naidm', N'2')
INSERT [dbo].[UserInfo] ([UserId], [Name], [Type]) VALUES (6, N'shawon', N'2')
SET IDENTITY_INSERT [dbo].[UserInfo] OFF
SET IDENTITY_INSERT [dbo].[Vote] ON 

INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (2, 1, 2, CAST(0x07B03BAB3C18DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (3, 1, 3, CAST(0x076038F04018DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (4, 1, 4, CAST(0x07E0294D4518DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (5, 1, 5, CAST(0x07907ADD4F18DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (6, 2, 2, CAST(0x07105AC05318DD410B0000 AS DateTimeOffset), 0)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (7, 2, 3, CAST(0x0780309E5718DD410B0000 AS DateTimeOffset), 0)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (8, 2, 4, CAST(0x0750A30C5B18DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (9, 2, 5, CAST(0x07C0EB4E6018DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (10, 3, 2, CAST(0x0700BEAAF618DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (11, 4, 3, CAST(0x0790CD3BFD18DD410B0000 AS DateTimeOffset), 0)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (12, 5, 4, CAST(0x0770748D0119DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (13, 6, 5, CAST(0x07E0FDCD0819DD410B0000 AS DateTimeOffset), 0)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (14, 7, 4, CAST(0x07803A581019DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (15, 8, 4, CAST(0x07F08D2A1619DD410B0000 AS DateTimeOffset), 1)
INSERT [dbo].[Vote] ([VoteId], [CommentId], [UserId], [SetTime], [islike]) VALUES (16, 9, 2, CAST(0x07B0A3581534DD410B0000 AS DateTimeOffset), 1)
SET IDENTITY_INSERT [dbo].[Vote] OFF
ALTER TABLE [dbo].[Comment] ADD  CONSTRAINT [DF_Comment_SetTime]  DEFAULT (getutcdate()) FOR [SetTime]
GO
ALTER TABLE [dbo].[Post] ADD  CONSTRAINT [DF_Post_SetTime]  DEFAULT (getutcdate()) FOR [SetTime]
GO
ALTER TABLE [dbo].[Vote] ADD  CONSTRAINT [DF_Vote_SetTime]  DEFAULT (getutcdate()) FOR [SetTime]
GO
USE [master]
GO
ALTER DATABASE [BSDB] SET  READ_WRITE 
GO
