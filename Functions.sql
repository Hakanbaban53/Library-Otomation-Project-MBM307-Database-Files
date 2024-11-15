CREATE FUNCTION CalculateOverdueFine
(
    @DueDate DATE,
    @ReturnDate DATE
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @FineAmount DECIMAL(10, 2) = 0.00;
    IF @ReturnDate > @DueDate
    BEGIN
        -- Assume fine is $1 per day overdue
        SET @FineAmount = DATEDIFF(DAY, @DueDate, @ReturnDate) * 1.00;
    END
    RETURN @FineAmount;
END;


CREATE FUNCTION IsBookAvailable
(
    @BookID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Available BIT = 1;
    IF EXISTS (SELECT 1 FROM Loans WHERE BookID = @BookID AND ReturnDate IS NULL)
    BEGIN
        SET @Available = 0;
    END
    RETURN @Available;
END;


CREATE FUNCTION GetTotalFinesForMember
(
    @MemberID INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalFines DECIMAL(10, 2);
    SELECT @TotalFines = SUM(Amount)
    FROM Fine f
    INNER JOIN Loans l ON f.LoanID = l.LoanID
    WHERE l.MemberID = @MemberID AND f.PaidStatus = 0;
    RETURN ISNULL(@TotalFines, 0);
END;


