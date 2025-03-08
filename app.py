from flask import Flask, render_template, json, redirect
from flask_mysqldb import MySQL
from flask import request
import os
from datetime import datetime

# taken from Flask debugging tutorial by Learning Software
# https://www.youtube.com/watch?v=_Nq_n6Uk8WA&t=166s
import sys
import logging
logging.basicConfig(filename = "debug.log", level=logging.DEBUG)

app = Flask(__name__, static_url_path='/static')

app.config['MYSQL_HOST'] = 'classmysql.engr.oregonstate.edu'
app.config['MYSQL_USER'] = 'cs340_connelan'
app.config['MYSQL_PASSWORD'] = '8248' #last 4 of onid
app.config['MYSQL_DB'] = 'cs340_connelan'
app.config['MYSQL_CURSORCLASS'] = "DictCursor"


mysql = MySQL(app)

# Routes
@app.route('/')
def root():
    return redirect("/artists")



@app.route("/commissions", methods=["POST", "GET"])
def commissions():
    if request.method == "POST":
        if request.form.get("insertCommission"): # submit button pressed
            customer = request.form["customer"]
            dateRequested = request.form["dateRequested"]
            price = request.form["price"]

            genre = request.form.getlist("genre") # id
            medium = request.form.getlist("medium") # id
            artist = request.form.getlist("artists") # id

            # Add in required values
            query = ("INSERT INTO Commissions (requestStatus, dateRequested, price, customerID) VALUES(1, %s, %s, %s);")
            cur = mysql.connection.cursor()
            cur.execute(query, (dateRequested, price, customer))
            mysql.connection.commit()

            # Add Artist
            query2 = ("INSERT INTO ArtistCommissions(artistID, commissionID) VALUES(%s, (SELECT commissionID from Commissions WHERE Commissions.dateRequested=%s AND customerID=%s));")       
            cur = mysql.connection.cursor()
            for artisttype in artist:
                cur.execute(query2, (artisttype, dateRequested, customer))
                mysql.connection.commit()

            if medium != "0":
                query3 = ("INSERT INTO CommissionMediums(commissionID, mediumID) VALUES((SELECT commissionID from Commissions WHERE Commissions.dateRequested=%s AND customerID=%s), %s);")               
                cur = mysql.connection.cursor()
                for mediumtype in medium:
                    cur.execute(query3, (dateRequested, customer, mediumtype))
                    mysql.connection.commit()

            if genre != "0":
                query4 = ("INSERT INTO CommissionGenres(commissionID, genreID) VALUES((SELECT commissionID from Commissions WHERE Commissions.dateRequested=%s AND customerID=%s), %s);")               
                cur = mysql.connection.cursor()
                for genretype in genre:
                    cur.execute(query4, (dateRequested, customer, genretype))
                    mysql.connection.commit()
                    
            return redirect("/commissions")
        
    if request.method == "GET":
        # Grab Artist data so we send it to our template to display
        query = ("SELECT Commissions.commissionID as commissionID, GROUP_CONCAT(DISTINCT Artists.artistID) as artistID, Commissions.requestStatus as requestStatus, GROUP_CONCAT(DISTINCT Genres.type) as genre, GROUP_CONCAT(DISTINCT Mediums.type) AS medium, Commissions.dateRequested as dateRequested, "
                   "Commissions.dateCompleted as dateCompleted, Commissions.price as price, Customers.customerID as customerID "
                   "FROM Commissions "
                   "LEFT JOIN ArtistCommissions ON Commissions.commissionID = ArtistCommissions.commissionID "
                   "LEFT JOIN Artists ON ArtistCommissions.artistID = Artists.artistID "
                   "LEFT JOIN CommissionGenres ON Commissions.commissionID = CommissionGenres.commissionID "
                   "LEFT JOIN Genres ON CommissionGenres.genreID = Genres.genreID "
                   "LEFT JOIN CommissionMediums ON Commissions.commissionID = CommissionMediums.commissionID "
                   "LEFT JOIN Mediums ON CommissionMediums.mediumID = Mediums.mediumID "
                   "LEFT JOIN Customers ON Commissions.customerID = Customers.customerID "
				   " GROUP BY commissionID;")
        cur = mysql.connection.cursor()
        cur.execute(query)
        commissionTableDisplay = cur.fetchall()

        queryCommissionID = ("SELECT Distinct CommissionID "
                        "FROM Commissions "
                        "ORDER BY CommissionID;")
        cur = mysql.connection.cursor()
        cur.execute(queryCommissionID)
        commissionIDDisplay = cur.fetchall()
    
        queryGenre = "SELECT Distinct genreID, type AS type FROM Genres;"
        cur = mysql.connection.cursor()
        cur.execute(queryGenre)
        genreDisplay = cur.fetchall()

        queryMedium = "SELECT Distinct mediumID, type AS type FROM Mediums;"
        cur = mysql.connection.cursor()
        cur.execute(queryMedium)
        mediumDisplay = cur.fetchall()

        queryArtist = "SELECT Distinct artistID, email FROM Artists;"
        ur = mysql.connection.cursor()
        cur.execute(queryArtist)
        artistDisplay = cur.fetchall()

        queryCustomer = "SELECT Distinct customerID, email FROM Customers;"
        ur = mysql.connection.cursor()
        cur.execute(queryCustomer)
        customerDisplay = cur.fetchall()

        return render_template("commissions.j2", commissionTableDisplay=commissionTableDisplay, commissionIDDisplay=commissionIDDisplay, genreDisplay=genreDisplay, mediumDisplay=mediumDisplay, artistDisplay=artistDisplay, customerDisplay=customerDisplay)
