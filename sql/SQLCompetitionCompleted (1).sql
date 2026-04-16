/* 
   Name: Caden Raleigh
   Course: [course name]
   Assignment: SQL Comprehensive Routines 1–35
   Notes: Each numbered section below corresponds to 
          the assignment questions.
*/


CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

-- Drop tables to recreate cleanly
IF OBJECT_ID('dbo.PurchaseItem','U') IS NOT NULL DROP TABLE dbo.PurchaseItem;
IF OBJECT_ID('dbo.Purchase','U')     IS NOT NULL DROP TABLE dbo.Purchase;
IF OBJECT_ID('dbo.Product','U')      IS NOT NULL DROP TABLE dbo.Product;
IF OBJECT_ID('dbo.Category','U')     IS NOT NULL DROP TABLE dbo.Category;
IF OBJECT_ID('dbo.Customer','U')     IS NOT NULL DROP TABLE dbo.Customer;
GO

CREATE TABLE dbo.Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FName      VARCHAR(50) NOT NULL,
    LName      VARCHAR(50) NOT NULL,
    City       VARCHAR(50) NOT NULL,
    State      VARCHAR(50) NOT NULL
);

CREATE TABLE dbo.Category (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(80) NOT NULL UNIQUE,
    Description  VARCHAR(255) NULL
);

