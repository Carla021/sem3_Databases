SELECT * FROM Tests
SELECT * FROM Tables
SELECT * FROM TestTables
SELECT * FROM Views
SELECT * FROM TestViews
SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews
SELECT * FROM Events
SELECT * FROM Artists
SELECT * FROM EventsArtists
GO


CREATE OR ALTER VIEW ViewOneTable
AS
	SELECT * FROM Events
GO

CREATE OR ALTER VIEW ViewTwoTables
AS
	SELECT e.EventID, e.EventName, a.ArtistName
	FROM Events e
	INNER JOIN EventsArtists ea ON e.EventID = ea.EventID
	INNER JOIN Artists a ON ea.ArtistID = a.ArtistID
GO

CREATE OR ALTER VIEW ViewGroupBy
AS
	SELECT u.UserID, u.UserName, COUNT(e.EventID) AS EventCount
	FROM Users u
	LEFT JOIN AttendingStatus ast ON u.UserID = ast.UserID
	LEFT JOIN Events e ON ast.EventID = e.EventID
	GROUP BY u.UserID, u.UserName
GO

SELECT * FROM ViewOneTable
SELECT * FROM ViewTwoTables
SELECT * FROM ViewGroupBy
GO

CREATE OR ALTER PROCEDURE delete_table
	@no_of_rows INT,
	@table_name VARCHAR(30)
AS
BEGIN
	DECLARE @last_row INT

	IF @table_name='Events'
	BEGIN
		IF (SELECT COUNT(*) FROM Events)<@no_of_rows
		BEGIN
			PRINT('Too many rows to delete')
			RETURN 1
		END
		ELSE
		BEGIN
			SET @last_row = (SELECT MAX(eventID) FROM Events) - @no_of_rows

			DELETE FROM Events
			WHERE EventID>@last_row
		END
	END

	ELSE IF @table_name='Artists'
	BEGIN
		IF (SELECT COUNT(*) FROM Artists)<@no_of_rows
		BEGIN
			PRINT ('Too many rows to delete')
			RETURN 1
		END
		ELSE
		BEGIN
		IF (SELECT COUNT(*) FROM Artists)<@no_of_rows
		BEGIN
			PRINT ('Too many rows to delete')
			RETURN 1
		END
		ELSE
		BEGIN
			SET @last_row = (SELECT MAX(ArtistID) FROM Artists) - @no_of_rows

			DELETE FROM Artists
			WHERE ArtistID>@last_row
		END
	END
	END

	ELSE IF @table_name='EventsArtists'
	BEGIN
	IF (SELECT COUNT(*) FROM EventsArtists)<@no_of_rows
	BEGIN
		PRINT('Too many rows to delete')
		RETURN 1
	END
	ELSE
	BEGIN
		DELETE FROM EventsArtists
		WHERE EventID>=@no_of_rows
	END
	END

	ELSE
	BEGIN
		PRINT('Not a valid table name')
		RETURN 1
	END
END
GO

CREATE OR ALTER PROCEDURE insert_table
	@no_of_rows INT,
	@table_name VARCHAR(30)
AS
BEGIN
	DECLARE @input_id INT
	IF @table_name='Events'
	BEGIN
		SET @input_id = 100
		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO Events(EventID, EventName) VALUES (@input_id, 'Szighet')

			SET @input_id=@input_id+1
			SET @no_of_rows=@no_of_rows-1
		END
	END

	ELSE IF @table_name='Artists'
	BEGIN
		SET @input_id = 100
		PRINT(@input_id)
		DECLARE @fk INT
		SET @fk=(SELECT TOP 1 EventID FROM Events)
			WHILE @no_of_rows > 0
			BEGIN
				INSERT INTO Artists(ArtistID, EventID, ArtistName) VALUES (@input_id, @fk, 'Imagine Dragons')

				SET @input_id=@input_id+1
				SET @no_of_rows=@no_of_rows-1

			END
		END

	ELSE IF @table_name='EventsArtists'
	BEGIN
	-- SET @input_id = @no_of_rows 
	/*
	DECLARE @fk1 INT
	SET @fk1 = 100
	-- SET @fk1=(SELECT TOP 1 EventID FROM Events)

	DECLARE @fk2 INT
	SET @fk2 = 100
	-- SET @fk2=(SELECT TOP 1 ArtistID FROM Artists)
	*/

	INSERT INTO EventsArtists (EventID, ArtistID)
	SELECT Events.EventID, Artists.ArtistID
	FROM Events CROSS JOIN Artists

	/*
		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO EventsArtists(EventID, ArtistID) VALUES (@fk1, @fk2)
			
			-- SET @input_id = @input_id+1
			SET @no_of_rows = @no_of_rows-1
			SET @fk1 = @fk1+1
			SET @fk2 = @fk2+1

			-- PRINT(@input_id)
		END
	*/
	END

	ELSE
	BEGIN
		PRINT('Not a valid table name')
		RETURN 1
	END
END
GO

CREATE OR ALTER PROCEDURE select_view
	@view_name VARCHAR(30)
AS
BEGIN
	IF @view_name='ViewOneTable'
	BEGIN
		SELECT * FROM ViewOneTable
	END

	ELSE IF @view_name='ViewTwoTables'
	BEGIN
		SELECT * FROM ViewTwoTables
	END

	ELSE IF @view_name='ViewGroupBy'
	BEGIN
		SELECT * FROM ViewGroupBy
	END

	ELSE
	BEGIN
		PRINT('Not a valid view name')
		RETURN 1
	END
