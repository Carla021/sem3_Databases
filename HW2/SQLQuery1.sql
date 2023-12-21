USE EventManagementDB;
GO


-- Insert data

INSERT INTO Users (UserID, UserName, UserEmail, UserPassword)
VALUES (1, 'Mirea Carla', 'cmirea003@gmail.com', 'carlita1234');

INSERT INTO Users (UserID, UserName, UserEmail, UserPassword)
VALUES (5, 'Diaconu Ruxandra', 'rdiaconu@gmail.com', 'ruxiii1234');

INSERT INTO Users (UserID, UserName, UserEmail, UserPassword)
VALUES (7, 'Stirbu Carla', 'scarla@gmail.com', 'carluta34');

INSERT INTO Users (UserID, UserName, UserEmail, UserPassword)
VALUES (8, 'Mitrea Viorel', 'mviorel04@gmail.com', 'mitrica007');

-- Insert data into Events table (violating referential integrity constraint)
INSERT INTO Events (EventID, EventName, EventRestrictions, EventDate, EventLocation)
VALUES (1, 'Summer Concert', '18+', '2024-08-02 20:00:00', 'Bucharest');

INSERT INTO Events (EventID, EventName, EventRestrictions, EventDate, EventLocation)
VALUES (2, 'Rock Concert', '18+', '2024-07-02 22:00:00', 'Cluj-Napoca');

-- Again, inserting the same value for the PK, violating referential integrity constraint
-- INSERT INTO Events (EventID, EventName, EventRestrictions, EventDate, EventLocation)
-- VALUES (1, 'Summer Concert', '18+', '2024-08-02 20:00:00', 'Bucharest');

INSERT INTO Artists (ArtistID, ArtistName, ArtistSpecialisation, EventID)
VALUES (1, 'Irina Rimes', 'Pop', 1);

INSERT INTO Categories(CategoryID, CategoryName, CategoryDescription)
VALUES (1, 'Concert', 'Pop summer concert');

INSERT INTO EventCategories(EventID, CategoryID)
VALUES (1, 1);

INSERT INTO Tickets (TicketID, Price, UserID, EventID)
VALUES (1, 100, 1, 1);

INSERT INTO Reviews (ReviewID, Content, Rating, UserID)
VALUES (3, 'Good!', 5, 1);

INSERT INTO Reviews (ReviewID, Content, Rating, UserID)
VALUES (2, 'Very bad!', 1, 5);

INSERT INTO Reviews (ReviewID, Content, Rating, UserID)
VALUES (4, 'OK!', 4, 8);

INSERT INTO Tickets (TicketID, Price, UserID, EventID)
VALUES (9, 100, 1, 1);


-- Update data

UPDATE Users
SET UserName = 'Stoian Vlad'
Where UserID = 1;

UPDATE Events
SET EventLocation = 'Cluj-Napoca'
WHERE EventID = 1;

UPDATE Tickets
SET Price = 50
WHERE EventID = 1 AND UserID IS NOT NULL;

UPDATE Reviews
SET Content = 'Bad actually..'
WHERE UserID <> 2 AND Content LIKE 'Good%'; 

UPDATE Reviews
SET Content = 'No no, actually good.'
WHERE UserID BETWEEN 4 AND 6;


-- Delete data

DELETE FROM Artists
WHERE ArtistID < 2;

DELETE FROM Reviews
WHERE UserID = 1 OR UserID <= 3;

DELETE FROM Users
WHERE UserID >= 8;

DELETE FROM Users
WHERE UserID > 6;