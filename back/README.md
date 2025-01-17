# Café sans-fil mobile (backend)

This repository contains the backend code for the Café sans-fil mobile application. 
The backend is built using Node.js and Express.js, and it connects to a MongoDB database.

## 🌐 Infrastructure

### 🗄️ Database

- [**MongoDB**](https://www.mongodb.com/): A NoSQL document-oriented database.

### 🔗 API

- [**Node.js**](https://nodejs.org/en): A JavaScript runtime built on Chrome's V8 JavaScript engine.
- [**Express.js**](https://expressjs.com): A web application framework for Node.js.

## 🚀 Getting Started

### Prerequisites

- Node.js
- npm (Node Package Manager)
- MongoDB

### Installation

#### 1. Install the dependencies:

```sh
npm install
```

#### 2. Create a `.env` file in the root directory and add your environment variables:

>  The `.env` file is used to store environment variables to keep sensitive values and environment-specific configurations out of the source code and to facilitate the application's configuration.

```env
MONGODB_URI=<MONGO_DB_CONNECTION_STRING>
MONGO_DB_NAME="cafesansfilmobilenew"
PORT=3000
PHRASE_PASS=PHRASE_SECRET
ENCRYPTION_KEY=PHRASE_SECRET_ENCRYPTION
```

💡**Note:** The values `<MONGO_DB_CONNECTION_STRING>` are placeholders. You need to replace them with your own values before deploying or running the backend.

#### 3. Start the server:

```sh
npm run dev
```

## 📂 Project Structure

- `src/contollers`: Contains the controllers for handling requests.
- `src/database`: Contains the database connection logic.
- `src/routes`: Contains the route definitions.
- `src/services`: Contains the services that communicate with the database.
- `tests`: Contains the test cases.

<!-- ## 🛠️ API Endpoints

### User Routes

- `GET /users`: Get all users.
- `POST /users`: Create a new user.
- `GET /users/:id`: Get a user by ID.
- `PUT /users/:id`: Update a user by ID.
- `DELETE /users/:id`: Delete a user by ID.

### Product Routes

- `GET /products`: Get all products.
- `POST /products`: Create a new product.
- `GET /products/:id`: Get a product by ID.
- `PUT /products/:id`: Update a product by ID.
- `DELETE /products/:id`: Delete a product by ID. -->

<!-- ## 📘 Documentation

For more detailed documentation, please refer to the [Wiki](https://github.com/ceduni/cafe-sans-fil/wiki). -->