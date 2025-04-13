-- creating the database 
CREATE DATABASE BookStore;

-- selecting the BookStore database
USE BookStore;

-- Independent Tables
CREATE TABLE Country (
    Country_id INT PRIMARY KEY,
    Country_name VARCHAR(100)
);

CREATE TABLE Book_language (
    Language_ID INT PRIMARY KEY,
    Language_Name VARCHAR(100)
);

CREATE TABLE Address_Status (
    Address_Status_ID INT PRIMARY KEY,
    Status_name VARCHAR(100)
);

CREATE TABLE Shipping_method (
    Shipping_method_id INT PRIMARY KEY,
    Method_name VARCHAR(100),
    Estimated_Days INT,
    Cost DECIMAL(10,2)
);

CREATE TABLE Order_status (
    Order_status_id INT PRIMARY KEY,
    Status_name VARCHAR(100)
);

CREATE TABLE Author (
    Author_ID INT PRIMARY KEY,
    Author_Name VARCHAR(255),
    Author_Age INT,
    Nationality VARCHAR(100)
);

CREATE TABLE Address (
    Address_id INT PRIMARY KEY,
    City VARCHAR(100),
    Street VARCHAR(100),
    Postal_code INT,
    Country_id INT,
    FOREIGN KEY (Country_id) REFERENCES Country(Country_id)
);

CREATE TABLE Publisher (
    Publisher_ID INT PRIMARY KEY,
    Publisher_name VARCHAR(255),
    Publisher_Age INT,
    Phone VARCHAR(20),
    Nationality VARCHAR(255),
    Address_id INT,
    FOREIGN KEY (Address_id) REFERENCES Address(Address_id)
);

CREATE TABLE Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255),
    Pages INT,
    Price DECIMAL(10,2),
    Quantity INT,
    Publication_year INT,
    Language_ID INT,
    Publisher_ID INT,
    FOREIGN KEY (Language_ID) REFERENCES Book_language(Language_ID),
    FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID)
);

CREATE TABLE Customer (
    Customer_id INT PRIMARY KEY,
    Customer_name VARCHAR(255),
    Customer_Age INT,
    Customer_Phone VARCHAR(20)
);

CREATE TABLE Customer_Address (
    Customer_Address_id INT PRIMARY KEY,
    Customer_id INT,
    Address_name VARCHAR(100),
    Address_Status_ID INT,
    FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
    FOREIGN KEY (Address_Status_ID) REFERENCES Address_Status(Address_Status_ID)
);

-- Tables depending on multiple others
CREATE TABLE Cust_Order (
    Order_id INT PRIMARY KEY,
    Customer_id INT,
    Order_date DATE,
    Customer_Address_id INT,
    Shipping_method_id INT,
    Order_status_id INT,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
    FOREIGN KEY (Customer_Address_id) REFERENCES Customer_Address(Customer_Address_id),
    FOREIGN KEY (Shipping_method_id) REFERENCES Shipping_method(Shipping_method_id),
    FOREIGN KEY (Order_status_id) REFERENCES Order_status(Order_status_id)
);

