-- Use the newly created database
USE AirportTicketingSystem;
GO

-- Step 1.7: Insert Sample Data (At least 7 records per table)
INSERT INTO Employees (FirstName, LastName, Email, Username, PasswordHash, Role)
VALUES 
('John', 'Doe', 'john.doe@email.com', 'johndoe', 'hashed_password', 'Ticketing Staff'),
('Jane', 'Smith', 'jane.smith@email.com', 'janesmith', 'hashed_password', 'Ticketing Supervisor'),
('Emily', 'Johnson', 'emily.j@email.com', 'emjohnson', 'hashed_pw1', 'Ticketing Staff'),
('Michael', 'Williams', 'michael.w@email.com', 'mwilliams', 'hashed_pw2', 'Ticketing Staff'),
('Olivia', 'Taylor', 'olivia.t@email.com', 'otaylor', 'hashed_pw3', 'Ticketing Staff'),
('David', 'Lee', 'david.l@email.com', 'dlee', 'hashed_pw4', 'Ticketing Staff'),
('Sophia', 'Martinez', 'sophia.m@email.com', 'smartinez', 'hashed_pw5', 'Ticketing Supervisor');

INSERT INTO Passengers (PNR, FirstName, LastName, Email, DoB, MealPreference, EmergencyContact)
VALUES 
('PNR001', 'Alice', 'Brown', 'alice.brown@email.com', '1990-05-15', 'Vegetarian', '1234567890'),
('PNR002', 'Bob', 'Green', 'bob.green@email.com', '1985-07-20', 'Non-Vegetarian', NULL),
('PNR003', 'Charlie', 'Davis', 'charlie.davis@email.com', '1992-09-25', 'Vegetarian', '1234567891'),
('PNR004', 'Diana', 'Hill', 'diana.hill@email.com', '1988-11-05', 'Vegetarian', '1234567892'),
('PNR005', 'Ethan', 'Clark', 'ethan.clark@email.com', '1995-03-10', 'Non-Vegetarian', NULL),
('PNR006', 'Fiona', 'White', 'fiona.white@email.com', '1991-12-17', 'Vegetarian', '1234567893'),
('PNR007', 'George', 'King', 'george.king@email.com', '1983-09-09', 'Vegetarian', '1234567894');

INSERT INTO Flights (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination, Capacity)
VALUES 
('FL001', '2025-06-01 08:00', '2025-06-01 12:00', 'London', 'New York', 150),
('FL002', '2025-06-02 10:00', '2025-06-02 14:00', 'Paris', 'Dubai', 200),
('FL003', '2025-06-03 09:30', '2025-06-03 13:45', 'Berlin', 'Rome', 180),
('FL004', '2025-06-04 15:00', '2025-06-04 19:30', 'Sydney', 'Singapore', 220),
('FL005', '2025-06-05 11:00', '2025-06-05 15:00', 'Toronto', 'Chicago', 160),
('FL006', '2025-06-06 13:00', '2025-06-06 17:00', 'Dubai', 'London', 250),
('FL007', '2025-06-07 07:00', '2025-06-07 10:00', 'Tokyo', 'Seoul', 190);

INSERT INTO Reservations (PNR, FlightID, BookingStatus, ReservationDate)
VALUES 
('PNR001', 1, 'Confirmed', '2025-05-20'),
('PNR002', 2, 'Pending', '2025-05-22'),
('PNR003', 3, 'Confirmed', '2025-05-23'),
('PNR004', 4, 'Pending', '2025-05-24'),
('PNR005', 5, 'Confirmed', '2025-05-25'),
('PNR006', 6, 'Pending', '2025-05-26'),
('PNR007', 7, 'Confirmed', '2025-05-27');

INSERT INTO Tickets (ReservationID, Fare, SeatNumber, Class, EBoardingNumber, EmployeeID)
VALUES 
(1, 500.00, '12A', 'Economy', 'EBN001', 1),
(2, 750.00, NULL, 'Business', 'EBN002', 2),
(6, 600.00, '14B', 'Economy', 'EBN003', 1),
(10, 900.00, NULL, 'Business', 'EBN004', 2),
(11, 450.00, '10C', 'Economy', 'EBN005', 1),
(12, 800.00, NULL, 'Business', 'EBN006', 2),
(13, 700.00, '11D', 'Economy', 'EBN007', 1);

INSERT INTO Baggage (TicketID, Weight, Status, AdditionalFee)
VALUES 
(34, 15.00, 'CheckedIn', 1500.00),
(35, 10.00, 'Loaded', 1000.00),
(36, 20.00, 'CheckedIn', 2000.00),
(37, 25.00, 'Loaded', 2500.00),
(38, 12.00, 'Loaded', 1200.00),
(39, 18.00, 'CheckedIn', 1800.00),
(40, 16.00, 'Loaded', 1600.00);

-- Checking the database and all the tables if the values are input properly
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT * FROM Employees;
SELECT * FROM Passengers;
SELECT * FROM Flights;
SELECT * FROM Reservations;
SELECT * FROM Tickets;
SELECT * FROM Baggage;
