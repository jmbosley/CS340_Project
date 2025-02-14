INSERT INTO Artists (email, name, completedCount)
	VALUES(:artistEmailInput, :artistNameInput:, :completedCountInput)

-- Insert Into Customers
INSERT INTO Customers (email, name, birthday, totalOrders)
	VALUES(:customerEmailInput, :customerNameInput, :birthdayInput, :totalOrdersInput);

-- Insert into Genres
INSERT INTO Genres(type)
	VALUES(:genreTypeInput);

-- Insert into Mediums
INSERT INTO Mediums(type)
	VALUES(:mediumTypeInput);

-- Insert into Commissions
INSERT INTO Commissions(requestStatus, dateRequested, dateCompleted, price, customerID)
	VALUES(:requestStatusInput, :dateRequestedInput, :dateCompletedInput, :priceInput, :customerIDInput);

-- Interaction Tables
-- Insert Into ArtistGenres
INSERT INTO ArtistGenres(artistID, genreID)
	VALUES((SELECT artistID from Artists WHERE Artists.email=:artistEmailInput), (SELECT genreID from Genres WHERE Genres.type=:genreTypeInput));

-- Insert Into ArtistMediums
INSERT INTO ArtistMediums(artistID, mediumID)
	VALUES((SELECT artistID from Artists WHERE Artists.email=:artistEmailInput), (SELECT mediumID from Mediums WHERE Mediums.type=:mediumTypeInput));

-- Insert Into CommissionMediums
INSERT INTO CommissionMediums(commissionID, mediumID)
	VALUES((SELECT commissionID from Commissions WHERE Commissions.dateRequested=:dateRequestedInput AND customerID=(SELECT customerID from Customers WHERE Customers.name=:customerNameInput)),
    (SELECT mediumID from Mediums WHERE Mediums.type=:mediumTypeInput));

-- Insert Into CommissionGenres
INSERT INTO CommissionGenres(commissionID,genreID)
	VALUES((SELECT commissionID from Commissions WHERE Commissions.dateRequested=:dateRequestedInput AND customerID=(SELECT customerID from Customers WHERE Customers.name=:customerNameInput)),
    (SELECT genreID from Genres WHERE Genres.type=:genreTypeInput));

-- Insert Into ArtistComissions
INSERT INTO ArtistCommissions(artistID,commissionID)
	VALUES((SELECT artistID from Artists WHERE Artists.email=:artistEmailInput),
    (SELECT commissionID from Commissions WHERE Commissions.dateRequested=:dateRequestedInput AND customerID=(SELECT customerID from Customers WHERE Customers.name=:customerNameInput));

-- Selections
-- Artists Page
SELECT Artists.artistID as "Artist ID",  Artists.email as "Email", Artists.name as "Full Name", Artists.completedCount as "Commissions Completed", Genres.type as "Genres", Mediums.type as "Mediums"
FROM Artists
INNER JOIN ArtistGenres ON Artists.artistID = ArtistGenres.artistID
INNER JOIN ArtistMediums ON Artists.artistID = ArtistMediums.artistID
INNER JOIN Genres ON ArtistGenres.genreID = Genres.genreID
INNER JOIN Mediums ON ArtistMediums.mediumID = Mediums.mediumID;

-- Customers Page
SELECT Customers.customerID as "Customer ID", Customers.email as "Email", Customers.name as "Name", Customers.birthday as "Birthday", Customers.totalOrders as "Total Commissions"
FROM Customers;

-- Commissions
SELECT Commissions.commissionID as "Commission ID", Artists.artistID as "Artist ID", Commissions.requestStatus as "Request Status", Genres.type as "Genres", Mediums.type as "Mediums", Commissions.dateRequested as "Date Requested",
Commissions.dateCompleted as "Date Completed", Commissions.price as "Price", Customers.customerID as "Customer IDs"
FROM Commissions
INNER JOIN ArtistCommissions ON Commissions.commissionID = ArtistCommissions.commissionID
INNER JOIN Artists ON ArtistCommissions.artistID = Artists.artistID
INNER JOIN CommissionGenres ON Commissions.commissionID = CommissionGenres.commissionID
INNER JOIN Genres ON CommissionGenres.genreID = Genres.genreID
INNER JOIN CommissionMediums ON Commissions.commissionID = CommissionMediums.commissionID
INNER JOIN Mediums ON CommissionMediums.mediumID = Mediums.mediumID
INNER JOIN Customers ON Commissions.customerID = Customers.customerID;

Commission ID	Artist ID	Request Status	Genres	Mediums	Date Requested	Date Completed	Price	Customer IDs	Edit


SET FOREIGN_KEY_CHECKS=1;
COMMIT;
