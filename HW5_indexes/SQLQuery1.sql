DROP TABLE TableC
DROP TABLE TableB
DROP TABLE TableA
GO

CREATE TABLE TableA
(
	aid INT PRIMARY KEY,
	a2 INT UNIQUE,
	name VARCHAR(20)
)
GO

CREATE TABLE TableB
(
	bid INT PRIMARY KEY,
	b2 INT
)
GO

CREATE TABLE TableC
(
	cid INT PRIMARY KEY,
	aid INT FOREIGN KEY REFERENCES TableA(aid),
	bid INT FOREIGN KEY REFERENCES TableB(bid)
)
GO

SELECT * FROM TableA
SELECT * FROM TableB
SELECT * FROM TableC
GO

--retrieve information from sys.indexes system catalog view within a SQL Server database
SELECT name FROM sys.indexes WHERE name LIKE 'TA%' OR name LIKE 'TB%' OR name LIKE 'TC%'

DELETE FROM TableC
DELETE FROM TableB
DELETE FROM TableA

DECLARE @i INT=0
DECLARE @rand INT
DECLARE @fk1 INT
DECLARE @fk2 INT
WHILE @i<150
BEGIN
	SET @rand = @i * 2
	INSERT INTO TableA VALUES (@i, @rand, CONCAT('table', @rand))
	INSERT INTO TableB VALUES (@i, RAND()*@rand)

	SET @fk1=(SELECT TOP 1 aid FROM TableA ORDER BY NEWID())
	SET @fk2=(SELECT TOP 1 bid FROM TableB ORDER BY NEWID())
	INSERT INTO TableC VALUES (@i,@fk1,@fk2)

	SET @i=@i+1
END
GO

--a
--clustered index scan
SELECT * FROM TableA ORDER BY aid

--clustered index seek
SELECT * FROM TableA WHERE aid < 60

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'TA_name_index')
	DROP INDEX TA_name_index ON TableA
GO
--include a2 in the index's leaf level (not part of the key)
CREATE NONCLUSTERED INDEX TA_name_index ON TableA(name) INCLUDE (a2)
GO

/*
IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'TA_a2_index')
	DROP INDEX TA_a2_index ON TableA
GO
CREATE NONCLUSTERED INDEX TA_a2_index ON TableA(a2)
GO
*/

--nonclustered index scan
SELECT name FROM TableA ORDER BY a2

--nonclustered index seek
SELECT name FROM TableA WHERE name LIKE 'table2%'

--key lookup
SELECT name, a2 FROM TableA WHERE a2=164
GO


--b.
SELECT * FROM TableB WHERE b2=3

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'TB_b2_index')
	DROP INDEX TB_b2_index ON TableB
GO
CREATE NONCLUSTERED INDEX TB_b2_index ON TableB(b2)
GO


--c.
DROP INDEX TC_bid_index ON TableC
CREATE NONCLUSTERED INDEX TC_bid_index ON TableC(bid)
GO


CREATE OR ALTER VIEW twoTablesView
AS
	SELECT C.cid, C.bid, B.b2
	FROM TableB B
	INNER JOIN TableC C ON C.bid=B.bid
GO

SELECT * FROM twoTablesView
GO

DROP INDEX TC_cid_index ON TableC
CREATE NONCLUSTERED INDEX TC_cid_index ON TableC(cid)


/*
CREATE OR ALTER VIEW allTablesView AS
	SELECT C.cid, A.aid, B.bid FROM TableC C
	INNER JOIN TableA A ON C.aid = A.aid
	INNER JOIN TableB B on C.bid = B.bid
GO

SELECT * FROM allTablesView
*/