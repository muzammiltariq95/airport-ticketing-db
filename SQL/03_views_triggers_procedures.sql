-- Use the newly created database
USE AirportTicketingSystem;
GO

-- Step 2: Add check constraint to ensure ReservationDate is not in the past
ALTER TABLE Reservations
ADD CONSTRAINT chk_ReservationDate CHECK (ReservationDate >= CAST(GETDATE() AS DATE));

SELECT 
    t.name AS TableName,
    c.name AS ConstraintName,
    c.type_desc AS ConstraintType
FROM sys.tables t
JOIN sys.check_constraints c ON t.object_id = c.parent_object_id
WHERE t.name = 'Reservations';

-- Step 3: Create a view to display passenger information, flight details, and reservation status
CREATE VIEW PassengerFlightDetails AS
SELECT 
    p.PNR,
    p.FirstName AS PassengerFirstName,
    p.LastName AS PassengerLastName,
    p.Email AS PassengerEmail,
    p.MealPreference,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    f.DepartureTime,
    f.ArrivalTime,
    r.BookingStatus,
    r.ReservationDate
FROM Reservations r
JOIN Passengers p ON r.PNR = p.PNR
JOIN Flights f ON r.FlightID = f.FlightID;

SELECT * FROM PassengerFlightDetails;

-- Step 4: Create a stored procedure to retrieve all bookings for a given passenger (PNR)
CREATE PROCEDURE GetPassengerBookings
    @PNR NVARCHAR(20)
AS
BEGIN
    SELECT 
        r.ReservationID,
        p.PNR,
        p.FirstName AS PassengerFirstName,
        p.LastName AS PassengerLastName,
        f.FlightNumber,
        f.Origin,
        f.Destination,
        f.DepartureTime,
        f.ArrivalTime,
        r.BookingStatus,
        r.ReservationDate
    FROM Reservations r
    JOIN Passengers p ON r.PNR = p.PNR
    JOIN Flights f ON r.FlightID = f.FlightID
    WHERE p.PNR = @PNR;
END;

-- Test the stored procedure
EXEC GetPassengerBookings 'PNR001';

