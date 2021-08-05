from flask import Flask, render_template, request
from flask_pymongo import PyMongo
import datetime 

app = Flask(__name__)

#setup mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/shows_db"
mongo = PyMongo(app)

#connect to collection
tv_shows = mongo.db.tv_shows

#READ
@app.route("/")
def index():
    #find all items in db and save to variable
    all_shows = list(tv_shows.find())
    print(all_shows)

    return render_template("index.html",data=all_shows)


#UPDATE 
@app.route("/update", methods=["GET", "POST"])
def update():
    if request.method == "POST":
        data = request.form

        update_show = {"name" : data['old_name']}

        post_data = { '$set': {'name': data['name'], 
            'seasons': data['seasons'],
            'duration': data['length'],
            'year': data['year_started'],
            }}

        tv_shows.update_one(update_show, post_data)
        return render_template("success.html", data = data)

    else:    
        return render_template("update.html")


#CREATE
@app.route("/add", methods=["POST", "GET"])    
def add():
    if request.method == "POST":
        # data in a dictionary
        data = request.form

        post_data = {'name': data['name'], 
            'seasons': data['seasons'],
            'duration': data['length'],
            'year': data['year_started'],
            'date_added': datetime.datetime.utcnow()
            }

        tv_shows.insert_one(post_data)

        return render_template("success.html", data = data)


    else:    
        return render_template("add.html")

#Delete
@app.route("/delete", methods=["POST", "GET"])
def delete():
    if request.method == "POST":
        data = request.form

        tv_shows.delete_one({'name': data['name']})
        return render_template("success.html", data = data)


    else:    
        return render_template("delete.html")


if __name__ == "__main__":
    app.run(debug=True)