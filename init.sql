CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    price NUMERIC(6,2) NOT NULL
);

INSERT INTO books (title, author, price) VALUES
('The Hobbit', 'J.R.R. Tolkien', 15.99),
('Clean Code', 'Robert C. Martin', 32.50),
('1984', 'George Orwell', 10.00),
('Atomic Habits', 'James Clear', 18.75),
('Dune', 'Frank Herbert', 14.20);