# delete
@app.route("/deleteCommission/<int:commissionID>")
def deleteCommission(commissionID):
    query = "DELETE FROM Commissions WHERE commissionID = %s;"
    cur = mysql.connection.cursor()
    cur.execute(query, (commissionID,))
    mysql.connection.commit()
    return redirect("/commissions")
#------------------------------------------------------------------------------------------------------------------------------------------------------------------EditCommissions---

@app.route("/editCommission/<int:commissionID>", methods=["POST", "GET"])
def editCommission(commissionID):
    if request.method == "POST":
       if request.form.get("editCommission"): # submit button pressed
            artists = request.form.getlist("artists")
            genres = request.form.getlist("genre")
            mediums = request.form.getlist("medium")
            customer = request.form["customer"]
            requestStatus = request.form["requestStatus"]
            dateRequested = request.form["dateRequested"]
            dateCompleted = request.form["dateCompleted"]
            price = request.form["price"]

            app.logger.info({"artists":artists, "genres":genres, "mediums":mediums, "customer":customer, "requestStatus":requestStatus, 
                             "dateRequested":dateRequested, "dateCompleted":dateCompleted, "price":price})

            # update customer, requestStatus, dateRequested, price
            query = ("UPDATE Commissions SET customerID = %s, requestStatus = %s, dateRequested = %s, price = %s "
                     "WHERE commissionID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (customer, requestStatus, dateRequested, price, commissionID))
            mysql.connection.commit()

            # dateCompleted
            if dateCompleted is not None:
                query = ("UPDATE Commissions SET dateCompleted = %s "
                        "WHERE commissionID = %s;")
                cur = mysql.connection.cursor()
                cur.execute(query, (dateCompleted, commissionID))
                mysql.connection.commit()

            # artists ----------------------------------------------------------
            query = ("SELECT ArtistCommissions.artistID FROM ArtistCommissions "
                    "WHERE ArtistCommissions.commissionID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (commissionID,))
            currArtistList = cur.fetchall()
            # turn into just ID list
            currArtistIDs = []
            for currArtist in currArtistList:
                currArtistIDs.append(currArtist['artistID'])
            
            # delete artists present in database but not selected in form
            currArtistIDsSave = currArtistIDs.copy() # so we don't mess up list by removing during iteration
            for currArtist in currArtistIDs:
                if currArtist not in artists: # not selected on form, remove
                    currArtistIDsSave.remove(currArtist) # so we don't add it back later
                    query = ("DELETE FROM ArtistCommissions WHERE artistID = %s AND commissionID = %s; ")
                    cur.execute(query, (currArtist, commissionID,))
                    mysql.connection.commit()
            currArtistIDs = currArtistIDsSave

            # add artists selected in form not in database yet
            for currArtist in artists:
                if currArtist not in currArtistIDs:
                    query = ("INSERT INTO ArtistCommissions (commissionID, artistID) VALUES(%s, %s); ")
                    cur = mysql.connection.cursor()
                    cur.execute(query, (commissionID, currArtist))
                    mysql.connection.commit()
            
            # genres ----------------------------------------------------------
            query = ("SELECT CommissionGenres.genreID FROM CommissionGenres "
                    "WHERE CommissionGenres.commissionID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (commissionID,))
            currGenreList = cur.fetchall()
            # turn into just ID list
            currGenreIDs = []
            for currGenre in currGenreList:
                currGenreIDs.append(currGenre['genreID'])
            
            currGenreIDsSave = currGenreIDs.copy()
            # delete genres
            for currGenre in currGenreIDs:
                if currGenre not in genres: # not selected on form, remove
                    currGenreIDsSave.remove(currGenre) # so we don't add it back later
                    query = ("DELETE FROM CommissionGenres WHERE genreID = %s AND commissionID = %s; ")
                    cur.execute(query, (currGenre, commissionID,))
                    mysql.connection.commit()
            currGenreIDs = currGenreIDsSave

            # add genres
            for currGenre in genres:
                if currGenre not in currGenreIDs:
                    query = ("INSERT INTO CommissionGenres (commissionID, genreID) VALUES(%s, %s); ")
                    cur = mysql.connection.cursor()
                    cur.execute(query, (commissionID, currGenre))
                    mysql.connection.commit()

            # mediums ----------------------------------------------------------
            query = ("SELECT CommissionMediums.mediumID FROM CommissionMediums "
                                "WHERE CommissionMediums.commissionID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (commissionID,))
            currMediumList = cur.fetchall()
            # turn into just ID list
            currMediumIDs = []
            for currMedium in currMediumList:
                currMediumIDs.append(currMedium['mediumID'])
            
            currMediumIDsSave = currMediumIDs.copy()
            # delete mediums
            for currMedium in currMediumIDs:
                if currMedium not in mediums: # not selected on form, remove
                    currMediumIDsSave.remove(currMedium) # so we don't add it back later
                    query = ("DELETE FROM CommissionMediums WHERE mediumID = %s AND commissionID = %s; ")
                    cur.execute(query, (currMedium, commissionID,))
                    mysql.connection.commit()
            currMediumIDs = currMediumIDsSave

            # add mediums
            for currMedium in mediums:
                if currMedium not in currMediumIDs:
                    query = ("INSERT INTO CommissionMediums (commissionID, mediumID) VALUES(%s, %s); ")
                    cur = mysql.connection.cursor()
                    cur.execute(query, (commissionID, currMedium))
                    mysql.connection.commit()

            return redirect("/commissions")

    if request.method == "GET":
        queryComission = "SELECT * FROM Commissions WHERE commissionID=%s;"
        cur = mysql.connection.cursor()
        cur.execute(queryComission, (commissionID,))
        CommissionDisplay = cur.fetchall()

        queryGenre = "SELECT Distinct genreID, type AS type FROM Genres;"
        cur = mysql.connection.cursor()
        cur.execute(queryGenre)
        genreDisplay = cur.fetchall()

        queryMedium = "SELECT Distinct mediumID, type AS type FROM Mediums;"
        cur = mysql.connection.cursor()
        cur.execute(queryMedium)
        mediumDisplay = cur.fetchall()

        queryArtist = "SELECT Distinct artistID, email FROM Artists;"
        ur = mysql.connection.cursor()
        cur.execute(queryArtist)
        artistDisplay = cur.fetchall()

        queryCustomer = "SELECT Distinct customerID, email FROM Customers;"
        ur = mysql.connection.cursor()
        cur.execute(queryCustomer)
        customerDisplay = cur.fetchall()

        querycurrGenre = ("SELECT CommissionGenres.genreID AS genreID, type AS type FROM CommissionGenres " 
                "LEFT JOIN Commissions ON Commissions.commissionID = CommissionGenres.commissionID "
                "LEFT JOIN Genres ON Genres.genreID = CommissionGenres.genreID "
                "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrGenre, (commissionID,))
        currGenreList = cur.fetchall()

        querycurrMedium = ("SELECT CommissionMediums.mediumID AS mediumID, type AS type FROM CommissionMediums " 
                        "LEFT JOIN Commissions ON Commissions.commissionID = CommissionMediums.commissionID "
                        "LEFT JOIN Mediums ON Mediums.mediumID = CommissionMediums.mediumID "
                        "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrMedium, (commissionID,))
        currMediumList = cur.fetchall()

        querycurrArtist = ("SELECT ArtistCommissions.artistID AS artistID, email AS email FROM ArtistCommissions " 
                        "LEFT JOIN Artists ON Artists.artistID = ArtistCommissions.artistID "
                        "LEFT JOIN Commissions ON Commissions.commissionID = ArtistCommissions.commissionID "
                        "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrArtist, (commissionID,))
        currArtistList = cur.fetchall()

        querycurrCustomer = ("SELECT Commissions.customerID AS customerID, Customers.email AS email "
                            "FROM Commissions "
                            "LEFT JOIN Customers ON Customers.customerID = Commissions.customerID "
                            "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrCustomer, (commissionID,))
        currCustomerList = cur.fetchall()

        # RequestStatus -----------------------------------------------------------
        requestEnumValues = {"Request Unclaimed":1, "Request Claimed":2, "Request Complete":3, "Request Cancelled":4}
        querycurrRequestStatus = ("SELECT Commissions.requestStatus as requestStatus "
                                  "FROM Commissions "
                                  "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrRequestStatus, (commissionID,))
        currRequestStatus = cur.fetchall()[0]
        # set back to enum int
        currRequestStatus = requestEnumValues[currRequestStatus["requestStatus"]]

        # dateRequested -----------------------------------------------------------
        querycurrDateRequested = ("SELECT Commissions.dateRequested as dateRequested "
                                "FROM Commissions "
                                "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrDateRequested, (commissionID,))
        # YYYY-MM-DDTHH:mm - source: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime-local
        currDateRequested = cur.fetchall()[0]["dateRequested"].strftime("%Y-%m-%dT%H:%M")

        # dateCompleted -----------------------------------------------------------
        querycurrDateCompleted = ("SELECT Commissions.dateCompleted as dateCompleted "
                                "FROM Commissions "
                                "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrDateCompleted, (commissionID,))
        currDateCompleted = cur.fetchall()[0]["dateCompleted"] # YYYY-MM-DD
        if currDateCompleted is not None:
            currDateCompleted = currDateCompleted.strftime("%Y-%m-%d")
        app.logger.info(currDateCompleted)

        # price -----------------------------------------------------------
        querycurrPrice = ("SELECT Commissions.price as price "
                        "FROM Commissions "
                        "WHERE Commissions.commissionID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrPrice, (commissionID,))
        currPrice = cur.fetchall()[0]["price"] # YYYY-MM-DD
        app.logger.info(currArtistList)
        app.logger.info(artistDisplay)
        
        return render_template("editCommission.j2", CommissionDisplay=CommissionDisplay, genreDisplay=genreDisplay, mediumDisplay=mediumDisplay, artistDisplay=artistDisplay, customerDisplay=customerDisplay, 
                               currGenreList=currGenreList, currMediumList=currMediumList, currArtistList=currArtistList, currCustomerList=currCustomerList, currRequestStatus=currRequestStatus,
                               currDateRequested=currDateRequested, currDateCompleted=currDateCompleted, currPrice=currPrice)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------Customers-------
@app.route('/customers', methods=["POST", "GET"])
def customers():
    if request.method == "POST":
        if request.form.get("insertCustomer"): # submit button pressed
            email = request.form["email"]
            name = request.form["name"]
            birthday = request.form["birthday"]

            # account for null birthday
            if birthday == "":
                query = ("INSERT INTO Customers (email, name) VALUES(%s, %s);")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

            # not null birthday
            else:
                query = ("INSERT INTO Customers (email, name, birthday) VALUES(%s, %s, %s);")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name, birthday))
                mysql.connection.commit()
        return redirect("/customers")
        
    if request.method == "GET":
        # Grab Artist data so we send it to our template to display
        query = ("SELECT Customers.customerID as customerID, Customers.email as  email, Customers.name as name, Customers.birthday as birthday, COUNT(DISTINCT Commissions.commissionID) as totalOrders "
                 "FROM Customers "
                 "LEFT JOIN Commissions ON Commissions.customerID = Customers.customerID "
                 "GROUP BY customerID;")
        cur = mysql.connection.cursor()
        cur.execute(query)
        customerTableDisplay = cur.fetchall()
    return render_template("customers.j2", customerTableDisplay=customerTableDisplay)

# delete
@app.route("/deleteCustomer/<int:customerID>")
def deleteCustomer(customerID):
    query = "DELETE FROM Customers WHERE customerID = %s;"
    cur = mysql.connection.cursor()
    cur.execute(query, (customerID,))
    mysql.connection.commit()
    return redirect("/customers")

#------------------------------------------------------------------------------------------------------------------------------------------------------------------Edit Customers-----

# route for edit functionality, updating the attributes of a person in bsg_people
# similar to our delete route, we want to the pass the 'id' value of that person on button click (see HTML) via the route
@app.route("/editCustomer/<int:customerID>", methods=["POST", "GET"])
def editCustomers(customerID):
    if request.method == "GET":
    # Grab Artist data so we send it to our template to display
        query = "SELECT * FROM Customers WHERE customerID = %s;"
        cur = mysql.connection.cursor()
        cur.execute(query, (customerID,)) #it doesn't work without the comma
        editCustomerData = cur.fetchall()
        return render_template("editCustomer.j2", editCustomerData=editCustomerData)

    if request.method == "POST":
       if request.form.get("editCustomer"): # submit button pressed
            email = request.form["email"]
            name = request.form["name"]
            birthday = request.form["birthday"]

            # Update email, name only
            query = ("UPDATE Customers SET email = %s, name = %s WHERE customerID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (email, name, customerID))
            mysql.connection.commit()
            
            # Update birthday
            if birthday != "":
                query = ("UPDATE Customers SET birthday = %s WHERE customerID = %s;")
                cur = mysql.connection.cursor()
                cur.execute(query, (birthday, customerID))
                mysql.connection.commit()
            return redirect("/customers")
#------------------------------------------------------------------------------------------------------------------------------------------------------------------Genres----------

# main page + add
@app.route('/genres', methods=["POST", "GET"])
def genres():
    # load table/dropdowns
    if request.method == "GET":
        # Grab Genres data so we send it to our template to display
        query = ("SELECT Genres.genreID AS genreID, Genres.type AS type, COUNT(DISTINCT CASE WHEN ArtistGenres.genreID = Genres.genreID THEN ArtistGenres.artistID END) AS artistCount, COUNT(DISTINCT CASE WHEN CommissionGenres.genreID = Genres.genreID THEN CommissionGenres.commissionID END) AS commissionCount "
                "FROM Genres "
                "LEFT JOIN CommissionGenres ON CommissionGenres.genreID = Genres.genreID "
                "LEFT JOIN ArtistGenres ON ArtistGenres.genreID = Genres.genreID "
                "GROUP BY Genres.genreID;"
            
        )
        cur = mysql.connection.cursor()
        cur.execute(query)
        genreTableDisplay = cur.fetchall()

        return render_template("genres.j2", genreTableDisplay=genreTableDisplay)

    # add genre
    if request.method == "POST":
        if request.form.get("insertGenre"): # submit button pressed
            type = request.form["type"]

            query = ("INSERT INTO Genres (type) VALUES (%s);")
            cur = mysql.connection.cursor()
            cur.execute(query, (type,))
            mysql.connection.commit()

        return redirect("/genres")

# edit     
@app.route("/editGenre/<int:genreID>", methods=["POST", "GET"])
def editGenre(genreID):
    if request.method == "GET":
    # Grab genre data so we send it to our template to display
        query = "SELECT * FROM Genres WHERE genreID = %s;"
        cur = mysql.connection.cursor()
        cur.execute(query, (genreID,))
        editGenreData = cur.fetchall()
    
        return render_template("editGenre.j2", editGenreData=editGenreData)

    if request.method == "POST":
        if request.form.get("editGenre"): # submit button pressed
            type = request.form["type"]

            query = ("UPDATE Genres SET type = %s WHERE genreID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (type, genreID))
            mysql.connection.commit()
            
            return redirect("/genres")

# delete
@app.route("/deleteGenre/<int:genreID>")
def deleteGenre(genreID):
    query = "DELETE FROM Genres WHERE genreID = %s;"
    cur = mysql.connection.cursor()
    cur.execute(query, (genreID,))
    mysql.connection.commit()

    return redirect("/genres")
#------------------------------------------------------------------------------------------------------------------------------------------------------------------Mediums---------

# main page + add
@app.route('/mediums', methods=["POST", "GET"])
def mediums():
    # load table/dropdowns
    if request.method == "GET":
        # Grab Mediums data so we send it to our template to display
        query = ("SELECT Mediums.mediumID AS mediumID, Mediums.type AS type, COUNT(DISTINCT CASE WHEN ArtistMediums.mediumID = Mediums.mediumID THEN ArtistMediums.artistID END) AS artistCount, COUNT(DISTINCT CASE WHEN CommissionMediums.mediumID = Mediums.mediumID THEN CommissionMediums.commissionID END) AS commissionCount "
                "FROM Mediums "
                "LEFT JOIN CommissionMediums ON CommissionMediums.mediumID = Mediums.mediumID "
                "LEFT JOIN ArtistMediums ON ArtistMediums.mediumID = Mediums.mediumID "
                "GROUP BY Mediums.mediumID;"
            
        )
        cur = mysql.connection.cursor()
        cur.execute(query)
        mediumTableDisplay = cur.fetchall()

        return render_template("mediums.j2", mediumTableDisplay=mediumTableDisplay)

    # add medium
    if request.method == "POST":
        if request.form.get("insertMedium"): # submit button pressed
            type = request.form["type"]

            query = ("INSERT INTO Mediums (type) VALUES (%s);")
            cur = mysql.connection.cursor()
            cur.execute(query, (type,))
            mysql.connection.commit()

        return redirect("/mediums")

# edit     
@app.route("/editMedium/<int:mediumID>", methods=["POST", "GET"])
def editMedium(mediumID):
    if request.method == "GET":
    # Grab medium data so we send it to our template to display
        query = "SELECT * FROM Mediums WHERE mediumID = %s;"
        cur = mysql.connection.cursor()
        cur.execute(query, (mediumID,))
        editMediumData = cur.fetchall()
    
        return render_template("editMedium.j2", editMediumData=editMediumData)

    if request.method == "POST":
        if request.form.get("editMedium"): # submit button pressed
            type = request.form["type"]

            query = ("UPDATE Mediums SET type = %s WHERE mediumID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (type, mediumID))
            mysql.connection.commit()
            
            return redirect("/mediums")

# delete
@app.route("/deleteMedium/<int:mediumID>")
def deleteMedium(mediumID):
    query = "DELETE FROM Mediums WHERE mediumID = %s;"
    cur = mysql.connection.cursor()
    cur.execute(query, (mediumID,))
    mysql.connection.commit()

    return redirect("/mediums")

#------------------------------------------------------------------------------------------------------------------------------------------------------------------Artists---------


@app.route("/artists", methods=["POST", "GET"])
def artists():
    
    # edit
    if request.method == "POST":
        if request.form.get("insertArtist"): # name of submit button is "addArtist"
            email = request.form["email"]
            name = request.form["name"]
            genre = request.form.getlist("genre") # id
            medium = request.form.getlist("medium") # id

            # Account for null genre AND null medium
            if genre == "0" and medium == "0":
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES (%s, %s, 0);")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

            # Account for null genre
            elif genre == "0":
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES(%s, %s, 0);")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

                query2 = ("INSERT INTO ArtistMediums(artistID, mediumID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                for mediumtype in medium:
                    cur.execute(query2, (email, mediumtype))
                    mysql.connection.commit()
                            
            # Account for null Medium
            elif medium == "0":
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES(%s, %s, 0); ")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

                

                query2 = ("INSERT INTO ArtistGenres(artistID, genreID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()

                for genretype in genre:
                    cur.execute(query2, (email, genretype))
                    mysql.connection.commit()

            # No Null values
            else:
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES(%s, %s, 0); ")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

                query2 = ("INSERT INTO ArtistMediums(artistID, mediumID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                for mediumtype in medium:
                    cur.execute(query2, (email, mediumtype))
                    mysql.connection.commit()

                query3 = ("INSERT INTO ArtistGenres(artistID, genreID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                for genretype in genre:
                    cur.execute(query3, (email, genretype))
                    mysql.connection.commit()
        
            return redirect("/artists")

    # load table/dropdowns
    if request.method == "GET":
        # Grab Artist data so we send it to our template to display
        query = ("SELECT Artists.artistID AS artistID, Artists.email AS email, Artists.name AS name, COUNT(DISTINCT Commissions.commissionID, Commissions.requestStatus = 'Request Complete') AS completedCount, GROUP_CONCAT(DISTINCT Genres.type) as genre, GROUP_CONCAT(DISTINCT Mediums.type) AS medium "
                "FROM Artists "
                "LEFT JOIN ArtistCommissions ON Artists.artistID = ArtistCommissions.artistID "
                "LEFT JOIN Commissions ON ArtistCommissions.commissionID = Commissions.commissionID "
                "LEFT JOIN ArtistGenres ON Artists.artistID = ArtistGenres.artistID "
                "LEFT JOIN ArtistMediums ON Artists.artistID = ArtistMediums.artistID "
                "LEFT JOIN Genres ON ArtistGenres.genreID = Genres.genreID "
                "LEFT JOIN Mediums ON ArtistMediums.mediumID = Mediums.mediumID "
                "GROUP BY artistID;")
        cur = mysql.connection.cursor()
        cur.execute(query)
        artistTableDisplay = cur.fetchall()

        queryArtistID = ("SELECT Distinct artistID "
                        "FROM Artists "
                        "ORDER BY artistID;")
        cur = mysql.connection.cursor()
        cur.execute(queryArtistID)
        artistIDDisplay = cur.fetchall()
    
        queryGenre = "SELECT Distinct genreID, type AS type FROM Genres;"
        cur = mysql.connection.cursor()
        cur.execute(queryGenre)
        genreDisplay = cur.fetchall()

        queryMedium = "SELECT Distinct mediumID, type AS type FROM Mediums;"
        cur = mysql.connection.cursor()
        cur.execute(queryMedium)
        mediumDisplay = cur.fetchall()

        return render_template("artists.j2", artistTableDisplay=artistTableDisplay, artistIDDisplay=artistIDDisplay, genreDisplay=genreDisplay, mediumDisplay=mediumDisplay)
    
# delete
@app.route("/deleteArtist/<int:artistID>")
def deleteArtist(artistID):
    query = "DELETE FROM Artists WHERE artistID = %s;"
    cur = mysql.connection.cursor()
    cur.execute(query, (artistID,))
    mysql.connection.commit()

    return redirect("/artists")

#------------------------------------------------------------------------------------------------------------------------------------------------------------------Edit Artists-----

# route for edit functionality, updating the attributes of a person in bsg_people
# similar to our delete route, we want to the pass the 'id' value of that person on button click (see HTML) via the route
@app.route("/editArtist/<int:artistID>", methods=["POST", "GET"])
def editArtist(artistID):
    if request.method == "GET":
    # Grab Artist data so we send it to our template to display
        query = "SELECT * FROM Artists WHERE artistID = %s;"
        cur = mysql.connection.cursor()
        cur.execute(query, (artistID,)) #it doesn't work without the comma
        editArtistData = cur.fetchall()
    
        queryGenre = "SELECT Distinct genreID, type AS type FROM Genres;"
        cur = mysql.connection.cursor()
        cur.execute(queryGenre)
        genreDisplay = cur.fetchall()

        queryMedium = "SELECT Distinct mediumID, type AS type FROM Mediums;"
        cur = mysql.connection.cursor()
        cur.execute(queryMedium)
        mediumDisplay = cur.fetchall()  

        querycurrGenre = ("SELECT ArtistGenres.genreID AS genreID, type AS type FROM ArtistGenres " 
                        "LEFT JOIN Artists ON Artists.artistID = ArtistGenres.artistID "
                        "LEFT JOIN Genres ON Genres.genreID = ArtistGenres.genreID "
                        "WHERE Artists.artistID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrGenre, (artistID,))
        currGenreList = cur.fetchall()

        querycurrMedium = ("SELECT ArtistMediums.mediumID AS mediumID, type AS type FROM ArtistMediums " 
                        "LEFT JOIN Artists ON Artists.artistID = ArtistMediums.artistID "
                        "LEFT JOIN Mediums ON Mediums.mediumID = ArtistMediums.mediumID "
                        "WHERE Artists.artistID = %s;")
        cur = mysql.connection.cursor()
        cur.execute(querycurrMedium, (artistID,))
        currMediumList = cur.fetchall()
 
      

        return render_template("editArtist.j2", editArtistData=editArtistData, genreDisplay=genreDisplay, mediumDisplay=mediumDisplay, currGenreList=currGenreList, currMediumList=currMediumList)

    if request.method == "POST":
       if request.form.get("editArtist"): # submit button pressed
            email = request.form["email"]
            name = request.form["name"]
            formGenres = request.form.getlist("genre") # id
            formMediums = request.form.getlist("medium") # id
            

            # Update email, name only
            query = ("UPDATE Artists SET email = %s, name = %s WHERE artistID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (email, name, artistID))
            mysql.connection.commit()
            
            # genres ----------------------------------------------------------
            query = ("SELECT ArtistGenres.genreID FROM ArtistGenres "
                    "WHERE ArtistGenres.artistID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (artistID,))
            currGenreList = cur.fetchall()
            # turn into just ID list
            currGenreIDs = []
            for currGenre in currGenreList:
                currGenreIDs.append(currGenre['genreID'])
            
            currGenreIDsSave = currGenreIDs.copy()
            # delete genres
            for currGenre in currGenreIDs:
                if currGenre not in formGenres: # not selected on form, remove
                    app.logger.info(currGenre)
                    currGenreIDsSave.remove(currGenre) # so we don't add it back later
                    query = ("DELETE FROM ArtistGenres WHERE genreID = %s AND artistID = %s; ")
                    cur.execute(query, (currGenre, artistID,))
                    mysql.connection.commit()

            app.logger.info(currGenreIDs)
            app.logger.info(currGenreIDsSave)
            currGenreIDs = currGenreIDsSave

            # add genres
            for currGenre in formGenres:
                if currGenre not in currGenreIDs:
                    app.logger.info(currGenre)
                    query = ("INSERT INTO ArtistGenres (artistID, genreID) VALUES(%s, %s); ")
                    cur = mysql.connection.cursor()
                    cur.execute(query, (artistID, currGenre))
                    mysql.connection.commit()

            # mediums ----------------------------------------------------------
            query = ("SELECT ArtistMediums.mediumID FROM ArtistMediums "
                                "WHERE ArtistMediums.artistID = %s;")
            cur = mysql.connection.cursor()
            cur.execute(query, (artistID,))
            currMediumList = cur.fetchall()
            # turn into just ID list
            currMediumIDs = []
            for currMedium in currMediumList:
                currMediumIDs.append(currMedium['mediumID'])
            
            currMediumIDsSave = currMediumIDs.copy()
            # delete mediums
            for currMedium in currMediumIDs:
                if currMedium not in formMediums: # not selected on form, remove
                    currMediumIDsSave.remove(currMedium) # so we don't add it back later
                    query = ("DELETE FROM ArtistMediums WHERE mediumID = %s AND artistID = %s; ")
                    cur.execute(query, (currMedium, artistID,))
                    mysql.connection.commit()
            currMediumIDs = currMediumIDsSave

            # add mediums
            for currMedium in formMediums:
                if currMedium not in currMediumIDs:
                    query = ("INSERT INTO ArtistMediums (artistID, mediumID) VALUES(%s, %s); ")
                    cur = mysql.connection.cursor()
                    cur.execute(query, (artistID, currMedium))
                    mysql.connection.commit()
            
            return redirect("/artists")


# Listener
if __name__ == "__main__":

    #Start the app on port 3000, it will be different once hosted
    app.run(port=59575, debug=True)

    # 59575 
    # gunicorn -b 0.0.0.0:59576 -D app:app
