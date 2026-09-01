# Simple Shopping Microservices (Docker Practice)

A minimal microservices project with:

- **db** — Postgres database (stores `users` and `books`)
- **auth-service** — Flask microservice for login / signup
- **book-service** — Flask microservice for the bookstore (the "shop" data)
- **frontend** — plain HTML/JS pages (login + shop) served by nginx

## Project structure
```
shop-microservices/
├── docker-compose.yml
├── init.sql
├── auth-service/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── book-service/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
└── frontend/
    ├── Dockerfile
    └── html/
        ├── index.html   (login page)
        ├── login.html
        └── shop.html
```

## How to run (Git Bash)

1. Make sure Docker Desktop is running.
2. Open Git Bash in this folder (`shop-microservices`).
3. Build and start everything:
   ```bash
   docker-compose up --build
   ```
4. Open your browser:
   - Frontend (login/shop): http://localhost:8080
   - Auth service (API): http://localhost:5001
   - Book service (API): http://localhost:5002

5. On the login page, click **Sign Up** first to create a user, then **Login**.
   After login you'll be taken to the shop page, which pulls the book list
   from the book-service microservice.

## Stopping

```bash
docker-compose down
```

To also wipe the database data:
```bash
docker-compose down -v
```

## How it fits together

- `docker-compose.yml` starts 4 containers: `db`, `auth-service`, `book-service`, `frontend`.
- Both microservices connect to the **same** Postgres database (`db`) but only
  use the tables relevant to them (`users` for auth, `books` for the shop) —
  this keeps things simple while still showing separate services.
- `init.sql` runs automatically the first time the database container starts,
  creating tables and inserting a few sample books.
- The frontend is just static HTML calling the two APIs directly with `fetch()`.

## Notes
- Passwords are stored in plain text and CORS is wide open — this is for
  **learning Docker/microservices only**, not production use.