CREATE TABLE dbo.Product (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Category(CategoryID),
    Price       DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Purchase (
    PurchaseID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID   INT NOT NULL FOREIGN KEY REFERENCES dbo.Customer(CustomerID),
    PurchaseDate DATE NOT NULL DEFAULT GETDATE()
);

-- FIXED PurchaseItem table (no subquery)
CREATE TABLE dbo.PurchaseItem (
    PurchaseItemID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseID     INT NOT NULL FOREIGN KEY REFERENCES dbo.Purchase(PurchaseID),
    ProductID      INT NOT NULL FOREIGN KEY REFERENCES dbo.Product(ProductID),
    Quantity       INT NOT NULL CHECK (Quantity > 0),
    PriceAtSale    DECIMAL(10,2) NOT NULL,  -- add price column
    LineTotal AS (Quantity * PriceAtSale) PERSISTED
);
GO

INSERT INTO dbo.Customer (FName, LName, City, State) VALUES
('Judy','Denth','Big Rapids','MI'),
('Idris','Elba','Grand Rapids','MI'),
('Ava','Nguyen','Detroit','MI'),
('Liam','Patel','Big Rapids','MI'),
('Sophia','Reed','Lansing','MI');

INSERT INTO dbo.Category (CategoryName, Description) VALUES
('Electronics','Phones, computers, and gadgets'),
('Groceries','Everyday food and drinks'),
('Home Goods','Household items');

INSERT INTO dbo.Product (ProductName, CategoryID, Price) VALUES
('Bluetooth Speaker', 1, 49.99),
('Laptop Sleeve',     1, 19.99),
('Protein Bars',      2, 7.99),
('Coffee Beans',      2, 12.50),
('Desk Lamp',         3, 24.00),
('Throw Blanket',     3, 18.75);

INSERT INTO dbo.Purchase (CustomerID, PurchaseDate) VALUES
(1, '2025-11-01'),
(1, '2025-11-10'),
(2, '2025-11-05'),
(3, '2025-11-07'),
(4, '2025-11-08');

-- Get price from Product table
INSERT INTO dbo.PurchaseItem (PurchaseID, ProductID, Quantity, PriceAtSale)
SELECT 1, 1, 1, Price FROM dbo.Product WHERE ProductID = 1 UNION ALL
SELECT 1, 3, 2, Price FROM dbo.Product WHERE ProductID = 3 UNION ALL
SELECT 2, 2, 1, Price FROM dbo.Product WHERE ProductID = 2 UNION ALL
SELECT 2, 4, 1, Price FROM dbo.Product WHERE ProductID = 4 UNION ALL
SELECT 3, 5, 1, Price FROM dbo.Product WHERE ProductID = 5 UNION ALL
SELECT 3, 6, 1, Price FROM dbo.Product WHERE ProductID = 6 UNION ALL
SELECT 4, 3, 3, Price FROM dbo.Product WHERE ProductID = 3 UNION ALL
SELECT 5, 1, 1, Price FROM dbo.Product WHERE ProductID = 1;

SELECT
    City,
    COUNT(*) AS NumCustomers
FROM dbo.Customer
GROUP BY City;

SELECT
    c.CategoryName,
    p.ProductName,
    p.Price
FROM dbo.Category c
INNER JOIN dbo.Product p
    ON c.CategoryID = p.CategoryID
ORDER BY
    c.CategoryName,
    p.ProductName;

SELECT
    cu.City,
    ca.CategoryName,
    pr.ProductName
FROM dbo.Customer cu
INNER JOIN dbo.Purchase pu
    ON cu.CustomerID = pu.CustomerID
INNER JOIN dbo.PurchaseItem pi
    ON pu.PurchaseID = pi.PurchaseID
INNER JOIN dbo.Product pr
    ON pi.ProductID = pr.ProductID
INNER JOIN dbo.Category ca
    ON pr.CategoryID = ca.CategoryID
ORDER BY
    cu.City,
    ca.CategoryName,
    pr.ProductName;

SELECT 
    City,
    COUNT(*) AS NumCustomers
FROM dbo.Customer
GROUP BY City
ORDER BY City;

INSERT INTO dbo.Category (CategoryName, Description)
VALUES ('Health and Beauty Aids', 'Products related to personal care, health, and beauty');

SELECT * 
FROM dbo.Category
ORDER BY CategoryID;

SELECT * FROM dbo.Category
WHERE CategoryName = 'Health and Beauty Aids';

INSERT INTO dbo.Product (ProductName, CategoryID, Price)
VALUES
('Vitamin C Serum',       4, 14.99),
('Aloe Skin Moisturizer', 4, 9.49),
('Hair Repair Shampoo',   4, 12.25);

SELECT * FROM dbo.Customer
WHERE LName IN ('Denth', 'Elba');

INSERT INTO dbo.Purchase (CustomerID, PurchaseDate)
VALUES
(1, '2025-11-20'),  -- Judy
(2, '2025-11-20');  -- Idris

SELECT * FROM dbo.Purchase ORDER BY PurchaseID DESC;

SELECT 
    cu.FName,
    cu.LName,
    ca.CategoryName,
    pr.ProductName,
    pi.Quantity,
    pi.LineTotal,
    pu.PurchaseDate
FROM dbo.Customer cu
INNER JOIN dbo.Purchase pu ON cu.CustomerID = pu.CustomerID
INNER JOIN dbo.PurchaseItem pi ON pu.PurchaseID = pi.PurchaseID
INNER JOIN dbo.Product pr ON pi.ProductID = pr.ProductID
INNER JOIN dbo.Category ca ON pr.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Health and Beauty Aids'
ORDER BY cu.LName, cu.FName, pu.PurchaseDate;

-- Judy's Health & Beauty purchase (PurchaseID = 6)
INSERT INTO dbo.PurchaseItem (PurchaseID, ProductID, Quantity, PriceAtSale)
SELECT 6, ProductID, 1, Price
FROM dbo.Product
WHERE ProductName IN ('Vitamin C Serum', 'Aloe Skin Moisturizer');

-- Idris' Health & Beauty purchase (PurchaseID = 7)
INSERT INTO dbo.PurchaseItem (PurchaseID, ProductID, Quantity, PriceAtSale)
SELECT 7, ProductID, 1, Price
FROM dbo.Product
WHERE ProductName IN ('Vitamin C Serum', 'Aloe Skin Moisturizer', 'Hair Repair Shampoo');

SELECT 
    cu.FName,
    cu.LName,
    ca.CategoryName,
    pr.ProductName,
    pi.Quantity,
    pi.LineTotal,
    pu.PurchaseDate
FROM dbo.Customer cu
INNER JOIN dbo.Purchase pu ON cu.CustomerID = pu.CustomerID
INNER JOIN dbo.PurchaseItem pi ON pu.PurchaseID = pi.PurchaseID
INNER JOIN dbo.Product pr ON pi.ProductID = pr.ProductID
INNER JOIN dbo.Category ca ON pr.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Health and Beauty Aids'
ORDER BY cu.LName, cu.FName, pu.PurchaseDate;

SELECT
    cu.LName,
    cu.FName,
    ca.CategoryName,
    pu.PurchaseDate,
    pi.LineTotal
FROM dbo.Customer cu
INNER JOIN dbo.Purchase pu
    ON cu.CustomerID = pu.CustomerID
INNER JOIN dbo.PurchaseItem pi
    ON pu.PurchaseID = pi.PurchaseID
INNER JOIN dbo.Product pr
    ON pi.ProductID = pr.ProductID
INNER JOIN dbo.Category ca
    ON pr.CategoryID = ca.CategoryID
WHERE cu.CustomerID IN (
    SELECT cu2.CustomerID
    FROM dbo.Customer cu2
    INNER JOIN dbo.Purchase pu2 ON cu2.CustomerID = pu2.CustomerID
    INNER JOIN dbo.PurchaseItem pi2 ON pu2.PurchaseID = pi2.PurchaseID
    GROUP BY cu2.CustomerID
    HAVING COUNT(*) >= 4  -- at least 4 products purchased
)
ORDER BY cu.LName, cu.FName, pu.PurchaseDate;

SELECT
    c.CategoryName,
    COUNT(p.ProductID) AS NumProducts
FROM dbo.Category c
LEFT JOIN dbo.Product p
    ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY c.CategoryName;

SELECT 
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    s.status,
    s.login_time
FROM sys.dm_exec_sessions s
WHERE s.is_user_process = 1
ORDER BY s.login_time DESC;

SELECT 
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY login_time DESC;

KILL 52;

USE RetailDB;
GO

IF OBJECT_ID('dbo.CustomerAudit','U') IS NOT NULL
    DROP TABLE dbo.CustomerAudit;
GO

CREATE TABLE dbo.CustomerAudit (
    AuditID        INT IDENTITY(1,1) PRIMARY KEY,
    ActionType     VARCHAR(10) NOT NULL,      -- INSERT / UPDATE / DELETE
    CustomerID     INT NULL,
    OldFName       VARCHAR(50) NULL,
    OldLName       VARCHAR(50) NULL,
    OldCity        VARCHAR(50) NULL,
    OldState       VARCHAR(50) NULL,
    NewFName       VARCHAR(50) NULL,
    NewLName       VARCHAR(50) NULL,
    NewCity        VARCHAR(50) NULL,
    NewState       VARCHAR(50) NULL,
    ChangedBy      SYSNAME NOT NULL DEFAULT SUSER_SNAME(),
    HostName       SYSNAME NULL DEFAULT HOST_NAME(),
    AppName        SYSNAME NULL DEFAULT APP_NAME(),
    ChangedAt      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID('dbo.trg_Customer_Audit','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Customer_Audit;
GO

CREATE TRIGGER dbo.trg_Customer_Audit
ON dbo.Customer
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT only (rows in inserted but not deleted)
    INSERT INTO dbo.CustomerAudit (
        ActionType, CustomerID,
        NewFName, NewLName, NewCity, NewState
    )
    SELECT
        'INSERT',
        i.CustomerID,
        i.FName, i.LName, i.City, i.State
    FROM inserted i
    LEFT JOIN deleted d ON i.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;

    -- DELETE only (rows in deleted but not inserted)
    INSERT INTO dbo.CustomerAudit (
        ActionType, CustomerID,
        OldFName, OldLName, OldCity, OldState
    )
    SELECT
        'DELETE',
        d.CustomerID,
        d.FName, d.LName, d.City, d.State
    FROM deleted d
    LEFT JOIN inserted i ON d.CustomerID = i.CustomerID
    WHERE i.CustomerID IS NULL;

    -- UPDATE (rows in both inserted and deleted)
    INSERT INTO dbo.CustomerAudit (
        ActionType, CustomerID,
        OldFName, OldLName, OldCity, OldState,
        NewFName, NewLName, NewCity, NewState
    )
    SELECT
        'UPDATE',
        i.CustomerID,
        d.FName, d.LName, d.City, d.State,
        i.FName, i.LName, i.City, i.State
    FROM inserted i
    INNER JOIN deleted d ON i.CustomerID = d.CustomerID;
END;
GO

INSERT INTO dbo.Customer (FName, LName, City, State)
VALUES ('Maya','Lopez','Chicago','IL');

UPDATE dbo.Customer
SET City = 'Ann Arbor'
WHERE CustomerID = 1;  -- Judy

DELETE FROM dbo.Customer
WHERE CustomerID = 5;  -- Sophia

SELECT *
FROM dbo.CustomerAudit
ORDER BY AuditID;

-- Clean-up optional step
DELETE FROM dbo.PurchaseItem;
DELETE FROM dbo.Purchase;

IF OBJECT_ID('dbo.trg_Purchase_CascadeDelete','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Purchase_CascadeDelete;
GO

CREATE TRIGGER dbo.trg_Purchase_CascadeDelete
ON dbo.Purchase
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.PurchaseItem
    WHERE PurchaseID IN (SELECT PurchaseID FROM deleted);
END;
GO

SELECT * FROM dbo.Purchase;

SELECT * FROM dbo.PurchaseItem
WHERE PurchaseID = 6;   -- use your own ID

DELETE FROM dbo.Purchase
WHERE PurchaseID = 6;   -- use your own ID

SELECT * FROM dbo.PurchaseItem
WHERE PurchaseID = 6;

INSERT INTO dbo.Purchase (CustomerID, PurchaseDate)
VALUES (1, GETDATE());

SELECT TOP 1 PurchaseID, CustomerID, PurchaseDate
FROM dbo.Purchase
ORDER BY PurchaseID DESC;

USE RetailDB;
GO

---------------------------------------------------------
-- STEP 1: DROP OLD TRIGGER (to avoid conflicts)
---------------------------------------------------------
IF OBJECT_ID('dbo.trg_Purchase_CascadeDelete','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Purchase_CascadeDelete;
GO

---------------------------------------------------------
-- STEP 2: CREATE NEW INSTEAD OF DELETE CASCADE TRIGGER
---------------------------------------------------------
CREATE TRIGGER dbo.trg_Purchase_CascadeDelete
ON dbo.Purchase
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete child PurchaseItem rows FIRST
    DELETE pi
    FROM dbo.PurchaseItem pi
    INNER JOIN deleted d
        ON pi.PurchaseID = d.PurchaseID;

    -- Then delete parent Purchase rows
    DELETE p
    FROM dbo.Purchase p
    INNER JOIN deleted d
        ON p.PurchaseID = d.PurchaseID;
END;
GO

---------------------------------------------------------
-- STEP 3: INSERT A TEST PURCHASE
---------------------------------------------------------
INSERT INTO dbo.Purchase (CustomerID, PurchaseDate)
VALUES (1, GETDATE());   -- Judy

-- Capture the new PurchaseID
DECLARE @NewPurchaseID INT;
SET @NewPurchaseID = SCOPE_IDENTITY();

PRINT 'New PurchaseID = ' + CAST(@NewPurchaseID AS VARCHAR(10));

---------------------------------------------------------
-- STEP 4: INSERT CHILD PURCHASE ITEMS FOR TEST
---------------------------------------------------------
INSERT INTO dbo.PurchaseItem (PurchaseID, ProductID, Quantity, PriceAtSale)
SELECT @NewPurchaseID, ProductID, 1, Price
FROM dbo.Product
WHERE ProductName IN ('Bluetooth Speaker', 'Protein Bars');

---------------------------------------------------------
-- STEP 5: SHOW CHILD ROWS BEFORE DELETE
---------------------------------------------------------
PRINT 'Rows BEFORE delete:';
SELECT *
FROM dbo.PurchaseItem
WHERE PurchaseID = @NewPurchaseID;

---------------------------------------------------------
-- STEP 6: DELETE THE PARENT PURCHASE (TRIGGER SHOULD CASCADE)
---------------------------------------------------------
DELETE FROM dbo.Purchase
WHERE PurchaseID = @NewPurchaseID;

---------------------------------------------------------
-- STEP 7: SHOW CHILD ROWS AFTER DELETE (SHOULD BE ZERO)
---------------------------------------------------------
PRINT 'Rows AFTER delete:';
SELECT *
FROM dbo.PurchaseItem
WHERE PurchaseID = @NewPurchaseID;

BACKUP DATABASE RetailDB
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\RetailDB.bak'
WITH INIT, NAME = 'RetailDB Full Backup';

RESTORE DATABASE RetailDB_RestoreTest
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\RetailDB.bak'
WITH MOVE 'RetailDB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RetailDB_RestoreTest.mdf',
     MOVE 'RetailDB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RetailDB_RestoreTest_log.ldf',
     REPLACE;

SELECT name FROM sys.databases;

CREATE LOGIN RetailUser
WITH PASSWORD = 'StrongPassword123!';

USE RetailDB;
GO

CREATE USER RetailUser FOR LOGIN RetailUser;

EXEC sp_addrolemember 'db_datareader', 'RetailUser';

EXEC sp_addrolemember 'db_datawriter', 'RetailUser';

EXEC sp_addrolemember 'db_owner', 'RetailUser';

SELECT 
    dp.name AS UserName, 
    dp.type_desc AS UserType,
    rp.name AS RoleName
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm 
    ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals rp 
    ON drm.role_principal_id = rp.principal_id
WHERE dp.name = 'RetailUser';

USE RetailDB;
GO

IF OBJECT_ID('dbo.sp_CustomerSpendingLevel','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CustomerSpendingLevel;
GO

CREATE PROCEDURE dbo.sp_CustomerSpendingLevel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CustomerID,
        c.FName,
        c.LName,
        SUM(pi.LineTotal) AS TotalSpent,
        CASE
            WHEN SUM(pi.LineTotal) > 100 THEN 'High Spender'
            WHEN SUM(pi.LineTotal) > 50 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS SpendingLevel
    FROM dbo.Customer c
    LEFT JOIN dbo.Purchase p
        ON c.CustomerID = p.CustomerID
    LEFT JOIN dbo.PurchaseItem pi
        ON p.PurchaseID = pi.PurchaseID
    GROUP BY c.CustomerID, c.FName, c.LName
    ORDER BY TotalSpent DESC;
END;
GO

EXEC dbo.sp_CustomerSpendingLevel;

USE RetailDB;
GO

IF OBJECT_ID('dbo.sp_CheckCustomerActivity','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckCustomerActivity;
GO

CREATE PROCEDURE dbo.sp_CheckCustomerActivity
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PurchaseCount INT;

    SELECT @PurchaseCount = COUNT(*)
    FROM dbo.Purchase
    WHERE CustomerID = @CustomerID;

    IF @PurchaseCount = 0
    BEGIN
        SELECT 'Customer has made NO purchases.' AS ActivityStatus;
    END
    ELSE IF @PurchaseCount = 1
    BEGIN
        SELECT 'Customer has made ONE purchase.' AS ActivityStatus;
    END
    ELSE IF @PurchaseCount BETWEEN 2 AND 4
    BEGIN
        SELECT 'Customer is MODERATELY active with purchases.' AS ActivityStatus;
    END
    ELSE
    BEGIN
        SELECT 'Customer is VERY active with purchases!' AS ActivityStatus;
    END
END;
GO

EXEC dbo.sp_CheckCustomerActivity @CustomerID = 1;

EXEC dbo.sp_CheckCustomerActivity @CustomerID = 2;

EXEC dbo.sp_CheckCustomerActivity @CustomerID = 4;

USE RetailDB;
GO

SELECT 
    t.name AS TableName,
    SUM(p.rows) AS TotalRows
FROM sys.tables t
JOIN sys.partitions p 
    ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;

USE RetailDB;
GO

IF OBJECT_ID('dbo.sp_CategorySalesTemp','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CategorySalesTemp;
GO

CREATE PROCEDURE dbo.sp_CategorySalesTemp
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Create temp table
    CREATE TABLE #SalesSummary (
        CategoryName VARCHAR(80),
        TotalSales   DECIMAL(10,2),
        NumItemsSold INT
    );

    -- 2) Populate temp table
    INSERT INTO #SalesSummary (CategoryName, TotalSales, NumItemsSold)
    SELECT
        ca.CategoryName,
        COALESCE(SUM(pi.LineTotal), 0) AS TotalSales,
        COALESCE(SUM(pi.Quantity), 0)  AS NumItemsSold
    FROM dbo.Category ca
    LEFT JOIN dbo.Product pr
        ON ca.CategoryID = pr.CategoryID
    LEFT JOIN dbo.PurchaseItem pi
        ON pr.ProductID = pi.ProductID
    GROUP BY ca.CategoryName;

    -- 3) Return results from temp table
    SELECT *
    FROM #SalesSummary
    ORDER BY TotalSales DESC;
END;
GO

EXEC dbo.sp_CategorySalesTemp;

SELECT 
    a.CustomerID AS RetailDB_ID,
    a.FName AS RetailDB_FName,
    a.LName AS RetailDB_LName,
    b.CustomerID AS RestoreDB_ID,
    b.FName AS RestoreDB_FName,
    b.LName AS RestoreDB_LName
FROM RetailDB.dbo.Customer a
INNER JOIN RetailDB_RestoreTest.dbo.Customer b
    ON a.FName = b.FName
    AND a.LName = b.LName;

USE master;
GO

-- Drop if you already made one
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = 'LOCAL_SQLEXPRESS')
    EXEC sp_dropserver 'LOCAL_SQLEXPRESS', 'droplogins';
GO

-- Create linked server pointing to your own SQLEXPRESS instance
EXEC sp_addlinkedserver
    @server     = 'LOCAL_SQLEXPRESS',
    @srvproduct = '',
    @provider   = 'SQLNCLI',  -- if this errors, see note below
    @datasrc    = @@SERVERNAME;
GO

-- Allow your current login to use it
EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'LOCAL_SQLEXPRESS',
    @useself    = 'TRUE';
GO

SELECT TOP 5 *
FROM LOCAL_SQLEXPRESS.RetailDB.dbo.Customer;

SELECT
    a.CustomerID AS LocalID,
    a.FName,
    a.LName,
    b.CustomerID AS RemoteID
FROM RetailDB.dbo.Customer a
INNER JOIN LOCAL_SQLEXPRESS.RetailDB_RestoreTest.dbo.Customer b
    ON a.FName = b.FName
    AND a.LName = b.LName;

USE RetailDB;
GO

------------------------------------------------------------
-- 1) Drop + Create the People table
------------------------------------------------------------
IF OBJECT_ID('dbo.People23','U') IS NOT NULL
    DROP TABLE dbo.People23;
GO

CREATE TABLE dbo.People23 (
    PersonID   INT IDENTITY(1,1) PRIMARY KEY,
    FName      VARCHAR(50) NOT NULL,
    LName      VARCHAR(50) NOT NULL,
    Address    VARCHAR(120) NOT NULL,
    City       VARCHAR(60) NOT NULL,
    StateProv  VARCHAR(60) NOT NULL,
    Country    VARCHAR(60) NOT NULL
);
GO

------------------------------------------------------------
-- 2) First name pool (200 distinct first names)
------------------------------------------------------------
IF OBJECT_ID('tempdb..#FirstNames') IS NOT NULL DROP TABLE #FirstNames;
CREATE TABLE #FirstNames (FirstName VARCHAR(50) PRIMARY KEY);

INSERT INTO #FirstNames (FirstName) VALUES
('Ava'),('Liam'),('Noah'),('Emma'),('Olivia'),('Elijah'),('Mia'),('Lucas'),('Sophia'),('Mason'),
('Isabella'),('Ethan'),('Amelia'),('Logan'),('Harper'),('James'),('Evelyn'),('Benjamin'),('Abigail'),('Henry'),
('Emily'),('Alexander'),('Ella'),('Michael'),('Avery'),('Daniel'),('Scarlett'),('Jacob'),('Grace'),('William'),
('Chloe'),('Matthew'),('Victoria'),('Joseph'),('Riley'),('David'),('Aria'),('Samuel'),('Lily'),('Owen'),
('Zoey'),('John'),('Penelope'),('Wyatt'),('Layla'),('Jack'),('Nora'),('Luke'),('Hannah'),('Jayden'),
('Camila'),('Dylan'),('Addison'),('Grayson'),('Eleanor'),('Levi'),('Stella'),('Isaac'),('Natalie'),('Gabriel'),
('Zara'),('Carter'),('Savannah'),('Julian'),('Brooklyn'),('Sebastian'),('Bella'),('Anthony'),('Claire'),('Andrew'),
('Lucy'),('Thomas'),('Paisley'),('Christopher'),('Leah'),('Joshua'),('Audrey'),('Nathan'),('Skylar'),('Ryan'),
('Violet'),('Adrian'),('Allison'),('Charles'),('Anna'),('Hunter'),('Caroline'),('Eli'),('Genesis'),('Aaron'),
('Kennedy'),('Isaiah'),('Sarah'),('Connor'),('Madelyn'),('Jeremiah'),('Ruby'),('Roman'),('Hailey'),('Easton'),
('Kinsley'),('Miles'),('Madison'),('Nicholas'),('Autumn'),('Cooper'),('Nevaeh'),('Ian'),('Piper'),('Jordan'),
('Samantha'),('Asher'),('Ariana'),('Jace'),('Naomi'),('Gavin'),('Serenity'),('Colton'),('Willow'),('Brayden'),
('Everly'),('Austin'),('Cora'),('Kevin'),('Emery'),('Brandon'),('Maya'),('Diego'),('Ivy'),('Tristan'),
('Maria'),('Zachary'),('Jasmine'),('Caleb'),('Melody'),('Christian'),('Athena'),('Ezekiel'),('Elena'),('Josiah'),
('Mila'),('Xavier'),('Isla'),('Dominic'),('Luna'),('Jason'),('Aaliyah'),('Evan'),('Nova'),('Robert'),
('Sophie'),('Colin'),('Kate'),('Brenda'),('Troy'),('Marco'),('Nina'),('Kara'),('Derek'),('Paula'),
('Ramon'),('Tessa'),('Felix'),('Kiara'),('Omar'),('Selena'),('Hector'),('Veronica'),('Rosa'),('Nico'),
('Tariq'),('Bianca'),('Holly'),('Quinn'),('Seth'),('Phoebe'),('Reese'),('Talia'),('Miles2'),('Judy2'),
('Idris2'),('Ava2'),('Liam2'),('Noah2'),('Emma2'),('Olivia2'),('Elijah2'),('Mia2'),('Lucas2'),('Sophia2'),
('Mason2'),('Isabella2'),('Ethan2'),('Amelia2'),('Logan2'),('Harper2'),('James2'),('Evelyn2'),('Benjamin2'),('Abigail2');
-- (still distinct because of the "2" suffix)
GO

------------------------------------------------------------
-- 3) Last name targets
--    5 heavy names with 150 occurrences each (within 100-250)
--    100 other names split 92/93 to total 10,000 rows.
------------------------------------------------------------
IF OBJECT_ID('tempdb..#LastNameTargets') IS NOT NULL DROP TABLE #LastNameTargets;
CREATE TABLE #LastNameTargets (LastName VARCHAR(50) PRIMARY KEY, TargetCount INT NOT NULL);

-- Heavy last names (150 each = 750 total)
INSERT INTO #LastNameTargets VALUES
('Jones',150),
('Miller',150),
('Roberts',150),
('Williams',150),
('Smith',150);

-- 50 names @92 each
INSERT INTO #LastNameTargets VALUES
('Adams',92),('Baker',92),('Bell',92),('Brooks',92),('Campbell',92),('Carter',92),('Clark',92),('Coleman',92),('Cook',92),('Cooper',92),
('Cox',92),('Cruz',92),('Diaz',92),('Edwards',92),('Evans',92),('Flores',92),('Foster',92),('Garcia',92),('Gomez',92),('Gonzalez',92),
('Gray',92),('Green',92),('Hall',92),('Harris',92),('Hayes',92),('Henderson',92),('Hernandez',92),('Hill',92),('Howard',92),('Hughes',92),
('Jackson',92),('James',92),('Kelly',92),('King',92),('Lee',92),('Lewis',92),('Long',92),('Lopez',92),('Martin',92),('Martinez',92),
('Mitchell',92),('Moore',92),('Morgan',92),('Morris',92),('Murphy',92),('Nelson',92),('Nguyen',92),('Ortiz',92),('Parker',92),('Perez',92);

-- 50 names @93 each
INSERT INTO #LastNameTargets VALUES
('Peterson',93),('Phillips',93),('Powell',93),('Price',93),('Ramirez',93),('Reed',93),('Rivera',93),('Rogers',93),('Ross',93),('Russell',93),
('Sanders',93),('Scott',93),('Simmons',93),('Stewart',93),('Taylor',93),('Thomas',93),('Thompson',93),('Torres',93),('Turner',93),('Walker',93),
('Ward',93),('Watson',93),('White',93),('Wood',93),('Wright',93),('Young',93),('Allen',93),('Barnes',93),('Bennett',93),('Bishop',93),
('Bryant',93),('Burke',93),('Butler',93),('Caldwell',93),('Carson',93),('Chapman',93),('Cunningham',93),('Daniels',93),('Davis',93),('Dawson',93),
('Ferguson',93),('Fisher',93),('Ford',93),('Gibson',93),('Gordon',93),('Grant',93),('Griffin',93),('Hamilton',93),('Harvey',93),('Holland',93);
GO

------------------------------------------------------------
-- 4) Expand last names to exact counts, then pair with first names
------------------------------------------------------------
;WITH LastNameExpanded AS (
    SELECT 
        l.LastName,
        ROW_NUMBER() OVER (PARTITION BY l.LastName ORDER BY (SELECT NULL)) AS rn
    FROM #LastNameTargets l
    CROSS APPLY (
        SELECT TOP (l.TargetCount) 1 AS x
        FROM sys.all_objects a
    ) gen
),
FirstNameList AS (
    SELECT FirstName, ROW_NUMBER() OVER (ORDER BY FirstName) AS fn_rn
    FROM #FirstNames
),
AssignedNames AS (
    SELECT 
        e.LastName,
        e.rn,
        f.FirstName
    FROM LastNameExpanded e
    JOIN FirstNameList f
      ON f.fn_rn = ((e.rn - 1) % (SELECT COUNT(*) FROM #FirstNames)) + 1
),
FinalRows AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n,
        FirstName,
        LastName
    FROM AssignedNames
)
INSERT INTO dbo.People23 (FName, LName, Address, City, StateProv, Country)
SELECT
    FirstName,
    LastName,
    CONCAT(n, ' Main St') AS Address,
    CASE (n % 6)
        WHEN 0 THEN 'Big Rapids'
        WHEN 1 THEN 'Grand Rapids'
        WHEN 2 THEN 'Lansing'
        WHEN 3 THEN 'Detroit'
        WHEN 4 THEN 'Chicago'
        ELSE 'Ann Arbor'
    END AS City,
    CASE (n % 5)
        WHEN 0 THEN 'MI'
        WHEN 1 THEN 'IL'
        WHEN 2 THEN 'OH'
        WHEN 3 THEN 'IN'
        ELSE 'WI'
    END AS StateProv,
    CASE (n % 3)
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'Canada'
        ELSE 'Mexico'
    END AS Country
FROM FinalRows;
GO

------------------------------------------------------------
-- 5) Verification queries (for your screenshots)
------------------------------------------------------------

