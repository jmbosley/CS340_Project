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
LEFT JOIN ArtistGenres ON Artists.artistID = ArtistGenres.artistID
LEFT JOIN ArtistMediums ON Artists.artistID = ArtistMediums.artistID
LEFT JOIN Genres ON ArtistGenres.genreID = Genres.genreID
LEFT JOIN Mediums ON ArtistMediums.mediumID = Mediums.mediumID;

-- Customers Page
SELECT Customers.customerID as "Customer ID", Customers.email as "Email", Customers.name as "Name", Customers.birthday as "Birthday", Customers.totalOrders as "Total Commissions"
FROM Customers;

-- Commissions
SELECT Commissions.commissionID as "Commission ID", Artists.artistID as "Artist ID", Commissions.requestStatus as "Request Status", Genres.type as "Genres", Mediums.type as "Mediums", Commissions.dateRequested as "Date Requested",
Commissions.dateCompleted as "Date Completed", Commissions.price as "Price", Customers.customerID as "Customer IDs"
FROM Commissions
LEFT JOIN ArtistCommissions ON Commissions.commissionID = ArtistCommissions.commissionID
LEFT JOIN Artists ON ArtistCommissions.artistID = Artists.artistID
LEFT JOIN CommissionGenres ON Commissions.commissionID = CommissionGenres.commissionID
LEFT JOIN Genres ON CommissionGenres.genreID = Genres.genreID
LEFT JOIN CommissionMediums ON Commissions.commissionID = CommissionMediums.commissionID
LEFT JOIN Mediums ON CommissionMediums.mediumID = Mediums.mediumID
LEFT JOIN Customers ON Commissions.customerID = Customers.customerID;

-- Genres
SELECT Genres.genreID as "Genre ID", Genres.type as "Type", IFNULL(COUNT(Genres.genreID = ArtistGenres.genreID), 0) AS "Artist Count", IFNULL(COUNT(Genres.genreID = CommissionGenres.genreID), 0) AS "Commission Count"
FROM Genres
LEFT JOIN ArtistGenres ON Genres.genreID = ArtistGenres.genreID
LEFT JOIN CommissionGenres ON Genres.genreID = CommissionGenres.genreID
GROUP BY Genres.genreID;

-- Mediums
SELECT Mediums.mediumID as "Medium ID", Mediums.type as "Type", IFNULL(COUNT(Mediums.mediumID = ArtistMediums.mediumID), 0) AS "Artist Count", IFNULL(COUNT(Mediums.mediumID = CommissionMediums.mediumID), 0) AS "Commission Count"
FROM Mediums
LEFT JOIN ArtistMediums ON Mediums.mediumID = ArtistMediums.mediumID
LEFT JOIN CommissionMediums ON Mediums.mediumID = CommissionMediums.mediumID
GROUP BY Mediums.mediumID;

-- Update
-- Edit Artists
UPDATE Artists SET email = :artistEmailInput, name=:artistNameInput 
WHERE artistID= :character_ID_from_the_update_form;

INSERT INTO ArtistGenres(artistID, genreID )
VALUES ((SELECT artistID FROM Artists WHERE email=:artistEmailInput), (SELECT genreID FROM Genres WHERE type=:genreTypeInput));

INSERT INTO ArtistMediums(artistID, mediumID )
VALUES ((SELECT artistID FROM Artists WHERE email=:artistEmailInput), (SELECT mediumID FROM Mediums WHERE type=:mediumTypeInput));


-- Edit Customers
UPDATE Customers SET email = :customerEmailInput, name=:customerNameInput, birthday = :birthdayInput
WHERE customerID= :character_ID_from_the_update_form;

-- Edit Commissions
UPDATE Commissions SET requestStatus = :requestStatusInput, dateCompleted = :dateCompletedInput, price=:priceInput
WHERE commissionID= :character_ID_from_the_update_form;

INSERT INTO ArtistCommissions(artistID, commissionID )
VALUES ((SELECT artistID FROM Artists WHERE email=:artistEmailInput), :commissionID_from_select);

INSERT INTO CommissionGenres(commissionID, genreID )
VALUES (:commissionID_from_select, (SELECT genreID FROM Genres WHERE type=:genreTypeInput));

INSERT INTO CommissionMediums(commissionID, mediumID )
VALUES (:commissionID_from_select, (SELECT mediumID FROM Mediums WHERE type=:mediumTypeInput));

-- Edit Genres
UPDATE Genres SET type = :genreTypeInput
WHERE genreID= :character_ID_from_the_update_form;

-- Edit Mediums
UPDATE Mediums SET type = :mediumTypeInput
WHERE mediumID= :character_ID_from_the_update_form;

SET FOREIGN_KEY_CHECKS=1;
COMMIT;
