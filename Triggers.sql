CREATE TRIGGER trg_AfterLoanInsert
ON Loans
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BookID INT;

    SELECT @BookID = BookID FROM inserted;

    -- Check if the book is available
    IF NOT EXISTS (SELECT 1 FROM Loans WHERE BookID = @BookID AND ReturnDate IS NULL)
    BEGIN
        -- Insert the loan record if the book is available
        INSERT INTO Loans (BookID, MemberID, LoanDate, DueDate)
        SELECT BookID, MemberID, LoanDate, DueDate FROM inserted;

        -- Log the loan action
        INSERT INTO AuditLogs (Action, Description, ActionDate)
        VALUES ('Loan', 'Book with ID ' + CAST(@BookID AS NVARCHAR) + ' has been loaned.', GETDATE());
    END
    ELSE
    BEGIN
        PRINT 'The book is currently on loan.';
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
    INSERT INTO AuditLog (Action, Description, ActionDate)
    VALUES ('Member', 'Member with ID ' + CAST(@MemberID AS NVARCHAR) + ' has been added.', GETDATE());
END;

CREATE TRIGGER trg_AfterMemberDelete
ON Members
AFTER DELETE
AS
BEGIN
    DECLARE @MemberID INT;
    SELECT @MemberID = MemberID FROM deleted;

    -- For demonstration, we'll log this action in a hypothetical Log table (create this if needed)
    INSERT INTO AuditLog (Action, Description, ActionDate)
    VALUES ('Member', 'Member with ID ' + CAST(@MemberID AS NVARCHAR) + ' has been deleted.', GETDATE());
END;

CREATE TRIGGER trg_AfterFineInsert
ON Fines
AFTER INSERT
AS
BEGIN
    DECLARE @FineID INT, @MemberID INT, @LoanID INT, @Amount DECIMAL(10, 2);

    -- Loop through all inserted rows
    DECLARE fine_cursor CURSOR FOR
    SELECT FineID, LoanID, Amount
    FROM inserted;

    OPEN fine_cursor;
    FETCH NEXT FROM fine_cursor INTO @FineID, @LoanID, @Amount;

    -- Loop through all inserted fines
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get the MemberID from the Loans table using the LoanID
        SELECT @MemberID = MemberID FROM Loans WHERE LoanID = @LoanID;

        -- Log the fine insertion into the AuditLog table
        INSERT INTO AuditLog (Action, Description, ActionDate)
        VALUES ('Fine', 
                'Fine with ID ' + CAST(@FineID AS NVARCHAR) + ' has been issued to Member ' + 
                CAST(@MemberID AS NVARCHAR) + ' for Loan ' + CAST(@LoanID AS NVARCHAR) + 
                ' with amount ' + CAST(@Amount AS NVARCHAR),
                GETDATE());

        FETCH NEXT FROM fine_cursor INTO @FineID, @LoanID, @Amount;
    END

    CLOSE fine_cursor;
    DEALLOCATE fine_cursor;
END;

CREATE TRIGGER trg_AfterFineUpdate
ON Fines
AFTER UPDATE
AS
BEGIN
    DECLARE @FineID INT, @PaidStatus BIT;

    SELECT @FineID = FineID, @PaidStatus = PaidStatus FROM inserted;

    IF @PaidStatus = 1
    BEGIN
        -- Log payment or take other actions
        INSERT INTO AuditLog (Action, Description, ActionDate)
        VALUES ('Fine', 'Fine with ID ' + CAST(@FineID AS NVARCHAR) + ' has been paid.', GETDATE());
    END
END;



