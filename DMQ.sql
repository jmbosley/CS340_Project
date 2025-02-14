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

SET FOREIGN_KEY_CHECKS=1;
COMMIT;
