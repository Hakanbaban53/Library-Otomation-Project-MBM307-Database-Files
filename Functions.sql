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
    FROM Fines f
    INNER JOIN Loans l ON f.LoanID = l.LoanID
    WHERE l.MemberID = @MemberID AND f.PaidStatus = 0;
    SELECT @TotalFines = SUM(DATEDIFF(DAY, l.DueDate, l.ReturnDate) * 1.00)
    FROM Loans l
    WHERE l.MemberID = @MemberID AND l.ReturnDate IS NOT NULL;
    RETURN ISNULL(@TotalFines, 0);
END;


