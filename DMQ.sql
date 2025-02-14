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

