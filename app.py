from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import os
import time

app = Flask(__name__)
CORS(app)  # allow the frontend (different port) to call this API


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
    return jsonify({"service": "auth-service", "status": "running"})


@app.route("/signup", methods=["POST"])
def signup():
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "username and password required"}), 400

    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO users (username, password) VALUES (%s, %s)",
            (username, password),
        )
        conn.commit()
        return jsonify({"message": "user created"}), 201
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        return jsonify({"error": "username already exists"}), 409
    finally:
        cur.close()
        conn.close()


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT id FROM users WHERE username = %s AND password = %s",
        (username, password),
    )
    user = cur.fetchone()
    cur.close()
    conn.close()

    if user:
        return jsonify({"message": "login successful", "user_id": user[0]}), 200
    return jsonify({"error": "invalid username or password"}), 401


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