END
GO


DELETE FROM Tables

-- Reset identity seed for Tables
TRUNCATE TABLE Tables -- This removes all rows
DBCC CHECKIDENT ('Tables', RESEED, 1) -- Reset the identity seed to 0

INSERT INTO Tables VALUES ('Events'), ('Artists'), ('EventsArtists')
GO

SELECT * FROM Tables -- from 10

DELETE FROM Views
INSERT INTO Views VALUES ('ViewOneTable'), ('ViewTwoTables'), ('ViewGroupBy')
GO

SELECT * FROM Views -- from 16

DELETE FROM Tests
INSERT INTO Tests VALUES ('test_10'), ('test_100'), ('test_1000')
GO

SELECT * FROM Tests -- from 18


DELETE FROM TestViews
INSERT INTO TestViews(TestID, ViewID) VALUES (18, 16)
INSERT INTO TestViews(TestID, ViewID) VALUES (18, 17)
INSERT INTO TestViews(TestID, ViewID) VALUES (18, 18)
INSERT INTO TestViews(TestID, ViewID) VALUES (19, 16)
INSERT INTO TestViews(TestID, ViewID) VALUES (19, 17)
INSERT INTO TestViews(TestID, ViewID) VALUES (19, 18)
INSERT INTO TestViews(TestID, ViewID) VALUES (20, 16)
INSERT INTO TestViews(TestID, ViewID) VALUES (20, 17)
INSERT INTO TestViews(TestID, ViewID) VALUES (20, 18)
GO

SELECT * FROM TestViews

DELETE FROM TestTables
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (18, 10, 10, 1)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (18, 11, 10, 2)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (18, 12, 10, 3)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (19, 10, 100, 1)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (19, 11, 100, 2)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (19, 12, 100, 3)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (20, 10, 1000, 1)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (20, 11, 1000, 2)
INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (20, 12, 1000, 3)
GO

SELECT * FROM TestTables

DELETE FROM TestRuns
DELETE FROM TestRunTables
DELETE FROM TestRunViews
GO


CREATE OR ALTER PROCEDURE main_test
	@testID INT
AS
BEGIN
	INSERT INTO TestRuns VALUES ((SELECT Name FROM Tests WHERE TestID=@testID), GETDATE(), GETDATE())
	DECLARE @testRunID INT
	SET @testRunID=(SELECT MAX(TestRunID) FROM TestRuns)

	DECLARE @noOfRows INT
	DECLARE @tableID INT
	DECLARE @tableName VARCHAR(30)
	DECLARE @startAt DATETIME
	DECLARE @endAt DATETIME
	DECLARE @viewID INT
	DECLARE @viewName VARCHAR(30)

	DECLARE testDeleteCursor CURSOR FOR
	SELECT TableID, NoOfRows
	FROM TestTables
	WHERE TestID=@testID
	ORDER BY Position DESC

	OPEN testDeleteCursor

	FETCH NEXT
	FROM testDeleteCursor
	INTO @tableID, @noOfRows

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @tableName=(SELECT Name FROM Tables WHERE TableID=@tableID)

		EXEC delete_table @noOfRows, @tableName

		FETCH NEXT
		FROM testDeleteCursor
		INTO @tableID, @noOfRows
	END

	CLOSE testDeleteCursor
	DEALLOCATE testDeleteCursor

	DECLARE testInsertCursor CURSOR FOR
	SELECT TableID, NoOfRows 
	FROM TestTables
	WHERE TestID=@testID
	ORDER BY Position ASC

	OPEN testInsertCursor

	FETCH NEXT
	FROM testInsertCursor
	INTO @tableID, @noOfRows

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @tableName=(SELECT Name FROM Tables WHERE TableID=@tableID)

		SET @startAt=GETDATE()
		EXEC insert_table @noOfRows, @tableName
		SET @endAt=GETDATE()

		INSERT INTO TestRunTables VALUES (@testRunID, @tableID, @startAt, @endAt)

		FETCH NEXT
		FROM testInsertCursor
		INTO @tableID, @noOfRows
	END

	CLOSE testInsertCursor
	DEALLOCATE testInsertCursor

	DECLARE testViewCursor CURSOR FOR
	SELECT ViewID
	FROM TestViews
	WHERE TestID=@testID

	OPEN testViewCursor

	FETCH NEXT
	FROM testViewCursor
	INTO @viewID

	WHILE @@FETCH_STATUS=0
	BEGIN 
		SET @viewName=(SELECT Name FROM Views WHERE ViewID=@viewID)

		SET @startAt=GETDATE()
		exec select_view @viewName
		SET @endAt=GETDATE()

		INSERT INTO TestRunViews VALUES (@testRunID, @viewID, @startAt, @endAt)

		FETCH NEXT
		FROM testViewCursor
		INTO @viewID
	END

	CLOSE testViewCursor
	DEALLOCATE testViewCursor

	UPDATE TestRuns
	SET EndAt=GETDATE()
	WHERE TestRunID=@testRunID

END
GO

SELECT * FROM Events
DELETE FROM Events
WHERE EventID NOT IN (
	SELECT TOP 2 EventID
	FROM Events
	ORDER BY EventID
)

SELECT * FROM Artists
DELETE FROM Artists
WHERE ArtistID NOT IN (
	SELECT TOP 1 ArtistID
	FROM Artists
	ORDER BY ArtistID
)

SELECT * FROM EventsArtists
DELETE FROM EventsArtists

EXEC main_test 18
EXEC main_test 19
EXEC main_test 20

SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews
