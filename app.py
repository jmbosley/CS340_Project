from flask import Flask, render_template, json, redirect
from flask_mysqldb import MySQL
from flask import request
import os

app = Flask(__name__, static_url_path='/static')

app.config['MYSQL_HOST'] = 'classmysql.engr.oregonstate.edu'
app.config['MYSQL_USER'] = 'cs340_bosleyj'
app.config['MYSQL_PASSWORD'] = '5957' #last 4 of onid
app.config['MYSQL_DB'] = 'cs340_bosleyj'
app.config['MYSQL_CURSORCLASS'] = "DictCursor"


mysql = MySQL(app)


# Routes
@app.route('/')
def root():
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
    tableDisplay = cur.fetchall()
    
    queryGenre = "SELECT Distinct genreID, type AS type FROM Genres;"
    cur = mysql.connection.cursor()
    cur.execute(queryGenre)
    genreDisplay = cur.fetchall()

    return render_template("main.j2", tableDisplay=tableDisplay, genreDisplay=genreDisplay)

@app.route("/artist", methods=["POST", "GET"])
def artist():
    if request.method == "POST":
        if request.form.get("Add_Person"):
            email = request.form["email"]
            name = request.form["name"]
            genre = request.form["genre"]
            medium = request.form["medium"]
            
            # Account for null genre AND null medium
            if genre == "" and medium == "":
                query = ("INSERT INTO Artists (email, name) "
                         "VALUES (%s, %s);")
            # Account for null genre
            elif genre == "":
                query = ("INSERT INTO Artists (email, name, medium) "
                         "VALUES (%s, %s, %s);")
            # Account for null Medium
            elif medium == "":
                query = ("INSERT INTO Artists (email, name, genre) "
                         "VALUES (%s, %s, %s);")
            # No Null values
            else:
                query = ("INSERT INTO Artists (email, name, genre, medium) "
                         "VALUES (%s, %s, %s, %s);")
            cur = mysql.connection.cursor()
            cur.execute(query, (email, name, genre, medium))
            mysql.connection.commit()
            return redirect("/")




    

# Listener
if __name__ == "__main__":

    #Start the app on port 3000, it will be different once hosted
    app.run(port=59575, debug=True)