-- Question5
-- Step 5: Trigger to Prevent Overbooking
CREATE TRIGGER PreventOverbooking
ON Tickets
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Rollback if inserting new tickets exceeds flight capacity
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Reservations r ON i.ReservationID = r.ReservationID
        JOIN Flights f ON r.FlightID = f.FlightID
        WHERE (
            -- Total tickets for the flight including new ones
            (SELECT COUNT(*) FROM Tickets t
             JOIN Reservations r2 ON t.ReservationID = r2.ReservationID
             WHERE r2.FlightID = f.FlightID) 
             
            + (SELECT COUNT(*) FROM inserted i2
               JOIN Reservations r3 ON i2.ReservationID = r3.ReservationID
               WHERE r3.FlightID = f.FlightID)
        
        ) > f.Capacity -- Compare against flight capacity
    )
    BEGIN
        RAISERROR ('This flight is already fully booked. No more tickets can be issued.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

-- Step 6: Create a function to calculate total fare with additional charges
CREATE FUNCTION CalculateTotalFare (@TicketID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @BaseFare DECIMAL(10,2);
    DECLARE @ExtraBaggageCharge DECIMAL(10,2);
    DECLARE @MealCharge DECIMAL(10,2);
    DECLARE @SeatCharge DECIMAL(10,2);
    DECLARE @TotalFare DECIMAL(10,2);

    -- Get base fare from Tickets table
    SELECT @BaseFare = Fare FROM Tickets WHERE TicketID = @TicketID;

    -- Calculate extra baggage charge (100 GBP per kg)
    SELECT @ExtraBaggageCharge = COALESCE(SUM(Weight * 100), 0)
    FROM Baggage WHERE TicketID = @TicketID;

    -- Check if the passenger has an upgraded meal (20 GBP charge)
    SELECT @MealCharge = 
        CASE 
            WHEN p.MealPreference IS NOT NULL THEN 20 
            ELSE 0 
        END
    FROM Passengers p
    JOIN Reservations r ON p.PNR = r.PNR
    JOIN Tickets t ON r.ReservationID = t.ReservationID
    WHERE t.TicketID = @TicketID;

    -- Charge 30 GBP if a seat number is assigned (preferred seat)
    SELECT @SeatCharge = 
        CASE 
            WHEN SeatNumber IS NOT NULL THEN 30 
            ELSE 0 
        END
    FROM Tickets WHERE TicketID = @TicketID;

    -- Calculate total fare
    SET @TotalFare = @BaseFare + @ExtraBaggageCharge + @MealCharge + @SeatCharge;

    RETURN @TotalFare;
END;

-- Step 7: Create a Stored Procedure to Issue a Ticket and Add Baggage in a Single Transaction
CREATE PROCEDURE IssueTicketWithBaggage
    @ReservationID INT,
    @Fare DECIMAL(10,2),
    @SeatNumber NVARCHAR(5),
    @Class NVARCHAR(20),
    @EBoardingNumber NVARCHAR(20),
    @EmployeeID INT,
    @BaggageWeight DECIMAL(5,2),
    @BaggageStatus NVARCHAR(20)
AS
BEGIN
    DECLARE @TicketID INT;
    DECLARE @AdditionalFee DECIMAL(10,2);

    -- Calculate baggage fee (100 GBP per kg)
    SET @AdditionalFee = @BaggageWeight * 100;

    -- Start transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insert ticket
        INSERT INTO Tickets (ReservationID, Fare, SeatNumber, Class, EBoardingNumber, EmployeeID)
        VALUES (@ReservationID, @Fare, @SeatNumber, @Class, @EBoardingNumber, @EmployeeID);

        -- Get the last inserted TicketID
        SET @TicketID = SCOPE_IDENTITY();

        -- Insert baggage record
        INSERT INTO Baggage (TicketID, Weight, Status, AdditionalFee)
        VALUES (@TicketID, @BaggageWeight, @BaggageStatus, @AdditionalFee);

        -- If both inserts are successful, commit the transaction
        COMMIT TRANSACTION;

        PRINT 'Ticket issued and baggage added successfully.';
    END TRY
    BEGIN CATCH
        -- If an error occurs, rollback the transaction
        ROLLBACK TRANSACTION;

        PRINT 'Transaction failed. Rolling back changes.';
        THROW;
    END CATCH;
END;

-- Making a trigger for cancellations.
-- Create a table to log cancellations
CREATE TABLE TicketCancellations (
    CancellationID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT,
    ReservationID INT,
    CancelledAt DATETIME DEFAULT GETDATE()
);
-- Trigger to log deletions
CREATE TRIGGER LogTicketCancellations
ON Tickets
AFTER DELETE
AS
BEGIN
    INSERT INTO TicketCancellations (TicketID, ReservationID)
    SELECT d.TicketID, d.ReservationID
    FROM deleted d;
END;
-- Insert a test ticket
INSERT INTO Tickets (ReservationID, Fare, SeatNumber, Class, EBoardingNumber, EmployeeID)
VALUES (1, 100.00, '9C', 'Economy', 'TEST_EBN999', 1);
-- Find the TicketID just inserted
SELECT TOP 1 TicketID FROM Tickets ORDER BY TicketID DESC;
-- Delete it
DELETE FROM Tickets WHERE EBoardingNumber = 'TEST_EBN999';
-- Check the log table
SELECT * FROM TicketCancellations;

-- User Defined Function for gathering passenger age
CREATE FUNCTION GetPassengerAge (@DoB DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DoB, GETDATE()) -
           CASE WHEN MONTH(@DoB) > MONTH(GETDATE()) 
                     OR (MONTH(@DoB) = MONTH(GETDATE()) AND DAY(@DoB) > DAY(GETDATE())) 
                THEN 1 ELSE 0 END;
END;
-- Example usage of the function for a sample date
SELECT dbo.GetPassengerAge('1995-06-10') AS PassengerAge;

-- Stored procedure
CREATE PROCEDURE GetEmployeeTicketStats
AS
BEGIN
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        COUNT(t.TicketID) AS TicketsIssued
    FROM Employees e
    LEFT JOIN Tickets t ON e.EmployeeID = t.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName;
END;
-- Execute the procedure
EXEC GetEmployeeTicketStats;

-- Upcoming flights with passengers view
CREATE VIEW UpcomingFlightsWithPassengers AS
SELECT 
    f.FlightNumber,
    f.Origin,
    f.Destination,
    f.DepartureTime,
    p.FirstName,
    p.LastName,
    r.BookingStatus
FROM Flights f
JOIN Reservations r ON f.FlightID = r.FlightID
JOIN Passengers p ON r.PNR = p.PNR
WHERE r.BookingStatus = 'Confirmed'
  AND f.DepartureTime >= GETDATE();