-- Total row count should be 10,000
SELECT COUNT(*) AS TotalPeople FROM dbo.People23;

-- Show 5+ last names with 100-250 occurrences
SELECT LName, COUNT(*) AS Cnt
FROM dbo.People23
GROUP BY LName
HAVING COUNT(*) BETWEEN 100 AND 250
ORDER BY Cnt DESC;

-- Confirm no full name occurs more than 5 times
SELECT FName, LName, COUNT(*) AS FullNameCnt
FROM dbo.People23
GROUP BY FName, LName
HAVING COUNT(*) > 5;
GO

SELECT 
    FName,
    LName,
    COUNT(*) AS FullNameCnt
FROM dbo.People23
GROUP BY FName, LName
ORDER BY FullNameCnt DESC, LName, FName;

USE RetailDB;
GO

------------------------------------------------------------
-- 1) Drop + Create Phone Table for People23
------------------------------------------------------------
IF OBJECT_ID('dbo.PeoplePhone23','U') IS NOT NULL
    DROP TABLE dbo.PeoplePhone23;
GO

CREATE TABLE dbo.PeoplePhone23 (
    PhoneID     INT IDENTITY(1,1) PRIMARY KEY,
    PersonID    INT NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    PhoneType   VARCHAR(20) NOT NULL DEFAULT('Mobile'),

    CONSTRAINT FK_PeoplePhone23_People23
        FOREIGN KEY (PersonID)
        REFERENCES dbo.People23(PersonID)
);
GO

