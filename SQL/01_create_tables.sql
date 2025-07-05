-- Step 1: Create the database
CREATE DATABASE AirportTicketingSystem;
GO

-- Use the newly created database
USE AirportTicketingSystem;
GO

-- Step 1.1: Create Employees table
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor')) NOT NULL
);

-- Step 1.2: Create Passengers table
CREATE TABLE Passengers (
    PassengerID INT IDENTITY(1,1) PRIMARY KEY,
    PNR NVARCHAR(20) UNIQUE NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    DoB DATE NOT NULL,
    MealPreference NVARCHAR(20) CHECK (MealPreference IN ('Vegetarian', 'Non-Vegetarian')),
    EmergencyContact NVARCHAR(15) NULL
);

-- Step 1.3: Create Flights table
CREATE TABLE Flights (
    FlightID INT IDENTITY(1,1) PRIMARY KEY,
    FlightNumber NVARCHAR(10) UNIQUE NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Origin NVARCHAR(100) NOT NULL,
    Destination NVARCHAR(100) NOT NULL,
    Capacity INT CHECK (Capacity > 0) NOT NULL
);

-- Step 1.4: Create Reservations table
CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    PNR NVARCHAR(20) NOT NULL,
    FlightID INT NOT NULL,
    BookingStatus NVARCHAR(20) CHECK (BookingStatus IN ('Confirmed', 'Pending', 'Cancelled')) NOT NULL,
    ReservationDate DATE NOT NULL, -- Will add constraint later
    FOREIGN KEY (PNR) REFERENCES Passengers(PNR),
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID)
);

-- Step 1.5: Create Tickets table
CREATE TABLE Tickets (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    ReservationID INT NOT NULL,
    IssueDate DATE DEFAULT GETDATE(),
    IssueTime TIME DEFAULT GETDATE(),
    Fare DECIMAL(10,2) NOT NULL,
    SeatNumber NVARCHAR(5) NULL,
    Class NVARCHAR(20) CHECK (Class IN ('Business', 'FirstClass', 'Economy')) NOT NULL,
    EBoardingNumber NVARCHAR(20) UNIQUE NOT NULL,
    EmployeeID INT NOT NULL,
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Step 1.6: Create Baggage table
CREATE TABLE Baggage (
    BaggageID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT NOT NULL,
    Weight DECIMAL(5,2) CHECK (Weight >= 0) NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('CheckedIn', 'Loaded')) NOT NULL,
    AdditionalFee DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
);