--Anna Connelly: Co-Captain
--Julie Bosley: Co-Captain
--Team Name: Team 143

-- Data Definition Queries
-- Entity Tables
CREATE OR REPLACE TABLE Artists 
	(
        artistID int AUTO_INCREMENT,
        email varchar(145) NOT NULL,
        averageRating INT,
        completedCount INT NOT NULL,
        -- Unique Email
        PRIMARY KEY (artistID),
        UNIQUE (email)
);

CREATE OR REPLACE TABLE Customers 
	(
        customerID int AUTO_INCREMENT,
        email varchar(145) NOT NULL,
        name VARCHAR(145) NOT NULL,
        birthday DATE,
        totalOrders INT NOT NULL,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (customerID),
        UNIQUE (email)
);

CREATE OR REPLACE TABLE Genres 
	(
        genreID int AUTO_INCREMENT,
        type VARCHAR(145),
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (genreID)
);

CREATE OR REPLACE TABLE Mediums 
	(
        mediumID int AUTO_INCREMENT,
        type VARCHAR(145),
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (mediumID)
);

CREATE OR REPLACE TABLE Commissions 
	(
        commissionID int AUTO_INCREMENT,
        requestStatus VARCHAR(145),
        dateRequested DATE NOT NULL,
        dateCompleted DATE,
        price DECIMAL(65,2),
        customerID INT,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (commissionID),
        FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);

CREATE OR REPLACE TABLE Reviews 
	(
        reviewID int AUTO_INCREMENT,
        starValue INT NOT NULL,
        reviewText VARCHAR(250),
        reviewDate DATE NOT NULL,
        customerID INT,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (reviewID),
        FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);

-- Intersection Tables
CREATE OR REPLACE TABLE ArtistGenres(
	artistGenreID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	genreID INT,
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	FOREIGN KEY (genreID) REFERENCES Genres(genreID),
	PRIMARY KEY (artistGenreID)
);

CREATE OR REPLACE TABLE ArtistMediums(
	artistMediumID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	mediumID INT,	
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID),
	PRIMARY KEY (artistMediumID)
);

CREATE OR REPLACE TABLE CommissionMediums(
	commissionMediumID INT NOT NULL AUTO_INCREMENT,
	commissionID INT,
	mediumID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID),
	PRIMARY KEY (commissionMediumID)
);

CREATE OR REPLACE TABLE CommissionGenres(
	commissionMediumID INT NOT NULL AUTO_INCREMENT,
	commissionID INT,
	genreID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (genreID) REFERENCES Genres(genreID),
	PRIMARY KEY (commissionMediumID)
);

CREATE OR REPLACE TABLE ArtistComissions(
	artistCommissionID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	commissionID INT,
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	PRIMARY KEY (artistCommissionID)
);

CREATE OR REPLACE TABLE ArtistReviews(
	artistReviewsID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	reviewID INT,
	FOREIGN KEY (reviewID) REFERENCES Reviews(reviewID),
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	PRIMARY KEY (artistReviewsID)
);


-- Sample Data INSERT statements
-- Entity Tables
-- Insert Into Artists
INSERT INTO Artists (email, averageRating, completedCount)
	VALUES('JaneDoe@gmail.com', 0,0), ('ghostShipGames@gmail.com', 5, 1);
-- Insert Into Customers
INSERT INTO Customers (email, name, birthday, totalOrders)
	VALUES('JoeShmow@yahoo.com','Joe Shmow', '1965-04-16',0), ('wWilson@hotmail.com', 'Wade Wilson', NULL, 1);
-- Insert into Genres
INSERT INTO Genres(type)
	VALUES('Steampunk');
-- Insert into Mediums
INSERT INTO Mediums(type)
	VALUES('Oil Painting');
-- Insert into Commissions
INSERT INTO Comissions(requestStatus, dateRequested, dateCompleted, price, customerID)
	VALUES('Request Complete', '2020-01-16','2020-11-19', 12.32, (SELECT customerID from Customers WHERE email='wWilson@hotmail.com'));
-- Insert into Reviews
INSERT INTO Reviews(starValue, reviewText, reviewDate, customerID)
	VALUES(5,'This artists was great to work with', '2020-11-19',(SELECT customerID from Customers WHERE email='wWilson@hotmail.com'));

-- Interaction Tables
-- Insert Into ArtistGenres
INSERT INTO ArtistGenres(artistID, genreID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'),(SELECT genreID from Genres WHERE type='Steampunk'));
-- Insert Into ArtistMediums
INSERT INTO ArtistMediums(artistID, mediumID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'),(SELECT mediumID from Mediums WHERE type='Oil Painting'));
-- Insert Into CommissionMediums
INSERT INTO CommissionMediums(commissionID, mediumID)
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=1),(SELECT mediumID from Mediums WHERE type='Oil Painting')); -- need to come up with query to search customerID by email
-- Insert Into CommissionGenres
INSERT INTO CommissionGenres(commissionID,genreID)
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=1),(SELECT genreID from Genres WHERE type='Steampunk')); -- need to come up with query to search customerID by email
-- Insert Into ArtistComissions
INSERT INTO ArtistComissions(artistID,commissionID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'),(SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=2)); -- need to come up with query to search customerID by email
-- Insert Into ArtistReviews
INSERT INTO ArtistReviews(artistID, reviewID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'),(SELECT reviewID from Reviews WHERE customerID=2));-- need to come up with query to search customerID by email
