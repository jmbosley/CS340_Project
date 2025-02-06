--Anna Connelly: Co-Captain
--Julie Bosley: Co-Captain
--Team Name: Team 143

-- Data Definition Queries
-- Entity Tables

SET FOREIGN_KEY_CHECKS=0; -- prevents import errors
SET AUTOCOMMIT = 0;

CREATE OR REPLACE TABLE Artists 
	(
        artistID int AUTO_INCREMENT,
        email varchar(145) NOT NULL,
		name varchar(145) NOT NULL,
        averageRating DECIMAL(2,1),
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
        type VARCHAR(145) NOT NULL,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (genreID)
);

CREATE OR REPLACE TABLE Mediums 
	(
        mediumID int AUTO_INCREMENT,
        type VARCHAR(145) NOT NULL,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (mediumID)
);

CREATE OR REPLACE TABLE Commissions 
	(
        commissionID int AUTO_INCREMENT,
        requestStatus VARCHAR(145) NOT NULL,
        dateRequested DATE NOT NULL,
        dateCompleted DATE,
        price DECIMAL(9,2) NOT NULL,
        customerID INT,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (commissionID),
        FOREIGN KEY (customerID) REFERENCES Customers(customerID)
			ON DELETE CASCADE -- if the foreign key is deleted it will be deleted here too
		-- CONSTRAINT onePerDay UNIQUE (customerID, dateRequested)
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
			ON DELETE CASCADE
);

-- Intersection Tables
CREATE OR REPLACE TABLE ArtistGenres(
	artistGenreID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	genreID INT,
	FOREIGN KEY (artistID) REFERENCES Artists(artistID)
		ON DELETE CASCADE,
	FOREIGN KEY (genreID) REFERENCES Genres(genreID)
		ON DELETE CASCADE,
	PRIMARY KEY (artistGenreID)
);

CREATE OR REPLACE TABLE ArtistMediums(
	artistMediumID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	mediumID INT,	
	FOREIGN KEY (artistID) REFERENCES Artists(artistID)
		ON DELETE CASCADE,
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID)
		ON DELETE CASCADE,
	PRIMARY KEY (artistMediumID)
);

CREATE OR REPLACE TABLE CommissionMediums(
	commissionMediumID INT NOT NULL AUTO_INCREMENT,
	commissionID INT,
	mediumID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID)
		ON DELETE CASCADE,
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID)
		ON DELETE CASCADE,
	PRIMARY KEY (commissionMediumID)
);

CREATE OR REPLACE TABLE CommissionGenres(
	commissionGenreID INT NOT NULL AUTO_INCREMENT,
	commissionID INT,
	genreID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID)
		ON DELETE CASCADE,
	FOREIGN KEY (genreID) REFERENCES Genres(genreID)
		ON DELETE CASCADE,
	PRIMARY KEY (commissionGenreID)
);

CREATE OR REPLACE TABLE ArtistCommissions(
	artistCommissionID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	commissionID INT,
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID)
		ON DELETE CASCADE,
	FOREIGN KEY (artistID) REFERENCES Artists(artistID)
		ON DELETE CASCADE,
	PRIMARY KEY (artistCommissionID)
);

CREATE OR REPLACE TABLE ArtistReviews(
	artistReviewID INT NOT NULL AUTO_INCREMENT,
	artistID INT,
	reviewID INT,
	FOREIGN KEY (reviewID) REFERENCES Reviews(reviewID)
		ON DELETE CASCADE,
	FOREIGN KEY (artistID) REFERENCES Artists(artistID)
		ON DELETE CASCADE,
	PRIMARY KEY (artistReviewID)
);


-- Sample Data INSERT statements
-- Entity Tables
-- Insert Into Artists
INSERT INTO Artists (email, name, averageRating, completedCount)
	VALUES('JaneDoe@gmail.com', 'Jane Doe', 3.0, 1), ('ghostShipGames@gmail.com', 'Peter Smith', 5.0, 1), ('watercolorlover@gmail.com', 'Betty Davis', 1.0, 1),
	('lazyArtist@gmail.com', 'Jenny Taylor', NULL, 0);

-- Insert Into Customers
INSERT INTO Customers (email, name, birthday, totalOrders)
	VALUES('JoeShmow@yahoo.com','Joe Shmow', '1965-04-16', 1), ('wWilson@hotmail.com', 'Wade Wilson', NULL, 1), ('bobTheArtLover@gmail.com', 'Bob Rodriguez', '1957-02-05', 2);

