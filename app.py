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
    query = ("SELECT Artists.artistID, Artists.email, Artists.name, Artists.completedCount, Genres.type, Mediums.type "
             "FROM Artists "
             "LEFT JOIN ArtistGenres ON Artists.artistID = ArtistGenres.artistID "
             "LEFT JOIN ArtistMediums ON Artists.artistID = ArtistMediums.artistID "
             "LEFT JOIN Genres ON ArtistGenres.genreID = Genres.genreID "
             "LEFT JOIN Mediums ON ArtistMediums.mediumID = Mediums.mediumID;")
    cur = mysql.connection.cursor()
    cur.execute(query)
    tableDisplay = cur.fetchall()
    return render_template("main.j2", tableDisplay=tableDisplay)


    

# Listener
if __name__ == "__main__":

    #Start the app on port 3000, it will be different once hosted
    app.run(port=59575, debug=True)