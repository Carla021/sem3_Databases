USE EventManagementDB;
GO

-- Using UNION ALL
SELECT EventName FROM Events WHERE EventDate > '2024-01-01'
UNION ALL
SELECT ArtistName FROM Artists WHERE ArtistSpecialisation = 'Pop';

-- Using UNION (OR)
SELECT UserName FROM Users WHERE UserEmail LIKE '%gmail.com'
UNION
SELECT Content FROM Reviews WHERE Content = 'Very bad!' OR Content = 'Good!';


-- Using INTERSECT (intersection)
-- find the events that have both reviews and tickets associated with them
SELECT EventID, EventName
FROM Events
WHERE EventID IN (
	SELECT EventID
	FROM Tickets
	INTERSECT
	SELECT EventID
	FROM Reviews 
);

-- Using IN (intersection)
-- same as above (alternative approach)
SELECT EventID, EventName 
FROM Events
WHERE EventID IN (
	SELECT EventID
	FROM Tickets 
)
AND EventID IN (
	SELECT EventID
	FROM Reviews 
);


-- Using EXCEPT (difference)
-- find the users who have not posted reviews
SELECT DISTINCT UserID
FROM Users
EXCEPT 
SELECT DISTINCT UserID
FROM Reviews;

-- Using NOT IN
-- alternative approach
SELECT UserID
FROM Users
WHERE UserID NOT IN (
	SELECT DISTINCT UserID
	FROM Reviews 
);


-- INNER JOIN with 3 tables and using a m:n relationship
-- the query perfoms an INNER JOIN on three tables to display events, their associated artists, and their categories
SELECT Events.EventName, Artists.ArtistName, Categories.CategoryName
FROM Events
INNER JOIN Artists ON Events.EventID = Artists.EventID
INNER JOIN EventCategories ON Events.EventID = EventCategories.EventID
INNER JOIN Categories ON EventCategories.CategoryID = Categories.CategoryID;

-- LEFT JOIN with two m:n relationships
-- Join the Users, Tickets, Events, EventsArtists and Artists tables to show users, their tickets, the events they attended, and the artists perfoming at those events.
SELECT Users.UserName, Events.EventName, Artists.ArtistName
FROM Users
LEFT JOIN Tickets ON Users.UserID = Tickets.UserID
LEFT JOIN Events ON Tickets.EventID = Events.EventID
LEFT JOIN EventsArtists ON Events.EventID = EventsArtists.EventID
LEFT JOIN Artists ON EventsArtists.ArtistID = Artists.ArtistID;

-- RIGHT JOIN
-- List all Reviews with their corresponding Users, or NULL values if there are not any users for a review
SELECT Users.UserName, Reviews.Content
FROM Users
RIGHT JOIN Reviews ON Users.UserID = Reviews.UserID;

-- FULL JOIN
-- Retrieve events and their associated categories, including events without categories and categories without events
SELECT Events.EventName, Categories.CategoryName
FROM Events
FULL JOIN EventCategories ON Events.EventID = EventCategories.EventID
FULL JOIN Categories ON EventCategories.CategoryID = Categories.CategoryID;


-- Queries with the IN operator and a subquery in the WHERE clause
-- TOP, GROUP BY and ORDER BY are also used, as well as arithmetic expr
-- Retrieve the top 5 users who have bought tickets for events with a price greter than 100, and display the total amount spent by each user on those tickets
SELECT TOP 5 Users.UserName, SUM(Tickets.Price) AS TotalAmountSpent
FROM Users
INNER JOIN Tickets ON Users.UserID = Tickets.UserID
WHERE Users.UserID IN (
	SELECT DISTINCT UserID
	FROM Tickets
	WHERE EventID IN (
		SELECT EventID
		FROM Events
		WHERE EventDate >= '2023-01-01' AND EventLocation LIKE '%Bucharest%'
	) AND Price > 100
)
GROUP BY Users.UserName
ORDER BY TotalAmountSpent DESC;

-- Using the IN Operator with Subqueries
-- Retrieve a list of events with their categories that have tickets with prices of 30 or higher, and sort the result by event name.
SELECT Events.EventName, EventCategories.CategoryID
FROM Events
INNER JOIN EventCategories ON Events.EventID = EventCategories.EventID
WHERE EventCategories.EventID IN (
	SELECT EventID
	FROM Tickets
	WHERE Price >= 30
)
ORDER BY Events.EventName;


-- Using EXISTS Operator with a subquery in the WHERE clause
-- Retrieve a list of users for whom there are reviews with a rating of 4 or more
-- SELECT 1 or SELECT any_constant is a common practice when using the EXIST operator in a subquery. It's used as a placeholder for the actual data you want to retrieve from the subquery.
SELECT UserName
FROM Users
WHERE EXISTS (
	SELECT 1
	FROM Reviews
	WHERE Reviews.UserID = Users.UserID
	AND Reviews.Rating >= 4
);

-- same task as above, using also TOP and an Arithmetic Expression (Average)
-- Retrieve the top 3 users who have bought tickets for events that have reviews with a rating of 4 or more.