-- Insert into Genres
INSERT INTO Genres(type)
	VALUES('Steampunk'), ('Cute'), ('Horror'), ('Modern'), ('Impressionism');

-- Insert into Mediums
INSERT INTO Mediums(type)
	VALUES('Oil Paint'), ('Gouache'), ('Digital'), ('Watercolor'), ('Acrylic Paint'), ('All');

-- Insert into Commissions
INSERT INTO Commissions(requestStatus, dateRequested, dateCompleted, price, customerID)
	VALUES('Request Complete', '2017-07-22', '2017-08-02', 50.00, (SELECT customerID from Customers WHERE email='JoeShmow@yahoo.com')),
	('Request Complete', '2020-01-16', '2020-11-19', 12.32, (SELECT customerID from Customers WHERE email='wWilson@hotmail.com')),
	('Request Complete', '2021-10-02', '2021-11-05', 20.00, (SELECT customerID from Customers WHERE email='bobTheArtLover@gmail.com')),
	('Request Unclaimed', '2021-12-20', NULL, 95.50, (SELECT customerID from Customers WHERE email='bobTheArtLover@gmail.com'));

-- Insert into Reviews
INSERT INTO Reviews(starValue, reviewText, reviewDate, customerID)
	VALUES(3, NULL, '2017-08-02', (SELECT customerID from Customers WHERE email='JoeShmow@yahoo.com')),
	(5,'This artist was great to work with', '2020-11-19', (SELECT customerID from Customers WHERE email='wWilson@hotmail.com')),
	(1,'This is so ugly!!', '2021-11-05', (SELECT customerID from Customers WHERE email='bobTheArtLover@gmail.com'));

-- Interaction Tables
-- Insert Into ArtistGenres
INSERT INTO ArtistGenres(artistID, genreID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT genreID from Genres WHERE type='Steampunk')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT genreID from Genres WHERE type='Horror')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT genreID from Genres WHERE type='Cute'));

-- Insert Into ArtistMediums
INSERT INTO ArtistMediums(artistID, mediumID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT mediumID from Mediums WHERE type='Digital')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT mediumID from Mediums WHERE type='Watercolor'));

-- Insert Into CommissionMediums
INSERT INTO CommissionMediums(commissionID, mediumID)
	-- joe's commission
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2017-07-22' AND customerID=1), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	-- wade's commission
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=2), (SELECT mediumID from Mediums WHERE type='Digital')),
	-- bob's commission
	((SELECT commissionID from Commissions WHERE dateRequested='2021-10-02' AND customerID=3), (SELECT mediumID from Mediums WHERE type='Watercolor')),
	((SELECT commissionID from Commissions WHERE dateRequested='2021-12-20' AND customerID=3), (SELECT mediumID from Mediums WHERE type='Gouache'));

-- Insert Into CommissionGenres
INSERT INTO CommissionGenres(commissionID,genreID)
	-- joe
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2017-07-22' AND customerID=1), (SELECT genreID from Genres WHERE type='Steampunk')), -- need to come up with query to search customerID by email
	-- wade
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=2), (SELECT genreID from Genres WHERE type='Horror')),
	-- bob
	((SELECT commissionID from Commissions WHERE dateRequested='2021-10-02' AND customerID=3), (SELECT genreID from Genres WHERE type='Cute')),
	((SELECT commissionID from Commissions WHERE dateRequested='2021-12-20' AND customerID=3), (SELECT genreID from Genres WHERE type='Modern'));

-- Insert Into ArtistComissions
INSERT INTO ArtistCommissions(artistID,commissionID)
	-- joe reviews jane
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2017-07-22' AND customerID=1)),
	-- wade reviews peter
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2020-01-16' AND customerID=2)),
	-- bob reviews betty
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2021-10-02' AND customerID=3)); -- need to come up with query to search customerID by email

-- Insert Into ArtistReviews
INSERT INTO ArtistReviews(artistID, reviewID)
	-- jane and joe
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'),(SELECT reviewID from Reviews WHERE customerID=1 AND reviewDate='2017-08-02')),
	-- peter and wade
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'),(SELECT reviewID from Reviews WHERE customerID=2 AND reviewDate='2020-11-19')),
	-- betty and bob
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'),(SELECT reviewID from Reviews WHERE customerID=3 AND reviewDate='2021-11-05')); -- need to come up with query to search customerID by email

SET FOREIGN_KEY_CHECKS=1;
COMMIT;