------------------------------------------------------------
-- 2) Insert 10,000 phone records
--    - First 9,000 unique phone numbers
--    - Last 1,000 duplicates (reusing earlier numbers)
------------------------------------------------------------

;WITH P AS (
    SELECT PersonID
    FROM dbo.People23
)
INSERT INTO dbo.PeoplePhone23 (PersonID, PhoneNumber, PhoneType)
SELECT
    PersonID,

    CASE 
        -- 90% unique numbers for PersonID 1–9000
        WHEN PersonID <= 9000 THEN
            CONCAT('555-', RIGHT('0000000' + CAST(PersonID AS VARCHAR(7)), 7))

        -- last 1000 reuse numbers from first 500 people
        ELSE
            CONCAT('555-', RIGHT('0000000' + CAST((PersonID % 500) + 1 AS VARCHAR(7)), 7))
    END AS PhoneNumber,

    CASE (PersonID % 3)
        WHEN 0 THEN 'Home'
        WHEN 1 THEN 'Mobile'
        ELSE 'Work'
    END AS PhoneType
FROM P;
GO

------------------------------------------------------------
-- 3) Verification queries (for screenshots)
------------------------------------------------------------

-- A) Row count should be 10,000
SELECT COUNT(*) AS TotalPhones
FROM dbo.PeoplePhone23;

