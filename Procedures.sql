CREATE PROCEDURE AddNewBook
    @Title NVARCHAR(255),
    @Author NVARCHAR(255),
    @ISBN NVARCHAR(13),
    @PublishedYear INT,
    @Publisher NVARCHAR(255),
    @CategoryID INT
AS
BEGIN
    INSERT INTO Books (Title, Author, ISBN, PublishedYear, Publisher, CategoryID)
    VALUES (@Title, @Author, @ISBN, @PublishedYear, @Publisher, @CategoryID);
END;


CREATE PROCEDURE RegisterNewMember
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @DateOfBirth DATE,
    @Address NVARCHAR(255),
    @Phone NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    INSERT INTO Members (FirstName, LastName, DateOfBirth, Address, Phone, Email)
    VALUES (@FirstName, @LastName, @DateOfBirth, @Address, @Phone, @Email);
END;


CREATE PROCEDURE LoanBook
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @DueDate DATE
AS
BEGIN
    -- Check if the book is already on loan
    IF NOT EXISTS (SELECT 1 FROM Loans WHERE BookID = @BookID AND ReturnDate IS NULL)
    BEGIN
        INSERT INTO Loans (BookID, MemberID, LoanDate, DueDate)
        VALUES (@BookID, @MemberID, @LoanDate, @DueDate);
    END
    ELSE
    BEGIN
        PRINT 'The book is currently on loan and cannot be lent again until returned.';
    END
END;


CREATE PROCEDURE ReturnBook
    @LoanID INT,
    @ReturnDate DATE
AS
BEGIN
    DECLARE @DueDate DATE;
    DECLARE @FineAmount DECIMAL(10, 2) = 0.00;
    
    -- Get the due date for the loan
    SELECT @DueDate = DueDate FROM Loans WHERE LoanID = @LoanID;
    
    -- Check if the book is overdue
    IF @ReturnDate > @DueDate
    BEGIN
        -- Calculate fine (example: $1 per day overdue)
        SET @FineAmount = DATEDIFF(DAY, @DueDate, @ReturnDate) * 1.00;
        
        -- Insert fine record
        INSERT INTO Fine (LoanID, Amount, PaidStatus)
        VALUES (@LoanID, @FineAmount, 0);
    END

    -- Update the loan record with the return date
    UPDATE Loans
    SET ReturnDate = @ReturnDate
    WHERE LoanID = @LoanID;
END;

CREATE PROCEDURE ListOverdueBooks
AS
BEGIN
    SELECT l.LoanID, b.Title, m.FirstName, m.LastName, l.DueDate, DATEDIFF(DAY, l.DueDate, GETDATE()) AS DaysOverdue
    FROM Loans l
    INNER JOIN Books b ON l.BookID = b.BookID
    INNER JOIN Members m ON l.MemberID = m.MemberID
    WHERE l.ReturnDate IS NULL AND l.DueDate < GETDATE();
END;


EXEC AddNewBook @Title = 'Sample Book', @Author = 'Author Name', @ISBN = '1234567890123', @PublishedYear = 2022, @Publisher = 'Publisher Name', @CategoryID = 1;


CREATE PROCEDURE AuthenticateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SELECT UserID, Role
    FROM Users
    WHERE Username = @Username AND PasswordHash = HASHBYTES('SHA2_256', @Password);
END;


CREATE PROCEDURE AddNewUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @Role NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        RAISERROR('Username already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Role)
    VALUES (@Username, HASHBYTES('SHA2_256', @Password), @Role);
END;

