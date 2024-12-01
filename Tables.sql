CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(255) NOT NULL,
    Author NVARCHAR(255),
    ISBN NVARCHAR(13) UNIQUE,
    PublishedYear INT CHECK (PublishedYear > 0),
    Publisher NVARCHAR(255),
    CategoryID INT FOREIGN KEY REFERENCES BookCategory(CategoryID)
);


CREATE TABLE Members (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Address NVARCHAR(255),
    Phone NVARCHAR(15),
    Email NVARCHAR(100) UNIQUE
);


CREATE TABLE Loans (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    BookID INT NOT NULL FOREIGN KEY REFERENCES Books(BookID),
    MemberID INT NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL
);


CREATE TABLE BookCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO BookCategory (CategoryName) VALUES ('Science Fiction'), ('Fantasy'), ('Mystery'), ('Non-Fiction'), ('Biography');


CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL, 
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(15),
    Status NVARCHAR(50) CHECK (Status IN ('Active', 'Inactive')) NOT NULL DEFAULT 'Active';
    Role NVARCHAR(50) CHECK (Role IN ('Admin', 'Librarian')) NOT NULL
);



CREATE TABLE Fine (
    FineID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT NOT NULL FOREIGN KEY REFERENCES Loans(LoanID),
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    PaidStatus BIT NOT NULL DEFAULT 0
);

CREATE TABLE Logs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    Description NVARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);


	CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    Action NVARCHAR(50),
    Description NVARCHAR(255),
    ActionDate DATETIME DEFAULT GETDATE()
);