-- B) Count how many UNIQUE phone numbers exist
SELECT COUNT(DISTINCT PhoneNumber) AS UniquePhones
FROM dbo.PeoplePhone23;

-- C) Show percent unique (must be >= 90%)
SELECT 
    CAST(COUNT(DISTINCT PhoneNumber) * 100.0 / COUNT(*) AS DECIMAL(5,2)) 
    AS PercentUnique
FROM dbo.PeoplePhone23;

-- D) Optional: show duplicate phone numbers
SELECT PhoneNumber, COUNT(*) AS TimesUsed
FROM dbo.PeoplePhone23
GROUP BY PhoneNumber
HAVING COUNT(*) > 1
ORDER BY TimesUsed DESC;
GO

-- Audit table for update logging
CREATE TABLE dbo.People23_AuditUpdate
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    PersonID INT,
    OldFName VARCHAR(100),
    OldLName VARCHAR(100),
    OldCity VARCHAR(100),
    OldState VARCHAR(50),
    NewFName VARCHAR(100),
    NewLName VARCHAR(100),
    NewCity VARCHAR(100),
    NewState VARCHAR(50),
    ChangeDate DATETIME DEFAULT GETDATE()
);

USE RetailDB;
GO

------------------------------------------------------------
-- 0) Drop trigger + audit table if they already exist
------------------------------------------------------------
IF OBJECT_ID('dbo.trg_People23_Update', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_People23_Update;
GO

IF OBJECT_ID('dbo.People23_AuditUpdate', 'U') IS NOT NULL
    DROP TABLE dbo.People23_AuditUpdate;
GO

------------------------------------------------------------
-- 1) Create audit table (logs BEFORE + AFTER values)
------------------------------------------------------------
CREATE TABLE dbo.People23_AuditUpdate
(
    AuditID     INT IDENTITY(1,1) PRIMARY KEY,
    PersonID    INT NOT NULL,

    OldFName    VARCHAR(100) NULL,
    OldLName    VARCHAR(100) NULL,
    OldCity     VARCHAR(100) NULL,

    NewFName    VARCHAR(100) NULL,
    NewLName    VARCHAR(100) NULL,
    NewCity     VARCHAR(100) NULL,

    ChangeDate  DATETIME NOT NULL DEFAULT GETDATE()
);
GO

------------------------------------------------------------
-- 2) Create UPDATE trigger on People23
--    Writes old/new values into People23_AuditUpdate
------------------------------------------------------------
CREATE TRIGGER dbo.trg_People23_Update
ON dbo.People23
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.People23_AuditUpdate
    (
        PersonID,
        OldFName, OldLName, OldCity,
        NewFName, NewLName, NewCity
    )
    SELECT
        d.PersonID,
        d.FName AS OldFName,
        d.LName AS OldLName,
        d.City  AS OldCity,
        i.FName AS NewFName,
        i.LName AS NewLName,
        i.City  AS NewCity
    FROM deleted d
    INNER JOIN inserted i
        ON d.PersonID = i.PersonID;
END;
GO

------------------------------------------------------------
-- 3) TEST it (pick any PersonID you want)
------------------------------------------------------------
UPDATE dbo.People23
SET City = 'Miami'
WHERE PersonID = 1;
GO

------------------------------------------------------------
-- 4) View audit results
------------------------------------------------------------
SELECT * 
FROM dbo.People23_AuditUpdate
ORDER BY ChangeDate DESC;
GO

USE RetailDB;
GO

------------------------------------------------------------
-- 0) Drop trigger if it already exists
------------------------------------------------------------
IF OBJECT_ID('dbo.trg_People23_CascadeDelete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_People23_CascadeDelete;
GO

------------------------------------------------------------
-- 1) Create cascading delete trigger
--    Deletes from PeoplePhone23 first, then People23
------------------------------------------------------------
CREATE TRIGGER dbo.trg_People23_CascadeDelete
ON dbo.People23
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- delete child rows first
    DELETE ph
    FROM dbo.PeoplePhone23 ph
    INNER JOIN deleted d
        ON ph.PersonID = d.PersonID;

    -- delete parent rows after children removed
    DELETE p
    FROM dbo.People23 p
    INNER JOIN deleted d
        ON p.PersonID = d.PersonID;
END;
GO

------------------------------------------------------------
-- 2) TEST IT (for screenshots)
------------------------------------------------------------

-- Pick a PersonID that has phones (example 1)
SELECT * 
FROM dbo.PeoplePhone23
WHERE PersonID = 1;

-- Now delete that person
DELETE FROM dbo.People23
WHERE PersonID = 1;

-- Verify phones are gone
SELECT * 
FROM dbo.PeoplePhone23
WHERE PersonID = 1;

-- Verify person is gone
SELECT * 
FROM dbo.People23
WHERE PersonID = 1;
GO

-- Table to store history of address changes
CREATE TABLE dbo.People23_AddressHistory
(
    HistoryID    INT IDENTITY(1,1) PRIMARY KEY,
    PersonID     INT,
    OldCity      VARCHAR(100),
    OldStateProv VARCHAR(50),
    NewCity      VARCHAR(100),
    NewStateProv VARCHAR(50),
    ChangeDate   DATETIME DEFAULT GETDATE()
);
GO

-- Trigger that logs address changes to People23
CREATE TRIGGER trg_People23_AddressChange
ON dbo.People23
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only log if city or state actually changed
    IF UPDATE(City) OR UPDATE(StateProv)
    BEGIN
        INSERT INTO dbo.People23_AddressHistory
        (
            PersonID,
            OldCity, OldStateProv,
            NewCity, NewStateProv,
            ChangeDate
        )
        SELECT
            d.PersonID,
            d.City       AS OldCity,
            d.StateProv  AS OldStateProv,
            i.City       AS NewCity,
            i.StateProv  AS NewStateProv,
            GETDATE()
        FROM deleted d
        JOIN inserted i ON d.PersonID = i.PersonID;
    END
END;
GO

-- Update a person to trigger the history log
UPDATE dbo.People23
SET City = 'Dallas',
    StateProv = 'TX'
WHERE PersonID = 1;
GO

SELECT *
FROM dbo.People23_AddressHistory
ORDER BY ChangeDate DESC;
GO

USE RetailDB;
GO

------------------------------------------------------------
-- 0) Clean up if rerunning
------------------------------------------------------------
IF OBJECT_ID('dbo.BigTable26', 'U') IS NOT NULL
    DROP TABLE dbo.BigTable26;
GO

------------------------------------------------------------
-- 1) Create table (10+ columns)
------------------------------------------------------------
CREATE TABLE dbo.BigTable26
(
    BigID        INT IDENTITY(1,1) PRIMARY KEY,   -- key column
    FName        VARCHAR(50),
    LName        VARCHAR(50),
    City         VARCHAR(100),
    StateProv    VARCHAR(50),
    Country      VARCHAR(50),
    ZipCode      VARCHAR(15),
    Age          INT,
    Salary       DECIMAL(10,2),
    CreatedDate  DATETIME
);
GO

------------------------------------------------------------
-- 2) Insert 1,000,000 rows using a tally approach
------------------------------------------------------------
;WITH
N1 AS (SELECT 1 AS n FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) a(n)), --10
N2 AS (SELECT 1 AS n FROM N1 a CROSS JOIN N1 b), --100
N3 AS (SELECT 1 AS n FROM N2 a CROSS JOIN N2 b), --10,000
N4 AS (SELECT 1 AS n FROM N3 a CROSS JOIN N2 b), --1,000,000
Nums AS (
    SELECT TOP (1000000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM N4
)
INSERT INTO dbo.BigTable26
(
    FName, LName, City, StateProv, Country,
    ZipCode, Age, Salary, CreatedDate
)
SELECT
    CONCAT('FName', rn % 500) AS FName,
    CASE 
        WHEN rn % 5 = 0 THEN 'Jones'
        WHEN rn % 5 = 1 THEN 'Miller'
        WHEN rn % 5 = 2 THEN 'Roberts'
        WHEN rn % 5 = 3 THEN 'Williams'
        ELSE 'Smith'
    END AS LName,
    CONCAT('City', rn % 200) AS City,
    CONCAT('ST', rn % 50) AS StateProv,
    'USA' AS Country,
    RIGHT(CONCAT('00000', rn % 99999), 5) AS ZipCode,
    (rn % 80) + 18 AS Age,
    CAST((rn % 90000) + 30000 AS DECIMAL(10,2)) AS Salary,
    DATEADD(DAY, -(rn % 3650), GETDATE()) AS CreatedDate;
GO

------------------------------------------------------------
-- 3) Confirm row count (should say 1,000,000)
------------------------------------------------------------
SELECT COUNT(*) AS TotalRows FROM dbo.BigTable26;
GO

