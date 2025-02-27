from flask import Flask, render_template, json, redirect
from flask_mysqldb import MySQL
from flask import request
import os

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

@app.route("/artists", methods=["POST", "GET"])
def artists():
    
    # edit
    if request.method == "POST":
        if request.form.get("insertArtist"):
            email = request.form["email"]
            name = request.form["name"]
            genre = request.form["genre"] # id
            medium = request.form["medium"] # id

            # Account for null genre AND null medium
            if genre == "0" and medium == "0":
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES (%s, %s, 10);")
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
                cur.execute(query2, (email, medium))
                mysql.connection.commit()
	                    
            # Account for null Medium
            elif medium == "0":
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES(%s, %s, 0); ")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

                query2 = ("INSERT INTO ArtistGenres(artistID, genreID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                cur.execute(query2, (email, genre))
                mysql.connection.commit()

            # No Null values
            else:
                query = ("INSERT INTO Artists (email, name, completedCount) VALUES(%s, %s, 0); ")
                cur = mysql.connection.cursor()
                cur.execute(query, (email, name))
                mysql.connection.commit()

                query2 = ("INSERT INTO ArtistMediums(artistID, mediumID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                cur.execute(query2, (email, medium))
                mysql.connection.commit()

                query3 = ("INSERT INTO ArtistGenres(artistID, genreID) VALUES((SELECT artistID from Artists WHERE Artists.email= %s), %s);")
                cur = mysql.connection.cursor()
                cur.execute(query3, (email, genre))
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
    query = "DELETE FROM Artists WHERE artistID = '%s';"
    cur = mysql.connection.cursor()
    cur.execute(query, (artistID,))
    mysql.connection.commit()

    return redirect("/artists")

# route for edit functionality, updating the attributes of a person in bsg_people
# similar to our delete route, we want to the pass the 'id' value of that person on button click (see HTML) via the route
@app.route("/editArtist/<int:artistID>", methods=["POST", "GET"])
def editArtist(artistID):
    if request.method == "GET":
        query = "SELECT * FROM Artists WHERE id = %s" % (artistID)
        cur = mysql.connection.cursor()
        cur.execute(query)
        editArtistData = cur.fetchall()

        # render edit_people page passing our query data and homeworld data to the edit_people template (might beed to make another file?)
        return render_template("artists.j2", editArtistData=editArtistData) # reload page will filled data?





    

# Listener
if __name__ == "__main__":

    #Start the app on port 3000, it will be different once hosted
    app.run(port=59576, debug=True)

    # 59575 
    # gunicorn -b 0.0.0.0:59576 -D app:app