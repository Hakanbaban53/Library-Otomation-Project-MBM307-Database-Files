CREATE VIEW ViewAvailableBooks AS
SELECT 
    b.BookID, 
    b.Title, 
    b.Author, 
    b.ISBN, 
    c.CategoryName
FROM 
    Books b
JOIN 
    BookCategory c ON b.CategoryID = c.CategoryID
WHERE 
    b.BookID NOT IN (SELECT BookID FROM Loans WHERE ReturnDate IS NULL);


CREATE VIEW ViewOverdueLoans AS
SELECT 
    l.LoanID,
    b.Title AS BookTitle,
    m.FirstName + ' ' + m.LastName AS MemberName,
    l.LoanDate,
    l.DueDate,
    DATEDIFF(DAY, l.DueDate, GETDATE()) AS DaysOverdue
FROM 
    Loans l
JOIN 
    Books b ON l.BookID = b.BookID
JOIN 
    Members m ON l.MemberID = m.MemberID
WHERE 
    l.ReturnDate IS NULL AND l.DueDate < GETDATE();


CREATE VIEW ViewActiveLoans AS
SELECT 
    m.MemberID,
    m.FirstName,
    m.LastName,
    l.LoanID,
    b.Title AS BookTitle,
    l.LoanDate,
    l.DueDate
FROM 
    Members m
JOIN 
    Loans l ON m.MemberID = l.MemberID
JOIN 
    Books b ON l.BookID = b.BookID
WHERE 
    l.ReturnDate IS NULL;