------------------------------------------------------------
-- 4) Turn on timing + IO stats for accurate comparison
------------------------------------------------------------
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

------------------------------------------------------------
-- 5) OPTIONAL: Clear cache so first run is "cold"
--     (teacher note: caching affects results)
------------------------------------------------------------
-- DBCC FREEPROCCACHE;
-- DBCC DROPCLEANBUFFERS;
GO

------------------------------------------------------------
-- 6) SELECT tests WITHOUT index
------------------------------------------------------------

-- A) Select one particular record (by BigID)
SELECT * 
FROM dbo.BigTable26
WHERE BigID = 500000;

-- B) Select a small number of records (~10)
SELECT TOP 10 *
FROM dbo.BigTable26
WHERE City = 'City25';

-- C) Multiple randomly distributed last names
SELECT *
FROM dbo.BigTable26
WHERE LName IN ('Jones','Miller','Roberts','Williams');

-- D) About 10% of records
SELECT *
FROM dbo.BigTable26
WHERE Age BETWEEN 30 AND 37;

GO

------------------------------------------------------------
-- 7) Create an index (on common search column)
------------------------------------------------------------
CREATE INDEX IX_BigTable26_LName
ON dbo.BigTable26 (LName);
GO

------------------------------------------------------------
-- 8) OPTIONAL: clear cache again before indexed run
------------------------------------------------------------
-- DBCC FREEPROCCACHE;
-- DBCC DROPCLEANBUFFERS;
GO

------------------------------------------------------------
-- 9) Run SAME SELECT tests WITH index
------------------------------------------------------------

-- A) Select one particular record
SELECT * 
FROM dbo.BigTable26
WHERE BigID = 500000;

-- B) Select a small number of records (~10)
SELECT TOP 10 *
FROM dbo.BigTable26
WHERE City = 'City25';

-- C) Multiple randomly distributed last names
SELECT *
FROM dbo.BigTable26
WHERE LName IN ('Jones','Miller','Roberts','Williams');

-- D) About 10% of records
SELECT *
FROM dbo.BigTable26
WHERE Age BETWEEN 30 AND 37;

GO

------------------------------------------------------------
-- 10) Turn stats back off
------------------------------------------------------------
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

USE RetailDB;
GO

/*----------------------------------------------------------
  27) Error logging routine using @@ERROR
-----------------------------------------------------------*/

-----------------------------
-- 1. Drop / create ErrorLog
-----------------------------
IF OBJECT_ID('dbo.ErrorLog27', 'U') IS NOT NULL
    DROP TABLE dbo.ErrorLog27;
GO

CREATE TABLE dbo.ErrorLog27
(
    ErrorLogID     INT IDENTITY(1,1) PRIMARY KEY,  -- unique row id
    ErrorNumber    INT            NULL,            -- from @@ERROR
    ErrorSeverity  INT            NULL,            -- from ERROR_SEVERITY()
    ErrorState     INT            NULL,            -- from ERROR_STATE()
    ErrorLine      INT            NULL,            -- from ERROR_LINE()
    ErrorMessage   VARCHAR(4000)  NULL,            -- from ERROR_MESSAGE()
    ProcName       SYSNAME        NULL,            -- OBJECT_NAME(@@PROCID)
    UserName       SYSNAME        NULL,            -- SUSER_SNAME()
    HostName       SYSNAME        NULL,            -- HOST_NAME()
    AppName        SYSNAME        NULL,            -- APP_NAME()
    ErrorTime      DATETIME       NOT NULL 
                     DEFAULT(GETDATE())
);
GO

------------------------------------------------------------
-- 2. Drop / create stored procedure that logs errors
------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Demo_ErrorLogging27', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Demo_ErrorLogging27;
GO

CREATE PROCEDURE dbo.sp_Demo_ErrorLogging27
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Err INT;   -- will hold value from @@ERROR

    BEGIN TRY
        ---------------------------------------------------
        -- INTENTIONAL ERROR:
        --  Try to insert a duplicate PersonID into People23.
        --  Assumes PersonID = 1 already exists.
        ---------------------------------------------------
        INSERT INTO dbo.People23
        (
            PersonID, FName, LName, Address, City, StateProv, Country
        )
        VALUES
        (
            1,                       -- duplicate PK on purpose
            'ErrorTest',
            'Demo',
            '123 Fake St',
            'Nowhere',
            'XX',
            'USA'
        );

        -- If no error happens, nothing is logged.
    END TRY
    BEGIN CATCH
        ---------------------------------------------------
        -- Capture error using @@ERROR and CATCH functions
        ---------------------------------------------------
        SET @Err = @@ERROR;   -- capture error number from system variable

        INSERT INTO dbo.ErrorLog27
        (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorLine,
            ErrorMessage,
            ProcName,
            UserName,
            HostName,
            AppName
        )
        VALUES
        (
            @Err,                       -- from @@ERROR
            ERROR_SEVERITY(),           -- extra useful info
            ERROR_STATE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
            OBJECT_NAME(@@PROCID),
            SUSER_SNAME(),
            HOST_NAME(),
            APP_NAME()
        );
    END CATCH;
END;
GO

------------------------------------------------------------
-- 3. Run the procedure to generate an error and log it
------------------------------------------------------------
EXEC dbo.sp_Demo_ErrorLogging27;
GO

------------------------------------------------------------
-- 4. View the contents of the error log
------------------------------------------------------------
SELECT *
FROM dbo.ErrorLog27
ORDER BY ErrorLogID DESC;
GO

USE RetailDB;
GO

/*----------------------------------------------------------
  28) Routine demonstrating UNION vs UNION ALL
-----------------------------------------------------------*/

-- A) View distinct cities from People23 and Customer using UNION

SELECT 
    City,
    'People23' AS SourceTable
FROM dbo.People23

UNION  -- removes duplicates

SELECT 
    City,
    'Customer' AS SourceTable
FROM dbo.Customer
ORDER BY City;


-- B) Same demo using UNION ALL to show duplicates remain

SELECT 
    City,
    'People23' AS SourceTable
FROM dbo.People23

UNION ALL -- keeps duplicates

SELECT 
    City,
    'Customer' AS SourceTable
FROM dbo.Customer
ORDER BY City;

USE RetailDB;
GO

USE RetailDB;
GO

/****************************************************
  29) SELECT INTO to populate a table from another table.
      Includes a randomized version for extra credit.
*****************************************************/
USE RetailDB;
GO

