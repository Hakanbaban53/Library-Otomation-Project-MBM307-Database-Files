CREATE TRIGGER trg_AfterLoanInsert
ON Loans
AFTER INSERT
AS
BEGIN
    DECLARE @BookID INT;

    SELECT @BookID = BookID FROM inserted;

    -- Update book availability or log the loan action if necessary
    IF EXISTS (SELECT 1 FROM Loans WHERE BookID = @BookID AND ReturnDate IS NULL)
    BEGIN
        PRINT 'The book is currently on loan.';
        -- Additional actions can be added here, such as logging or updating status
    END
END;


CREATE TRIGGER trg_AfterMemberInsert
ON Members
AFTER INSERT
AS
BEGIN
    DECLARE @MemberID INT;
    SELECT @MemberID = MemberID FROM inserted;

    -- For demonstration, we'll log this action in a hypothetical Log table (create this if needed)
    INSERT INTO Logs (Description, LogDate)
    VALUES ('New member registered with ID ' + CAST(@MemberID AS NVARCHAR), GETDATE());
END;


CREATE TABLE Logs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    Description NVARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_AfterFineUpdate
ON Fine
AFTER UPDATE
AS
BEGIN
    DECLARE @FineID INT, @PaidStatus BIT;

    SELECT @FineID = FineID, @PaidStatus = PaidStatus FROM inserted;

    IF @PaidStatus = 1
    BEGIN
        -- Log payment or take other actions
        PRINT 'Fine with ID ' + CAST(@FineID AS NVARCHAR) + ' has been marked as paid.';
    END
END;



