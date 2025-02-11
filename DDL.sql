-- Anna Connelly: Co-Captain
-- Julie Bosley: Co-Captain
-- Team Name: Team 143

-- Data Definition Queries
-- Entity Tables

SET FOREIGN_KEY_CHECKS=0; -- prevents import errors
SET AUTOCOMMIT = 0;

CREATE OR REPLACE TABLE Artists 
	(
        artistID int AUTO_INCREMENT,
        email varchar(145) NOT NULL,
		name varchar(145) NOT NULL,
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
        PRIMARY KEY (customerID),
        UNIQUE (email)
);

CREATE OR REPLACE TABLE Genres 
	(
        genreID int AUTO_INCREMENT,
        type VARCHAR(145) NOT NULL,
        PRIMARY KEY (genreID)
);

CREATE OR REPLACE TABLE Mediums 
	(
        mediumID int AUTO_INCREMENT,
        type VARCHAR(145) NOT NULL,
        PRIMARY KEY (mediumID)
);

CREATE OR REPLACE TABLE Commissions 
	(
        commissionID int AUTO_INCREMENT,
        requestStatus VARCHAR(145) NOT NULL,
        dateRequested DATETIME NOT NULL, -- format: 1000-01-01 00:00:00
        dateCompleted DATE,
        price DECIMAL(9,2) NOT NULL,
        customerID INT,
        PRIMARY KEY (commissionID),
        FOREIGN KEY (customerID) REFERENCES Customers(customerID)
			ON DELETE CASCADE -- if the foreign key is deleted it will be deleted here too
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


-- Sample Data INSERT statements
-- Entity Tables
-- Insert Into Artists

INSERT INTO Artists (email, name, completedCount)
	VALUES('JaneDoe@gmail.com', 'Jane Doe', 1), ('ghostShipGames@gmail.com', 'Peter Smith', 1), ('watercolorlover@gmail.com', 'Betty Davis', 2),
	('lazyArtist@gmail.com', 'Jenny Taylor', 0);

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
	VALUES('Request Complete', '2017-07-22 02:10:02', '2017-08-02', 50.00, (SELECT customerID from Customers WHERE email='JoeShmow@yahoo.com')),
	('Request Complete', '2018-02-02 12:01:05', '2018-03-20', 75.00, (SELECT customerID from Customers WHERE email='JoeShmow@yahoo.com')), -- new joe, betty
	('Request Complete', '2020-01-16 10:22:32', '2020-11-19', 12.32, (SELECT customerID from Customers WHERE email='wWilson@hotmail.com')),
	('Request Complete', '2021-10-02 07:18:00', '2021-11-05', 20.00, (SELECT customerID from Customers WHERE email='bobTheArtLover@gmail.com')),
	('Request Unclaimed', '2021-12-20 20:00:02', NULL, 95.50, (SELECT customerID from Customers WHERE email='bobTheArtLover@gmail.com'));

-- Interaction Tables
-- Insert Into ArtistGenres
INSERT INTO ArtistGenres(artistID, genreID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT genreID from Genres WHERE type='Steampunk')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT genreID from Genres WHERE type='Horror')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT genreID from Genres WHERE type='Modern')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT genreID from Genres WHERE type='Cute')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT genreID from Genres WHERE type='Horror'));

-- Insert Into ArtistMediums
INSERT INTO ArtistMediums(artistID, mediumID)
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT mediumID from Mediums WHERE type='Digital')),
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT mediumID from Mediums WHERE type='Watercolor')),
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT mediumID from Mediums WHERE type='Digital'));

-- Insert Into CommissionMediums
INSERT INTO CommissionMediums(commissionID, mediumID)
	-- joe, jane
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2017-07-22 02:10:02' AND customerID=1), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	-- joe, betty
	((SELECT commissionID from Commissions WHERE dateRequested='2018-02-02 12:01:05' AND customerID=1), (SELECT mediumID from Mediums WHERE type='Digital')),
	-- wade, peter
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16 10:22:32' AND customerID=2), (SELECT mediumID from Mediums WHERE type='Digital')),
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16 10:22:32' AND customerID=2), (SELECT mediumID from Mediums WHERE type='Oil Paint')),
	-- bob, betty
	((SELECT commissionID from Commissions WHERE dateRequested='2021-10-02 07:18:00' AND customerID=3), (SELECT mediumID from Mediums WHERE type='Watercolor')),
	-- bob, unclaimed
	((SELECT commissionID from Commissions WHERE dateRequested='2021-12-20 20:00:02' AND customerID=3), (SELECT mediumID from Mediums WHERE type='Gouache'));

-- Insert Into CommissionGenres
INSERT INTO CommissionGenres(commissionID,genreID)
	-- joe, jane
	VALUES((SELECT commissionID from Commissions WHERE dateRequested='2017-07-22 02:10:02' AND customerID=1), (SELECT genreID from Genres WHERE type='Steampunk')),
	-- joe, betty
	((SELECT commissionID from Commissions WHERE dateRequested='2018-02-02 12:01:05' AND customerID=1), (SELECT genreID from Genres WHERE type='Horror')),
	-- wade, peter
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16 10:22:32' AND customerID=2), (SELECT genreID from Genres WHERE type='Horror')),
	((SELECT commissionID from Commissions WHERE dateRequested='2020-01-16 10:22:32' AND customerID=2), (SELECT genreID from Genres WHERE type='Modern')),
	-- bob, betty
	((SELECT commissionID from Commissions WHERE dateRequested='2021-10-02 07:18:00' AND customerID=3), (SELECT genreID from Genres WHERE type='Cute')),
	-- bob, unclaimed
	((SELECT commissionID from Commissions WHERE dateRequested='2021-12-20 20:00:02' AND customerID=3), (SELECT genreID from Genres WHERE type='Modern'));

-- Insert Into ArtistComissions
INSERT INTO ArtistCommissions(artistID,commissionID)
	-- joe, jane
	VALUES((SELECT artistID from Artists WHERE email='JaneDoe@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2017-07-22 02:10:02' AND customerID=1)),
	-- joe, betty
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2018-02-02 12:01:05' AND customerID=1)),
	-- wade, peter
	((SELECT artistID from Artists WHERE email='ghostShipGames@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2020-01-16 10:22:32' AND customerID=2)),
	-- bob, betty
	((SELECT artistID from Artists WHERE email='watercolorlover@gmail.com'), (SELECT commissionID from Commissions WHERE dateRequested='2021-10-02 07:18:00' AND customerID=3));

SET FOREIGN_KEY_CHECKS=1;
COMMIT;