------------------------------------------------------
-- 1. Clean up any old demo tables if they exist
------------------------------------------------------
IF OBJECT_ID('dbo.BigTable26_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.BigTable26_Copy;
GO

IF OBJECT_ID('dbo.BigTable26_RandomSample', 'U') IS NOT NULL
    DROP TABLE dbo.BigTable26_RandomSample;
GO

------------------------------------------------------
-- 2. Basic SELECT INTO (straight copy of all rows)
--    Creates a NEW TABLE named BigTable26_Copy
--    Structure and data are copied automatically
------------------------------------------------------
SELECT *
INTO dbo.BigTable26_Copy
FROM dbo.BigTable26;
GO


------------------------------------------------------
-- 3. SELECT INTO with RANDOMIZED sample (extra point)
--    RAND(CHECKSUM(NEWID())) creates random values
--    TOP 10% sample of BigTable26
------------------------------------------------------
SELECT TOP 10 PERCENT *, 
       RAND(CHECKSUM(NEWID())) AS RandomValue
INTO dbo.BigTable26_RandomSample
FROM dbo.BigTable26;
GO

------------------------------------------------------
-- 4. Verification: Compare row counts
--    Confirms both new tables were created
------------------------------------------------------
SELECT 
    'BigTable26' AS TableName,
    COUNT(*)      AS [RowCount]
FROM dbo.BigTable26

UNION ALL

SELECT
    'BigTable26_Copy' AS TableName,
    COUNT(*)          AS [RowCount]
FROM dbo.BigTable26_Copy;


------------------------------------------------------
-- 5. Row count for the randomized sample
------------------------------------------------------
SELECT 
    'BigTable26_RandomSample' AS TableName,
    COUNT(*)                  AS [RowCount]
FROM dbo.BigTable26_RandomSample;
GO


USE RetailDB;
GO

-- Add some demo rows so row counts aren't zero (optional, for #29)
-- NOTE: We only insert into the columns that actually exist
--       (assuming BigID is an IDENTITY and created automatically)

INSERT INTO dbo.BigTable26 (FName, LName, City, Age)
VALUES
('Test1', 'Smith',  'City01', 25),
('Test2', 'Jones',  'City02', 30),
('Test3', 'Miller', 'City03', 35);

USE RetailDB;
GO

/* 
===========================================================
30) SQL routine that produces a graphical output (chart)

Purpose:
    Show a simple text-based bar chart of total sales
    by product category.  The "bars" are made from '#'
    characters using REPLICATE().

Tables used:
    Category, Product, PurchaseItem

Output:
    CategoryName | TotalSales | SalesBar
===========================================================
*/

USE RetailDB;
GO

;WITH SalesByCategory AS
(
    SELECT 
        c.CategoryName,
        SUM(pi.LineTotal) AS TotalSales
    FROM dbo.Category       AS c
    LEFT JOIN dbo.Product   AS p
        ON c.CategoryID = p.CategoryID
    LEFT JOIN dbo.PurchaseItem AS pi
        ON p.ProductID = pi.ProductID
    GROUP BY c.CategoryName
)
SELECT
    CategoryName,
    TotalSales,
    -- Simple text "bar" where length is proportional to TotalSales
    REPLICATE(
        '#',
        CASE 
            WHEN TotalSales IS NULL THEN 0
            ELSE CAST(TotalSales / 5 AS INT)   -- adjust divisor to change bar length
        END
    ) AS SalesBar
FROM SalesByCategory
ORDER BY TotalSales DESC;

/*
===========================================================
  30) pt 2 SQL routine that produces a graphical output (chart)
      Text-based bar chart of number of customers per City
      - Uses REPLICATE() to draw a bar for each city
      - Fully documented and runs in RetailDB
===========================================================
*/

USE RetailDB;
GO

;WITH CityCounts AS
(
    -- 1) Count how many customers live in each city
    SELECT 
        c.City,
        COUNT(*) AS NumCustomers
    FROM dbo.Customer AS c
    GROUP BY c.City
),
CityStats AS
(
    -- 2) Get totals and the maximum count for scaling the bar length
    SELECT
        SUM(NumCustomers)        AS TotalCustomers,
        MAX(NumCustomers)        AS MaxCustomers
    FROM CityCounts
)
-- 3) Produce an ASCII bar chart of customers by city
SELECT
    cc.City,
    cc.NumCustomers,
    CAST(
        100.0 * cc.NumCustomers / NULLIF(cs.TotalCustomers, 0)
        AS DECIMAL(5,2)
    ) AS PctOfTotal,
    REPLICATE(
        '█',                                                   -- bar character
        CASE 
            WHEN cs.MaxCustomers = 0 THEN 0
            ELSE CAST(1.0 * cc.NumCustomers / cs.MaxCustomers * 30 AS INT)
                 -- 30 = max bar length; adjust if you want longer/shorter bars
        END
    ) AS CustomerBar
FROM CityCounts AS cc
CROSS JOIN CityStats AS cs
ORDER BY cc.NumCustomers DESC;

/* 
===========================================================
31) SQL Routine that Uses a Subquery (Nested Query)

Purpose:
    List all customers whose total purchase amount is
    greater than the average total purchase amount
    across all customers.

Uses:
    - Aggregate by customer
    - Nested subquery to calculate the average total
      spent and compare each customer against it.
===========================================================
*/

USE RetailDB;
GO

SELECT 
    c.CustomerID,
    c.FName,
    c.LName,
    ISNULL(SUM(pi.LineTotal), 0) AS TotalSpent
FROM dbo.Customer      AS c
LEFT JOIN dbo.Purchase AS p
    ON c.CustomerID = p.CustomerID
LEFT JOIN dbo.PurchaseItem AS pi
    ON p.PurchaseID = pi.PurchaseID
GROUP BY 
    c.CustomerID,
    c.FName,
    c.LName
HAVING 
    ISNULL(SUM(pi.LineTotal), 0) >
    (
        -- Nested subquery: average total spent per customer
        SELECT AVG(CustomerTotal)
        FROM
        (
            SELECT 
                c2.CustomerID,
                ISNULL(SUM(pi2.LineTotal), 0) AS CustomerTotal
            FROM dbo.Customer      AS c2
            LEFT JOIN dbo.Purchase AS p2
                ON c2.CustomerID = p2.CustomerID
            LEFT JOIN dbo.PurchaseItem AS pi2
                ON p2.PurchaseID = pi2.PurchaseID
            GROUP BY c2.CustomerID
        ) AS TotalsByCustomer
    )
ORDER BY TotalSpent DESC;

/*
===========================================================
32) Capture IP address and include it in @@ERROR logging
===========================================================
*/
USE RetailDB;
GO

