USE EventManagementDB
GO

-- Modify Column Type
CREATE OR ALTER PROCEDURE ModifyColumnType
AS 
BEGIN
	ALTER TABLE Events
	ALTER COLUMN EventRestrictions NVARCHAR(150);
END;
GO

EXEC ModifyColumnType
GO

-- Revert Modify Column Type
CREATE OR ALTER PROCEDURE RevertModifyColumnType
AS BEGIN
	ALTER TABLE Events
	ALTER COLUMN EventRestrictions NVARCHAR(100);
END;
GO

EXEC RevertModifyColumnType
GO


-- Add Column
CREATE OR ALTER PROCEDURE AddColumn
AS BEGIN
	ALTER TABLE Events
	ADD EventDescription NVARCHAR(50);
END;
GO

EXEC AddColumn
GO

-- Revert Add Column
CREATE OR ALTER PROCEDURE RevertAddColumn
AS
BEGIN
	ALTER TABLE Events
	DROP COLUMN EventDescription;
END;
GO

EXEC RevertAddColumn
GO


-- Add Default Constraint
CREATE OR ALTER PROCEDURE AddDefaultConstraint
AS
BEGIN
	ALTER TABLE Users
	ADD CONSTRAINT DF_UserEmail DEFAULT 'user_name@gmail.com' FOR UserEmail;
END;
GO

EXEC AddDefaultConstraint
GO

-- Revert Add Default Constraint
CREATE OR ALTER PROCEDURE RevertAddDefaultConstraint
AS
BEGIN
	ALTER TABLE Users
	DROP CONSTRAINT DF_UserEmail;
END;
GO

EXEC RevertAddDefaultConstraint
GO


-- Add / Remove Primary Key
CREATE OR ALTER PROCEDURE DropPrimaryKey
AS
BEGIN
	ALTER TABLE Sponsors
	DROP CONSTRAINT pk_Sponsors
END
GO

EXEC DropPrimaryKey
GO

-- Revert Add Primary Key
CREATE OR ALTER PROCEDURE RevertDropPrimaryKey
AS
BEGIN
	ALTER TABLE Sponsors
	ADD CONSTRAINT pk_Sponsors PRIMARY KEY (SponsorID);
END
GO

EXEC RevertDropPrimaryKey
GO


-- ADD Candidate Key
CREATE OR ALTER PROCEDURE AddCandidateKeyEventCategories
AS
BEGIN
	ALTER TABLE EventCategories
	ADD CONSTRAINT UniqueIDEventCategory UNIQUE(EventID, CategoryID);
END;
GO

EXEC AddCandidateKeyEventCategories
GO

-- Revert Add Candidate Key
CREATE OR ALTER PROCEDURE RevertAddCandidateKeyEventCategories
AS
BEGIN
	ALTER TABLE EventCategories
	DROP CONSTRAINT UniqueIDEventCategory;
END;
GO

EXEC RevertAddCandidateKeyEventCategories
GO


-- Add Foreign Key
CREATE OR ALTER PROCEDURE AddForeignKeyEventsArtists
AS
BEGIN
	ALTER TABLE EventsArtists
	ADD CONSTRAINT FK_EventsArtists_EventsID FOREIGN KEY (EventID) REFERENCES Events(EventID);
END;
GO

EXEC AddForeignKeyEventsArtists
GO

-- Revert Add Foreign Key
CREATE OR ALTER PROCEDURE RevertAddForeignKeyEventsArtists
AS
BEGIN
	ALTER TABLE EventsArtists
	DROP CONSTRAINT FK_EventsArtists_EventsID;
END;
GO

EXEC RevertAddForeignKeyEventsArtists
GO


-- Create Table
CREATE OR ALTER PROCEDURE CreateOrdersTable
AS
BEGIN
	CREATE TABLE Orders (
		OrderID INT PRIMARY KEY,
		Quantity INT
	)
END
GO