SELECT TOP 3 Users.UserName
FROM Users
WHERE EXISTS (
	SELECT 1
	FROM Tickets AS T
	WHERE T.UserID = Users.UserID
	AND T.EventID IN (
		SELECT EventID
		FROM Reviews
		WHERE Reviews.Rating >= 4
	)
);


-- Using a subquery in the FROM clause
-- Retrieve a list of events along with the average ticket price for each event
SELECT Events.EventName, AVG(T.Price) AS AverageTicketPrice
FROM Events
LEFT JOIN (
	SELECT EventID, Price
	FROM Tickets
) AS T ON Events.EventID = T.EventID
GROUP BY Events.EventName
ORDER BY AverageTicketPrice DESC;

-- same as above
-- Retrieve a list of users and their associated review rating, specifically for users with reviews meeting the specified rating condition
SELECT Users.UserName, Reviews.Rating
FROM Users
LEFT JOIN (
	SELECT UserID, Rating
	FROM Reviews 
	WHERE Rating >= 4
) AS Reviews ON Users.UserID = Reviews.UserID
ORDER BY Reviews.Rating DESC;


-- GROUP BY with COUNT and HAVING
-- Count the number of events in each category and display only categories with more than 0 events
SELECT EC.CategoryID, C.CategoryName, COUNT(EC.EventID) AS EventCount
FROM EventCategories as EC
JOIN Categories AS C ON EC.CategoryID = C.CategoryID
GROUP BY EC.CategoryID, C.CategoryName
HAVING COUNT(EC.EventID) > 0;

-- GROUP BY with AVG and HAVING (subquery)
-- find the average rating given by users and display only users that have given an average rating greater than the overall average rating
SELECT Users.UserID, Users.UserName, AVG(R.Rating) AS AvgRating
FROM Users
LEFT JOIN Reviews AS R ON Users.UserID = R.UserID
GROUP BY Users.UserID, Users.UserName
HAVING AVG(R.ReviewID) > (SELECT AVG(Rating) FROM Reviews)

-- GROUP BY with MAX and HAVING
-- Retrieve a list of events along with their maximum ticket prices. It is useful for finding the highest ticket price for each event.
SELECT E.EventID, E.EventName, MAX(T.Price) AS MaxTicketPrice
FROM Events AS E
LEFT JOIN Tickets AS T ON E.EventID = T.EventID
GROUP BY E.EventID, E.EventName;

-- GROUP BY with MIN and HAVING (Subquery)
-- Find the minimum age restriction for events in each category and display only categories with a minimum age restriction less than the overall minimum age restriction
SELECT EC.CategoryID, C.CategoryName, MIN(E.EventRestrictions) AS MinAgeRestriction
FROM EventCategories AS EC
JOIN Categories AS C ON EC.CategoryID = C.CategoryID
JOIN Events AS E ON EC.EventID = E.EventID
GROUP BY EC.CategoryID, C.CategoryName
HAVING MIN(E.EventRestrictions) < (SELECT MIN(EventRestrictions) FROM Events);


-- ANY Operator (Subquery in WHERE Clause)
-- The ANY operator returns 'TRUE' if at least one of the subquery results meets the specified condition
-- Find events where at least one user has reviewd the event with a rating of 5.
SELECT EventID, EventName
FROM Events
WHERE EventID = ANY (SELECT DISTINCT EventID FROM Reviews WHERE Rating = 5);

-- ALL Operator (Subquery in WHERE Clause)
-- The ALL operator returns 'TRUE' if the specified condition is true for all values in the subquery result set.
-- Find events where all users have reviewed the event with a rating of 5.
SELECT EventID, EventName
FROM Events
WHERE EventID = ALL(SELECT DISTINCT EventID FROM Reviews WHERE Rating = 5);

-- ANY Operator (Subquery in WHERE Clause)
-- Find events where at least one belongs to an artist
SELECT EventID, EventName
FROM Events
WHERE EventID = ANY (SELECT DISTINCT EventID FROM Artists);

-- the one from the above but with IN
SELECT EventID, EventName
FROM Events
WHERE EventID IN (SELECT DISTINCT EventID FROM Artists);

-- the one from the above but with MIN
SELECT EventID, EventName
FROM Events
WHERE EventID = (SELECT DISTINCT MIN(EventID) FROM Artists);

-- ALL Operator (Subquery in WHERE Clause)
-- Find users who have not reviewed an event with a rating of 1.
SELECT UserID, UserName
FROM Users
WHERE UserID <> ALL (SELECT DISTINCT UserID FROM Reviews WHERE Rating = 1);

-- the one from the above rewritten with NOT IN
SELECT UserID, UserName
FROM Users
WHERE UserID NOT IN (SELECT DISTINCT UserID FROM Reviews WHERE Rating = 1);

-- the one from the above rewritten with MAX
SELECT UserID, UserName
FROM Users
WHERE UserID <> (SELECT DISTINCT MAX(UserID) FROM Reviews WHERE Rating = 1);