/* 1) Create ErrorLog table if it doesn't exist (with IPAddress) */
IF OBJECT_ID('dbo.ErrorLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ErrorLog
    (
        ErrorLogID    INT IDENTITY(1,1) PRIMARY KEY,
        ErrorNumber   INT,
        ErrorSeverity INT,
        ErrorState    INT,
        ErrorLine     INT,
        ErrorMessage  NVARCHAR(4000),
        IPAddress     VARCHAR(48),      -- client IP
        ErrorDate     DATETIME DEFAULT(GETDATE())
    );
END;
GO

/* 2) Create/replace logging procedure that captures IP address */
IF OBJECT_ID('dbo.usp_LogErrorWithIP', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_LogErrorWithIP;
GO

CREATE PROCEDURE dbo.usp_LogErrorWithIP
    @ErrorNumber   INT,
    @ErrorSeverity INT,
    @ErrorState    INT,
    @ErrorLine     INT,
    @ErrorMessage  NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IPAddress VARCHAR(48);

    -- Get client IP for this session
    SELECT 
        @IPAddress = client_net_address
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID;

    BEGIN TRY
        INSERT INTO dbo.ErrorLog
        (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorLine,
            ErrorMessage,
            IPAddress
        )
        VALUES
        (
            @ErrorNumber,
            @ErrorSeverity,
            @ErrorState,
            @ErrorLine,
            @ErrorMessage,
            @IPAddress
        );
    END TRY
    BEGIN CATCH
        -- If logging itself fails, swallow it so we don't loop errors
        PRINT 'Error while writing to ErrorLog.';
    END CATCH;
END;
GO

/* 3) Demo block: cause an error, catch it, and log with IP */
BEGIN TRY
    DECLARE @x INT = 1, @y INT = 0, @z INT;
    SET @z = @x / @y;  -- divide by zero (intentional)
END TRY
BEGIN CATCH
    DECLARE
        @ErrorNumber   INT           = ERROR_NUMBER(),
        @ErrorSeverity INT           = ERROR_SEVERITY(),
        @ErrorState    INT           = ERROR_STATE(),
        @ErrorLine     INT           = ERROR_LINE(),
        @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();

    EXEC dbo.usp_LogErrorWithIP
        @ErrorNumber   = @ErrorNumber,
        @ErrorSeverity = @ErrorSeverity,
        @ErrorState    = @ErrorState,
        @ErrorLine     = @ErrorLine,
        @ErrorMessage  = @ErrorMessage;

    PRINT 'Error captured and logged with IP address.';
END CATCH;
GO

/* 4) Show most recent log rows, including IPAddress */
SELECT TOP 10
    ErrorLogID,
    ErrorNumber,
    ErrorSeverity,
    ErrorState,
    ErrorLine,
    ErrorMessage,
    IPAddress,
    ErrorDate
FROM dbo.ErrorLog
ORDER BY ErrorLogID DESC;
GO

/*
===========================================================
33) SQL routine that uses a nested subquery
    - Shows each customer's total spending
    - Uses a nested subquery to compute the overall average
      and flags who is ABOVE that average.
===========================================================
*/
USE RetailDB;
GO

SELECT
    c.CustomerID,
    c.FName,
    c.LName,
    ct.TotalAmount,
    overall.AvgAmount AS OverallAverage,
    CASE 
        WHEN ct.TotalAmount > overall.AvgAmount THEN 'Above Average'
        WHEN ct.TotalAmount = overall.AvgAmount THEN 'At Average'
        ELSE 'Below Average'
    END AS SpendingCategory
FROM dbo.Customer AS c
LEFT JOIN
(
    -- Subquery #1: total spending per customer
    SELECT
        p.CustomerID,
        SUM(pi.LineTotal) AS TotalAmount
    FROM dbo.Purchase      AS p
    INNER JOIN dbo.PurchaseItem AS pi
        ON p.PurchaseID = pi.PurchaseID
    GROUP BY p.CustomerID
) AS ct
    ON c.CustomerID = ct.CustomerID
CROSS JOIN
(
    -- Subquery #2 (nested): overall average of customer totals
    SELECT AVG(CustomerTotal) AS AvgAmount
    FROM
    (
        -- Inner subquery used only to feed the AVG()
        SELECT
            p.CustomerID,
            SUM(pi.LineTotal) AS CustomerTotal
        FROM dbo.Purchase      AS p
        INNER JOIN dbo.PurchaseItem AS pi
            ON p.PurchaseID = pi.PurchaseID
        GROUP BY p.CustomerID
    ) AS totalsPerCustomer
) AS overall
ORDER BY ct.TotalAmount DESC;
GO

/*
===========================================================
34) SQL routine that uses a Common Table Expression (CTE)
    - Find each customer's total spending
    - Then use a CTE to rank the top spenders in each city
===========================================================
*/
USE RetailDB;
GO

;WITH CustomerTotals AS
(
    -- First CTE: total amount spent by each customer
    SELECT
        c.CustomerID,
        c.FName,
        c.LName,
        c.City,
        ISNULL(SUM(pi.LineTotal), 0.00) AS TotalSpent
    FROM dbo.Customer      AS c
    LEFT JOIN dbo.Purchase AS p
        ON c.CustomerID = p.CustomerID
    LEFT JOIN dbo.PurchaseItem AS pi
        ON p.PurchaseID = pi.PurchaseID
    GROUP BY
        c.CustomerID,
        c.FName,
        c.LName,
        c.City
),
RankedSpenders AS
(
    -- Second CTE: rank customers within each city by TotalSpent
    SELECT
        CustomerID,
        FName,
        LName,
        City,
        TotalSpent,
        ROW_NUMBER() OVER (
            PARTITION BY City
            ORDER BY TotalSpent DESC
        ) AS CityRank
    FROM CustomerTotals
)

-- Final query: show the top spenders per city
SELECT
    City,
    CustomerID,
    FName,
    LName,
    TotalSpent,
    CityRank
FROM RankedSpenders
WHERE CityRank <= 3       -- top 3 per city (adjust if you want)
ORDER BY
    City,
    CityRank;
GO

/*
===========================================================
 34 pt 2 ) SQL routine that uses a Common Table Expression (CTE)
     - CTE calculates total spending per customer
     - Main query filters and sorts on the CTE result
===========================================================
*/

USE RetailDB;
GO

;WITH CustomerTotals AS
(
    SELECT
        c.CustomerID,
        c.FName,
        c.LName,
        c.City,
        c.State,
        -- Sum of all LineTotals for this customer
        ISNULL(SUM(pi.LineTotal), 0.00) AS TotalSpent
    FROM dbo.Customer      AS c
    LEFT JOIN dbo.Purchase AS p
        ON c.CustomerID = p.CustomerID
    LEFT JOIN dbo.PurchaseItem AS pi
        ON p.PurchaseID = pi.PurchaseID
    GROUP BY
        c.CustomerID,
        c.FName,
        c.LName,
        c.City,
        c.State
)
SELECT
    CustomerID,
    FName,
    LName,
    City,
    State,
    TotalSpent
FROM CustomerTotals
WHERE TotalSpent > 0        -- only customers who have actually spent money
ORDER BY TotalSpent DESC;   -- biggest spender first
GO

/*
===========================================================
 35) SSIS routine that imports an Excel file and is scheduled
     to run at 9:00 AM every day
===========================================================

Package Name:
    Import_DailySales_FromExcel

Source Excel File (example):
    C:\DataImports\DailySales.xlsx
    Sheet: Sheet1$
    Columns: SaleDate, CustomerID, ProductID, Quantity, PriceAtSale

Destination Table in RetailDB:
    dbo.DailySalesStaging
    (SaleDate DATE,
     CustomerID INT,
     ProductID INT,
     Quantity INT,
     PriceAtSale DECIMAL(10,2))

-------------------------------------------
 A) Create the SSIS package in Visual Studio
-------------------------------------------

1. Open SQL Server Data Tools / Visual Studio.
2. Create a new project:
       File -> New -> Project -> "Integration Services Project"
       Project name: RetailDB_Imports

3. In Solution Explorer, rename Package.dtsx to:
       Import_DailySales_FromExcel.dtsx

4. Double-click the package to edit it.

-------------------------------------------
 B) Control Flow: add a Data Flow Task
-------------------------------------------

1. In the Control Flow tab, drag a **Data Flow Task** onto the design surface.
2. Rename the task:
       "DFT – Import Daily Sales from Excel"

3. Double-click the Data Flow Task to open the **Data Flow** tab.

-------------------------------------------
 C) Data Flow: Excel Source -> OLE DB Destination
-------------------------------------------

1. In the Data Flow tab, add an **Excel Source**:
       - Right-click the Data Flow surface -> SSIS Toolbox -> Excel Source.
       - Double-click it to configure:
            • New Excel Connection Manager
            • Excel file path: C:\DataImports\DailySales.xlsx
            • Excel version: Microsoft Excel 2007–2013
            • Data access mode: "Table or view"
            • Name of the Excel sheet: "Sheet1$"

2. Click "Columns" and verify the mappings:
       SaleDate, CustomerID, ProductID, Quantity, PriceAtSale

3. Add an **OLE DB Destination**:
       - Drag OLE DB Destination onto the Data Flow.
       - Connect the Excel Source (green arrow) to the OLE DB Destination.

4. Configure the OLE DB Destination:
       - OLE DB connection manager: point to **RetailDB** database.
       - Data access mode: "Table or view – fast load".
       - Name of the table: dbo.DailySalesStaging
         (create this table in RetailDB ahead of time if needed).

5. Click "Mappings" and map Excel columns to destination columns:
       SaleDate      -> SaleDate
       CustomerID    -> CustomerID
       ProductID     -> ProductID
       Quantity      -> Quantity
       PriceAtSale   -> PriceAtSale

6. (Optional) Add a **Derived Column** or **Data Conversion** transform
   between source and destination if data types need to be cleaned
   or converted (e.g., Excel dates, numeric formats, etc.).

-------------------------------------------
 D) Package configuration / error handling (optional but nice)
-------------------------------------------

1. In the Event Handlers tab, you can log on OnError to a table or file.
2. Enable SSIS logging (right-click Control Flow background -> Logging)
   to capture errors and row counts.
3. Save and build the SSIS project:
       Build -> Build Solution

-------------------------------------------
 E) Deploy the SSIS package to SQL Server
-------------------------------------------

1. In Visual Studio, right-click the project -> "Deploy".
2. Use the Integration Services Catalog (SSISDB) on your SQL Server:
       - Server name: your SQL Server instance
       - Folder: \SSISDB\RetailDB_Imports
       - Deploy Import_DailySales_FromExcel.dtsx

-------------------------------------------
 F) Schedule the SSIS package to run daily at 9:00 AM
-------------------------------------------

1. Open **SQL Server Management Studio (SSMS)**.
2. Connect to the **Database Engine**.
3. Expand "SQL Server Agent" (start the Agent service if it’s stopped).
4. Right-click "Jobs" -> "New Job…"
       - Name: Import Daily Sales from Excel

5. Go to the **Steps** page -> "New…"
       - Step name: Run SSIS Daily Sales Import
       - Type: SQL Server Integration Services Package
       - Run as: SQL Agent service account (or a proxy with SSIS rights)
       - Package source: SSIS Catalog
       - Server: your SSIS server
       - Package: \SSISDB\RetailDB_Imports\Import_DailySales_FromExcel.dtsx

6. Go to the **Schedules** page -> "New…"
       - Name: Daily at 9AM
       - Schedule type: Recurring
       - Occurs: Daily
       - Occurs once at: 9:00:00 AM
       - Enabled: checked

7. Click OK to save the schedule, then OK again to create the job.

Result:
    Every day at 9:00 AM, SQL Server Agent executes the SSIS package
    Import_DailySales_FromExcel, which imports the contents of the
    Excel file C:\DataImports\DailySales.xlsx into RetailDB.dbo.DailySalesStaging.
*/
