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
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
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
        PRIMARY KEY (commissionID)
        FOREIGN KEY (customerID) REFERENCES Customers(customerID),
);

CREATE OR REPLACE TABLE Reviews 
	(
        reviewID int AUTO_INCREMENT,
        starValue INT NOT NULL,
        reviewText VARCHAR(250)
        reviewDate DATE NOT NULL,
        customerID INT,
        -- The combination of the first_name and last_name must be unique in this table. Name this constraint as full_name 
        PRIMARY KEY (reviewID)
        FOREIGN KEY (customerID) REFERENCES Customers(customerID),
);

-- Intermediate Tables
CREATE OR REPLACE TABLE ArtistGenres(
	artistGenreID INT,
	artistID INT,
	genreID INT,	
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	FOREIGN KEY (genreID) REFERENCES Genres(genreID),
	PRIMARY KEY (artistGenreID) REFERENCES(artistID, genreID)
);

CREATE OR REPLACE TABLE ArtistMediums(
	artistMediumID INT,
	artistID INT,
	mediumID INT,	
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID),
	PRIMARY KEY (artistMediumID) REFERENCES(artistID, mediumID)
);

CREATE OR REPLACE TABLE CommissionMediums(
	commissionMediumID INT,
	commissionID INT,
	mediumID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (mediumID) REFERENCES Mediums(mediumID),
	PRIMARY KEY (commissionMediumID) REFERENCES(commissionID, mediumID)
);

CREATE OR REPLACE TABLE CommissionGenres(
	commissionMediumID INT,
	commissionID INT,
	genreID INT,	
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (genreID) REFERENCES Genres(genreID),
	PRIMARY KEY (commissionMediumID) REFERENCES(commissionID, genreID)
);

CREATE OR REPLACE TABLE ArtistComissions(
	artistCommissionID INT,
	artistID INT,
	commissionID INT,
	FOREIGN KEY (commissionID) REFERENCES Commissions(commissionID),
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	PRIMARY KEY (artistCommissionID) REFERENCES(commissionID, artistID)
);

CREATE OR REPLACE TABLE ArtistReviews(
	artistReviewsID INT,
	artistID INT,
	reviewID INT,
	FOREIGN KEY (reviewID) REFERENCES Reviews(reviewID),
	FOREIGN KEY (artistID) REFERENCES Artists(artistID),
	PRIMARY KEY (artistReviewsID) REFERENCES(commissionID, artistID)
);


-- Sample Data INSERT statements
