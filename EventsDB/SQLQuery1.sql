CREATE DATABASE EventManagementDB;
GO

USE EventManagementDB;
GO

CREATE TABLE Users (
	UserID INT PRIMARY KEY,
	UserName NVARCHAR(50),
	UserEmail NVARCHAR(100),
	UserPassword NVARCHAR(100)
);

CREATE TABLE Events (
	EventID INT PRIMARY KEY,
	EventName NVARCHAR(50),
	EventRestrictions NVARCHAR(100),
	EventDate DATETIME,
	EventLocation NVARCHAR(100),
	--UserID INT FOREIGN KEY REFERENCES Users(UserID)
);

CREATE TABLE Artists (
	ArtistID INT PRIMARY KEY,
	ArtistName NVARCHAR(50),
	ArtistSpecialisation NVARCHAR(100),
	EventID INT FOREIGN KEY REFERENCES Events(EventID)
);

CREATE TABLE EventsArtists (
	EventID INT,
	ArtistID INT,
	PRIMARY KEY (EventID, ArtistID),
	FOREIGN KEY (EventID) REFERENCES Events(EventID),
	FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

CREATE TABLE AttendingStatus (
	ASID INT PRIMARY KEY,
	AStatus NVARCHAR(100),
	UserID INT FOREIGN KEY REFERENCES Users(UserID),
	EventID INT FOREIGN KEY REFERENCES Events(EventID)
);

CREATE TABLE Tickets (
	TicketID INT PRIMARY KEY,
	Price INT,
	UserID INT FOREIGN KEY REFERENCES Users(UserID),
	EventID INT FOREIGN KEY REFERENCES Events(EventID)
);

CREATE TABLE Reviews (
	ReviewID INT PRIMARY KEY,
	Content NVARCHAR(100),
	Rating INT,
	UserID INT FOREIGN KEY REFERENCES Users(UserID)
);

CREATE TABLE Organizers (
	OrganizersID INT PRIMARY KEY,
	ContactInformation NVARCHAR(100),
	OrganizerType NVARCHAR(100),
	UserID INT FOREIGN KEY REFERENCES Users(UserID)
);

CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY,
	CategoryName NVARCHAR(100),
	CategoryDescription NVARCHAR(100)
);

CREATE TABLE EventCategories (
	EventID INT,
	CategoryID INT,
	PRIMARY KEY (EventID, CategoryID),
	FOREIGN KEY (EventID) REFERENCES Events(EventID),
	FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Sponsors (
	SponsorID INT,
	EventID INT FOREIGN KEY REFERENCES Events(EventID),
	CONSTRAINT pk_Sponsors PRIMARY KEY (SponsorID)
);