EXEC CreateOrdersTable
GO

-- Revert Create Table
CREATE OR ALTER PROCEDURE RevertCreateOrdersTable
AS
BEGIN
	DROP TABLE IF EXISTS Orders;
END;
GO

EXEC RevertCreateOrdersTable
GO


CREATE TABLE VersionHistory
(
	VERSION INT
)
INSERT INTO VersionHistory VALUES (0) -- first version

CREATE TABLE ProcedureTable
(
	DoProcedure VARCHAR(100),
	UndoProcedure VARCHAR(100),
	Version INT PRIMARY KEY
)
GO

INSERT INTO ProcedureTable(DoProcedure, UndoProcedure, Version)
VALUES ('ModifyColumnType', 'RevertModifyColumnType', 1),
('AddColumn', 'RevertAddColumn', 2),
('AddDefaultConstraint', 'RevertAddDefaultConstraint', 3),
('AddPrimaryKey', 'RevertAddPrimaryKey', 4),
('AddCandidateKeyTickets', 'RevertAddCandidateKeyTickets', 5),
('AddForeignKey', 'RevertAddForeignKey', 6),
('CreateOrdersTable', 'RevertCreateOrdersTable', 7)

UPDATE ProcedureTable
SET 
    DoProcedure = 'DropPrimaryKey',
    UndoProcedure = 'RevertDropPrimaryKey'
WHERE 
    Version = 4;

UPDATE ProcedureTable
SET 
    DoProcedure = 'AddCandidateKeyEventCategories',
    UndoProcedure = 'RevertAddCandidateKeyEventCategories'
WHERE 
    Version = 5;

UPDATE ProcedureTable
SET 
    DoProcedure = 'AddForeignKeyEventsArtists',
    UndoProcedure = 'RevertAddForeignKeyEventsArtists'
WHERE 
    Version = 6;

GO
CREATE OR ALTER PROCEDURE goToVersion(@version INT)
AS
BEGIN
	DECLARE @currentVersion INT
	SET @currentVersion = (SELECT version FROM VersionHistory) -- get the current version of the ds
	IF @version < 0 OR @version > 7
		BEGIN
			PRINT 'Version number bust be in [0,7] range.'
			RETURN
		END
	ELSE
		IF @version = @currentVersion
			BEGIN
				PRINT 'Current version...'
				RETURN
			END
		ELSE
		DECLARE @currentProcedure NVARCHAR(50)
		IF @currentVersion < @version -- if is lower, exec the DOProcedures
			BEGIN
				WHILE @currentVersion < @version
					BEGIN
						PRINT 'Current version: ' + CONVERT(varchar(10), @currentVersion)
						SET @currentProcedure = (SELECT DoProcedure
												FROM ProcedureTable
												WHERE Version = @currentVersion + 1)
						EXEC(@currentProcedure)
						SET @currentVersion = @currentVersion + 1
					END
			END
		ELSE -- if we get higher, exec the UndoProcedures
			IF @currentVersion > @version
				BEGIN 
					WHILE @currentVersion > @version
						BEGIN
							PRINT 'Current version: ' + CONVERT(varchar(10), @currentVersion)
							SET @currentProcedure = (SELECT UndoProcedure
													FROM ProcedureTable
													WHERE version = @currentVersion)
							EXEC(@currentProcedure)
							SET @currentVersion = @currentVersion - 1
						END
				END
		UPDATE VersionHistory
			SET VERSION = @currentVersion
		PRINT 'Current version updated!'
		PRINT 'Reached desired version: ' + CONVERT(varchar(10), @currentVersion)
END

-- SELECT * FROM ProcedureTable

GO
EXEC goToVersion 7
EXEC goToVersion 7
EXEC goToVersion 4
EXEC goToVersion 3
EXEC goToVersion 2
EXEC goToVersion 1
EXEC goToVersion 0
EXEC goToVersion -1


select * from VersionHistory;

select * from events;