CREATE TABLE Order_line (
    Order_line_id INT PRIMARY KEY,
    Order_id INT,
    BookID INT,
    FOREIGN KEY (Order_id) REFERENCES Cust_Order(Order_id),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

CREATE TABLE Order_history (
    Order_history_id INT PRIMARY KEY,
    Order_id INT,
    Order_status_id INT,
    Order_date DATE,
    FOREIGN KEY (Order_id) REFERENCES Cust_Order(Order_id),
    FOREIGN KEY (Order_status_id) REFERENCES Order_status(Order_status_id)
);

CREATE TABLE Book_Author (
    BookID INT,
    Author_ID INT,
    PRIMARY KEY (BookID, Author_ID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID)
);

-- REMOVED invalid ALTER TABLE statement: it was missing a table name
-- ❌ This was wrong:
-- ALTER TABLE 
-- ADD COLUMN Customer_Address_id INT,
-- ADD CONSTRAINT ...

-- ✅ REMOVED redundant foreign key declarations already defined in CREATE TABLEs
-- You already defined all foreign keys inline during table creation above,
-- so there's no need to use ALTER TABLE again to add the same ones.


-- ------------------------------------------------------
-- USER ROLES AND ACCESS CONTROL FOR BookStore DATABASE
-- ------------------------------------------------------

-- 1. Create roles for different groups
CREATE ROLE Bookstore_Admin;
CREATE ROLE Inventory_Manager;
CREATE ROLE Sales_Rep;
CREATE ROLE Viewer;

-- 2. Grant privileges to roles
-- Admin has full access
GRANT ALL PRIVILEGES ON BookStore.* TO Bookstore_Admin;

-- Inventory manager can manage books, authors, and publishers
GRANT SELECT, INSERT, UPDATE, DELETE ON BookStore.Book TO Inventory_Manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookStore.Author TO Inventory_Manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookStore.Publisher TO Inventory_Manager;

-- Sales rep can manage orders and customers
GRANT SELECT, INSERT, UPDATE ON BookStore.Cust_Order TO Sales_Rep;
GRANT SELECT, INSERT, UPDATE ON BookStore.Order_line TO Sales_Rep;
GRANT SELECT ON BookStore.Book TO Sales_Rep;
GRANT SELECT, INSERT, UPDATE ON BookStore.Customer TO Sales_Rep;

-- Viewer has read-only access
GRANT SELECT ON BookStore.* TO Viewer;

-- 3. Create users and assign roles
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'adminpass';
CREATE USER 'inventory_user'@'localhost' IDENTIFIED BY 'inventorypass';
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'salespass';
CREATE USER 'viewer_user'@'localhost' IDENTIFIED BY 'viewerpass';

-- 4. Grant roles to users
GRANT Bookstore_Admin TO 'admin_user'@'localhost';
GRANT Inventory_Manager TO 'inventory_user'@'localhost';
GRANT Sales_Rep TO 'sales_user'@'localhost';
GRANT Viewer TO 'viewer_user'@'localhost';

-- 5. Set default roles for each user
SET DEFAULT ROLE Bookstore_Admin TO 'admin_user'@'localhost';
SET DEFAULT ROLE Inventory_Manager TO 'inventory_user'@'localhost';
SET DEFAULT ROLE Sales_Rep TO 'sales_user'@'localhost';
SET DEFAULT ROLE Viewer TO 'viewer_user'@'localhost';

-- 6. (Optional) Apply role changes immediately
FLUSH PRIVILEGES;






-- making of the foreign key for this dataset 
-- the columns already exist so this is just an altering to identify them as foreignkeys

ALTER TABLE Book
ADD CONSTRAINT fk_Book_Language_ID FOREIGN KEY (Language_ID) 
REFERENCES Book_language(Language_ID)
ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT fk_Book_Publisher_ID FOREIGN KEY (Publisher_ID) 
REFERENCES Publisher(Publisher_ID)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Book_Author
ADD CONSTRAINT fk_B_BookID FOREIGN KEY (BookID) 
REFERENCES Book(BookID)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_B_Author_ID FOREIGN KEY (Author_ID) 
REFERENCES Author(Author_ID)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Publisher
ADD CONSTRAINT fk_Publisher_Address_ID FOREIGN KEY (Address_id) 
REFERENCES Address(Address_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Address
ADD CONSTRAINT fk_Address_Country_ID FOREIGN KEY (Country_id) 
REFERENCES Country(Country_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- Handle circular reference between Customer and Customer_Address
-- First add the column
ALTER TABLE Customer
ADD COLUMN Customer_Address_id INT;

-- Then add the constraint
ALTER TABLE Customer
ADD CONSTRAINT fk_Customer_AddressID FOREIGN KEY (Customer_Address_id) 
REFERENCES Customer_Address(Customer_Address_id)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE Customer_Address
ADD CONSTRAINT fk_C_Customer_ID FOREIGN KEY (Customer_id) 
REFERENCES Customer(Customer_id)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_C_Address_Status_ID FOREIGN KEY (Address_Status_ID) 
REFERENCES Address_Status(Address_Status_ID)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Cust_Order
ADD CONSTRAINT fk_O_Customer_ID FOREIGN KEY (Customer_id) 
REFERENCES Customer(Customer_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT fk_O_Customer_Address_ID FOREIGN KEY (Customer_Address_id) 
REFERENCES Customer_Address(Customer_Address_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT fk_O_Shipping_Method_ID FOREIGN KEY (Shipping_method_id) 
REFERENCES Shipping_method(Shipping_method_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT fk_O_Order_Status_ID FOREIGN KEY (Order_status_id) 
REFERENCES Order_status(Order_status_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Order_line
ADD CONSTRAINT fk_L_Order_ID FOREIGN KEY (Order_id) 
REFERENCES Cust_Order(Order_id)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_L_BookID FOREIGN KEY (BookID) 
REFERENCES Book(BookID)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Order_history
ADD CONSTRAINT fk_H_Order_ID FOREIGN KEY (Order_id) 
REFERENCES Cust_Order(Order_id)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT fk_H_Order_Status_ID FOREIGN KEY (Order_status_id) 
REFERENCES Order_status(Order_status_id)
ON DELETE RESTRICT ON UPDATE CASCADE;
