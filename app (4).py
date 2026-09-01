from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
import os
import time

app = Flask(__name__)
CORS(app)


def get_connection():
    for attempt in range(10):
        try:
            return psycopg2.connect(
                host=os.environ.get("DB_HOST", "db"),
                dbname=os.environ.get("DB_NAME", "shopdb"),
                user=os.environ.get("DB_USER", "admin"),
                password=os.environ.get("DB_PASSWORD", "admin123"),
            )
        except psycopg2.OperationalError:
            print("DB not ready yet, retrying in 3s...")
            time.sleep(3)
    raise Exception("Could not connect to the database")


@app.route("/")
def home():
    return jsonify({"service": "book-service", "status": "running"})


@app.route("/books", methods=["GET"])
def get_books():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, title, author, price FROM books")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    books = [
        {"id": r[0], "title": r[1], "author": r[2], "price": float(r[3])}
        for r in rows
    ]
    return jsonify(books), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
