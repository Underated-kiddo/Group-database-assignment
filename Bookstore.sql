-- creating the database 
CREATE DATABASE BookStore ;
-- the bellow use part will select the bookstore database created and allow us to use it now
USE BookStore ;

--  creation of tables that will hold the database up and running
CREATE TABLE Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255),
    Pages INT,
    Price DECIMAL(10,2),
    Quantity INT,
    Publication_year INT,
    Language_ID INT,
    Publisher_ID INT
);

CREATE TABLE Book_language (
    Language_ID INT PRIMARY KEY,
    Language_Name VARCHAR(100)
);

CREATE TABLE Publisher (
    Publisher_ID INT PRIMARY KEY,
    Publisher_name VARCHAR(255),
    Publisher_Age INT,
    Phone INT,
    Nationality VARCHAR(255),
    Address_id INT
);

CREATE TABLE Address (
    Address_id INT PRIMARY KEY,
    City VARCHAR(100),
    Street VARCHAR(100),
    Postal_code INT,
    Country_id INT
);

CREATE TABLE Country (
    Country_id INT PRIMARY KEY,
    Country_name VARCHAR(100)
);

CREATE TABLE Author (
    Author_ID INT PRIMARY KEY,
    Author_Name VARCHAR(255),
    Author_Age INT,
    Nationality VARCHAR(100)
);

CREATE TABLE Book_Author (
    BookID INT,
    Author_ID INT
);

CREATE TABLE Customer (
    Customer_id INT PRIMARY KEY,
    Customer_name VARCHAR(255),
    Customer_Age INT,
    Customer_Phone INT,
    Customer_Address_id INT
);

CREATE TABLE Customer_Address (
    Customer_Address_id INT PRIMARY KEY,
    Customer_id INT,
    Address_name VARCHAR(100),
    Address_Status_ID INT
);

CREATE TABLE Address_Status (
    Address_Status_ID INT PRIMARY KEY,
    Status_name VARCHAR(100)
);

CREATE TABLE Cust_Order (
    Order_id INT PRIMARY KEY,
    Customer_id INT,
    Order_date DATE,
    Customer_Address_id INT,
    Shipping_method_id INT,
    Order_status_id INT,
    Total_Amount DOUBLE
);

CREATE TABLE Shipping_method (
    Shipping_method_id INT PRIMARY KEY,
    Method_name VARCHAR(100),
    Estimated_Days INT,
    Cost DOUBLE
);

CREATE TABLE Order_status (
    Order_status_id INT PRIMARY KEY,
    Status_name VARCHAR(100)
);

CREATE TABLE Order_line (
    Order_line_id INT PRIMARY KEY,
    Order_id INT,
    BookID INT
);

CREATE TABLE Order_history (
    Order_history_id INT PRIMARY KEY,
    Order_id INT,
    Order_status_id INT,
    Order_date DATE
);

-- making of the foreign key for this dataset 
-- the columns already exist so this is just an altering to identify them as foreignkeys
ALTER TABLE Book
ADD CONSTRAINT fk_Book_Language_ID FOREIGN KEY (Language_ID) REFERENCES Book_language(Language_ID),
ADD CONSTRAINT fk_Book_Publisher_ID FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID);

ALTER TABLE Book_Author
ADD CONSTRAINT fk_B_BookID FOREIGN KEY (BookID) REFERENCES Book(BookID),
ADD CONSTRAINT fk_B_Author_ID FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID);

ALTER TABLE Publisher
ADD CONSTRAINT fk_Publisher_Address_ID FOREIGN KEY (Address_id) REFERENCES Address(Address_id);

ALTER TABLE Address
ADD CONSTRAINT fk_Address_Country_ID FOREIGN KEY (Country_id) REFERENCES Country(Country_id);

ALTER TABLE Customer
ADD CONSTRAINT fk_Customer_AddressID FOREIGN KEY (Customer_Address_id) REFERENCES Customer_Address(Customer_Address_id);

ALTER TABLE Customer_Address
ADD CONSTRAINT fk_C_Customer_ID FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
ADD CONSTRAINT fk_C_Address_Status_ID FOREIGN KEY (Address_Status_ID) REFERENCES Address_Status(Address_Status_ID);

ALTER TABLE Cust_Order
ADD CONSTRAINT fk_O_Customer_ID FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
ADD CONSTRAINT fk_O_Customer_Address_ID FOREIGN KEY (Customer_Address_id) REFERENCES Customer_Address(Customer_Address_id),
ADD CONSTRAINT fk_O_Shipping_Method_ID FOREIGN KEY (Shipping_method_id) REFERENCES Shipping_method(Shipping_method_id),
ADD CONSTRAINT fk_O_Order_Status_ID FOREIGN KEY (Order_status_id) REFERENCES Order_status(Order_status_id);

ALTER TABLE Order_line
ADD CONSTRAINT fk_L_Order_ID FOREIGN KEY (Order_id) REFERENCES Cust_Order(Order_id),
ADD CONSTRAINT fk_L_BookID FOREIGN KEY (BookID) REFERENCES Book(BookID);

ALTER TABLE Order_history
ADD CONSTRAINT fk_H_Order_ID FOREIGN KEY (Order_id) REFERENCES Cust_Order(Order_id),
ADD CONSTRAINT fk_H_Order_Status_ID FOREIGN KEY (Order_status_id) REFERENCES Order_status(Order_status_id);
