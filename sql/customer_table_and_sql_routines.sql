/**************************************************************************
    SQL Assignment 3
    Question 1
    Task:
        Create a Customer table using appropriate data types with the
        following columns:
            - CustomerID (identity starting at 100)
            - First Name
            - Last Name
            - Date of Birth
            - Address
            - City
            - State
            - Zip Code
        This routine drops the table if it already exists, then recreates it,
        and finally verifies that the table was created successfully.
**************************************************************************/

--=====================================================
-- Step 1: Drop Customer table if it already exists
--=====================================================
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Customer;
END;
GO

--=====================================================
-- Step 2: Create Customer table
--=====================================================
CREATE TABLE dbo.Customer
(
    CustomerID   INT IDENTITY(100,1) NOT NULL,  -- identity starts at 100
    FirstName    VARCHAR(50)        NOT NULL,
    LastName     VARCHAR(50)        NOT NULL,
    DateOfBirth  DATE               NULL,
    Address      VARCHAR(100)       NULL,
    City         VARCHAR(50)        NULL,
    State        CHAR(2)            NULL,
    ZipCode      VARCHAR(10)        NULL
);
GO

--=====================================================
-- Step 3: Verification query for Question 1
--     This confirms that the table exists and shows the structure.
--=====================================================
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
ORDER BY ORDINAL_POSITION;
GO

/**************************************************************************
    SQL Assignment 3
    Question 2
    Task:
        Define the primary key on the CustomerID column of the Customer table.
        This routine:
            1. Drops the primary key if it already exists.
            2. Creates a named primary key constraint on CustomerID.
            3. Verifies that the primary key is defined.
**************************************************************************/

--=====================================================
-- Step 1: Drop existing primary key (if it exists)
--=====================================================
IF EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE [type] = 'PK'
          AND [name] = 'PK_Customer_CustomerID'
)
BEGIN
    ALTER TABLE dbo.Customer
        DROP CONSTRAINT PK_Customer_CustomerID;
END;
GO

--=====================================================
-- Step 2: Add primary key on CustomerID
--=====================================================
ALTER TABLE dbo.Customer
    ADD CONSTRAINT PK_Customer_CustomerID
        PRIMARY KEY CLUSTERED (CustomerID);
GO

--=====================================================
-- Step 3: Verification query for Question 2
--     Shows the primary key constraint on the Customer table.
--=====================================================
SELECT 
    tc.TABLE_NAME,
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON  tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_NAME      = kcu.TABLE_NAME
WHERE tc.TABLE_NAME = 'Customer'
  AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';
GO

/**************************************************************************
    SQL Assignment 3
    Question 3
    Task:
        Define two indexes on the Customer table:
            1) An index using the primary key column (CustomerID).
            2) A composite index using LastName and FirstName.
        This routine:
            - Drops the indexes if they already exist.
            - Recreates both indexes.
            - Verifies that the indexes exist.
**************************************************************************/

--=====================================================
-- Step 1: Drop existing indexes if they exist
--=====================================================
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Customer_CustomerID'
      AND object_id = OBJECT_ID('dbo.Customer')
)
BEGIN
    DROP INDEX IX_Customer_CustomerID ON dbo.Customer;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Customer_LastName_FirstName'
      AND object_id = OBJECT_ID('dbo.Customer')
)
BEGIN
    DROP INDEX IX_Customer_LastName_FirstName ON dbo.Customer;
END;
GO

--=====================================================
-- Step 2: Create index on primary key column (CustomerID)
--     Note: The primary key already has a clustered index,
--     but this demonstrates explicitly defining an index in SQL.
--=====================================================
CREATE NONCLUSTERED INDEX IX_Customer_CustomerID
    ON dbo.Customer (CustomerID);
GO

--=====================================================
-- Step 3: Create composite index on LastName, FirstName
--=====================================================
CREATE NONCLUSTERED INDEX IX_Customer_LastName_FirstName
    ON dbo.Customer (LastName, FirstName);
GO

--=====================================================
-- Step 4: Verification query for Question 3
--     Shows the indexes defined on the Customer table.
--=====================================================
SELECT 
    t.name           AS TableName,
    i.name           AS IndexName,
    i.type_desc      AS IndexType,
    i.is_primary_key AS IsPrimaryKeyIndex,
    i.is_unique      AS IsUnique
FROM sys.indexes i
JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE t.name = 'Customer'
  AND i.name IN ('IX_Customer_CustomerID', 'IX_Customer_LastName_FirstName')
ORDER BY i.name;
GO

/**************************************************************************
    SQL Assignment 3
    Question 4
    Task:
        Insert fifty rows of unique data into the Customer table.
        This routine:
            - Uses a loop and variables to generate 50 unique customers.
            - Relies on the IDENTITY property for CustomerID (starts at 100).
            - Verifies that at least 50 rows now exist in the table.
**************************************************************************/

--=====================================================
-- Step 1: Insert 50 unique Customer rows
--=====================================================
DECLARE @Counter INT = 1;

WHILE @Counter <= 50
BEGIN
    INSERT INTO dbo.Customer
    (
        FirstName,
        LastName,
        DateOfBirth,
        Address,
        City,
        State,
        ZipCode
    )
    VALUES
    (
        CONCAT('FirstName_', @Counter),          -- unique first name
        CONCAT('LastName_', @Counter),           -- unique last name
        DATEADD(DAY, @Counter, '1990-01-01'),    -- slightly different DOB
        CONCAT(@Counter, ' Main Street'),        -- unique address
        'Big Rapids',                            -- example city
        'MI',                                    -- example state
        '49307'                                  -- example zip code
    );

    SET @Counter = @Counter + 1;
END;
GO

--=====================================================
-- Step 2: Verification query for Question 4
--     Confirms that at least 50 rows exist in Customer
--     and shows a sample of the data (first 10 by ID).
--=====================================================
SELECT COUNT(*) AS TotalCustomers
FROM dbo.Customer;

SELECT TOP 10 *
FROM dbo.Customer
ORDER BY CustomerID;
GO

/**************************************************************************
    SQL Assignment 3
    Question 5
    Task:
        Truncate and then drop the Customer table.
        This routine:
            - Verifies table exists before truncating.
            - Truncates Customer (removes all rows, resets identity).
            - Drops the Customer table.
            - Confirms that the table no longer exists.
**************************************************************************/

--=====================================================
-- Step 1: Truncate Customer table (if it exists)
--=====================================================
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE dbo.Customer;
END;
GO

--=====================================================
-- Step 2: Drop Customer table (if it exists)
--=====================================================
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Customer;
END;
GO

--=====================================================
-- Step 3: Verification for Question 5
--     Confirms that the Customer table no longer exists.
--=====================================================
SELECT 
    CASE 
        WHEN OBJECT_ID('dbo.Customer', 'U') IS NULL 
        THEN 'Customer table successfully dropped'
        ELSE 'Customer table STILL EXISTS — check drop routine'
    END AS StatusMessage;
GO

/**************************************************************************
    SQL Assignment 3
    Question 6
    Task:
        Create a view of the Customer table using all columns except
        DateOfBirth.
        Because the Customer table was dropped in Question 5, this routine:
            1. Recreates the Customer table.
            2. Reinserts 50 rows of data.
            3. Creates the view without DateOfBirth.
            4. Verifies that the view works.
**************************************************************************/

--=====================================================
-- Step 1: Recreate Customer table
--=====================================================
CREATE TABLE dbo.Customer
(
    CustomerID   INT IDENTITY(100,1) NOT NULL,
    FirstName    VARCHAR(50)        NOT NULL,
    LastName     VARCHAR(50)        NOT NULL,
    DateOfBirth  DATE               NULL,
    Address      VARCHAR(100)       NULL,
    City         VARCHAR(50)        NULL,
    State        CHAR(2)            NULL,
    ZipCode      VARCHAR(10)        NULL
);
GO

--=====================================================
-- Step 2: Reinsert 50 rows of unique data
--=====================================================
DECLARE @Counter INT = 1;

WHILE @Counter <= 50
BEGIN
    INSERT INTO dbo.Customer
    (
        FirstName,
        LastName,
        DateOfBirth,
        Address,
        City,
        State,
        ZipCode
    )
    VALUES
    (
        CONCAT('FirstName_', @Counter),
        CONCAT('LastName_', @Counter),
        DATEADD(DAY, @Counter, '1990-01-01'),
        CONCAT(@Counter, ' Main Street'),
        'Big Rapids',
        'MI',
        '49307'
    );

    SET @Counter = @Counter + 1;
END;
GO

--=====================================================
-- Step 3: Create view excluding DateOfBirth
--=====================================================
IF OBJECT_ID('dbo.vCustomer_NoDOB', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.vCustomer_NoDOB;
END;
GO

CREATE VIEW dbo.vCustomer_NoDOB AS
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Address,
    City,
    State,
    ZipCode
FROM dbo.Customer;
GO

--=====================================================
-- Step 4: Verification for Question 6
--     Displays first 10 rows from the new view.
--=====================================================
SELECT TOP 10 *
FROM dbo.vCustomer_NoDOB
ORDER BY CustomerID;
GO

/**************************************************************************
    SQL Assignment 3
    Question 7
    Task:
        Use the view created in Question 6 (vCustomer_NoDOB) to display
        all Customers sorted by FirstName in descending order.
        This routine:
            - Selects from the view only (no direct table access).
            - Orders the result set by FirstName DESC.
**************************************************************************/

--=====================================================
-- Step 1: Display all customers using the view
--         sorted by FirstName in descending order
--=====================================================
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Address,
    City,
    State,
    ZipCode
FROM dbo.vCustomer_NoDOB
ORDER BY FirstName DESC;
GO

/**************************************************************************
    SQL Assignment 3
    Question 8
    Task:
        Create a SQL routine with at least 3 IF statements and print
        confirmation that each IF condition works.
        This routine:
            - Declares variables
            - Uses 3 separate IF statements
            - Prints confirmation messages for each
**************************************************************************/

--=====================================================
-- Step 1: Declare variables for checking
--=====================================================
DECLARE @Number1 INT = 10;
DECLARE @Number2 INT = 20;
DECLARE @City VARCHAR(20) = 'Big Rapids';

--=====================================================
-- Step 2: IF statement #1
--=====================================================
IF @Number1 < @Number2
BEGIN
    PRINT 'IF #1: @Number1 is less than @Number2 - Condition TRUE';
END;

--=====================================================
-- Step 3: IF statement #2
--=====================================================
IF @Number2 > 15
BEGIN
    PRINT 'IF #2: @Number2 is greater than 15 - Condition TRUE';
END;

--=====================================================
-- Step 4: IF statement #3
--=====================================================
IF @City = 'Big Rapids'
BEGIN
    PRINT 'IF #3: @City equals Big Rapids - Condition TRUE';
END;
GO

/**************************************************************************
    SQL Assignment 3
    Question 9
    Task:
        Create a SQL routine that uses IF, ELSE IF, and ELSE.
        This routine:
            - Declares a test score variable
            - Uses IF / ELSE IF / ELSE to evaluate the score
            - Prints confirmation messages for each condition
**************************************************************************/

--=====================================================
-- Step 1: Declare variable for testing logic
--=====================================================
DECLARE @Score INT = 85;   -- Change value to test different branches

--=====================================================
-- Step 2: Conditional logic using IF / ELSE IF / ELSE
--=====================================================
IF @Score >= 90
BEGIN
    PRINT 'Condition 1: Score is 90 or above - Grade A';
END
ELSE IF @Score >= 80
BEGIN
    PRINT 'Condition 2: Score is between 80 and 89 - Grade B';
END
ELSE
BEGIN
    PRINT 'Condition 3: Score is below 80 - Grade C or lower';
END;
GO

/**************************************************************************
    SQL Assignment 3
    Question 10
    Task:
        Create a CASE statement with at least 3 WHEN options.
        This routine:
            - Declares a variable representing a customer age
            - Uses CASE to determine an age group
            - Returns a labeled age category for confirmation
**************************************************************************/

--=====================================================
-- Step 1: Declare variable for CASE test
--=====================================================
DECLARE @Age INT = 32;   -- Change this to test each CASE branch

--=====================================================
-- Step 2: Use CASE with at least 3 WHEN options
--=====================================================
SELECT 
    @Age AS InputAge,
    CASE
        WHEN @Age < 18 THEN 'Minor'
        WHEN @Age BETWEEN 18 AND 64 THEN 'Adult'
        WHEN @Age >= 65 THEN 'Senior'
        ELSE 'Unknown Category'
    END AS AgeCategory;
GO

/**************************************************************************
    SQL Assignment 3
    Question 11
    Task:
        Alter an existing table by adding a new integer column 
        that allows NULL values.
        This routine:
            - Adds a column named LoyaltyPoints (INT NULL)
            - Verifies the column was successfully added
**************************************************************************/

--=====================================================
-- Step 1: Add new integer column to Customer table
--=====================================================
ALTER TABLE dbo.Customer
ADD LoyaltyPoints INT NULL;
GO

--=====================================================
-- Step 2: Verification query
--     Shows the new column in the table definition
--=====================================================
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
  AND COLUMN_NAME = 'LoyaltyPoints';
GO

/**************************************************************************
    SQL Assignment 3
    Question 12
    Task:
        Create an UPDATE routine with error checking and error logging.
        This routine:
            1. Creates an ErrorLog table (if it does not already exist).
            2. Performs a successful UPDATE wrapped in TRY...CATCH.
            3. Performs a second UPDATE that intentionally causes an error
               to demonstrate error logging.
            4. Displays the logged errors for confirmation.
**************************************************************************/

--=====================================================
-- Step 1: Create ErrorLog table (if not exists)
--=====================================================
IF OBJECT_ID('dbo.ErrorLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ErrorLog
    (
        ErrorLogID     INT IDENTITY(1,1) PRIMARY KEY,
        ErrorDateTime  DATETIME        NOT NULL DEFAULT(GETDATE()),
        ErrorMessage   NVARCHAR(4000)  NOT NULL,
        ProcedureName  SYSNAME         NULL,
        Severity       INT             NULL
    );
END;
GO

--=====================================================
-- Step 2: Successful UPDATE with error checking/logging
--=====================================================
BEGIN TRY
    UPDATE dbo.Customer
    SET LoyaltyPoints = ISNULL(LoyaltyPoints, 0) + 10
    WHERE CustomerID = 100;

    PRINT 'Question 12: Successful UPDATE completed with no errors.';
END TRY
BEGIN CATCH
    INSERT INTO dbo.ErrorLog (ErrorMessage, ProcedureName, Severity)
    VALUES (ERROR_MESSAGE(), ERROR_PROCEDURE(), ERROR_SEVERITY());

    PRINT 'Question 12: An error occurred during UPDATE (logged in ErrorLog).';
END CATCH;
GO

--=====================================================
-- Step 3: Forced error to demonstrate logging
--     This intentionally causes a conversion error inside TRY...CATCH.
--=====================================================
BEGIN TRY
    UPDATE dbo.Customer
    SET LoyaltyPoints = CAST('NotANumber' AS INT)   -- will cause error
    WHERE CustomerID = 100;

    PRINT 'Question 12 (Forced Error): UPDATE unexpectedly succeeded.';
END TRY
BEGIN CATCH
    INSERT INTO dbo.ErrorLog (ErrorMessage, ProcedureName, Severity)
    VALUES (ERROR_MESSAGE(), ERROR_PROCEDURE(), ERROR_SEVERITY());

    PRINT 'Question 12 (Forced Error): Error occurred and was logged.';
END CATCH;
GO

--=====================================================
-- Step 4: Verification for Question 12
--     Show contents of ErrorLog to confirm logging.
--=====================================================
SELECT TOP 10
    ErrorLogID,
    ErrorDateTime,
    ErrorMessage,
    ProcedureName,
    Severity
FROM dbo.ErrorLog
ORDER BY ErrorLogID DESC;
GO
/**************************************************************************
    SQL Assignment 3
    Question 13
    Task:
        Write a SQL statement that defines and uses variables.
        This routine:
            - Declares variables for subtotal, tax rate, and total.
            - Calculates the tax amount and final total.
            - Returns all values in a single SELECT statement.
**************************************************************************/

--=====================================================
-- Step 1: Declare and set variables
--=====================================================
DECLARE @SubTotal   DECIMAL(10,2);
DECLARE @TaxRate    DECIMAL(5,2);
DECLARE @TaxAmount  DECIMAL(10,2);
DECLARE @GrandTotal DECIMAL(10,2);

SET @SubTotal = 125.50;   -- example subtotal
SET @TaxRate  = 0.06;     -- 6% tax

--=====================================================
-- Step 2: Use variables in calculations
--=====================================================
SET @TaxAmount  = @SubTotal * @TaxRate;
SET @GrandTotal = @SubTotal + @TaxAmount;

--=====================================================
-- Step 3: Return results to verify variable usage
--=====================================================
SELECT 
    @SubTotal   AS SubTotal,
    @TaxRate    AS TaxRate,
    @TaxAmount  AS TaxAmount,
    @GrandTotal AS GrandTotal;
GO

/**************************************************************************
    SQL Assignment 3
    Question 14
    Task:
        Create a stored procedure that accepts a variable and includes
        error checking and logging during execution.
        This routine:
            - Creates usp_UpdateLoyalty
            - Accepts @CustomerID as input
            - Updates LoyaltyPoints for that customer
            - Logs any error to ErrorLog table using TRY/CATCH
            - Executes procedure twice (success + forced failure)
**************************************************************************/

--=====================================================
-- Step 1: Drop stored procedure if it exists
--=====================================================
IF OBJECT_ID('dbo.usp_UpdateLoyalty', 'P') IS NOT NULL
DROP PROCEDURE dbo.usp_UpdateLoyalty;
GO

--=====================================================
-- Step 2: Create stored procedure
--=====================================================
CREATE PROCEDURE dbo.usp_UpdateLoyalty
(
    @CustomerID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Customer
        SET LoyaltyPoints = ISNULL(LoyaltyPoints, 0) + 5
        WHERE CustomerID = @CustomerID;

        PRINT 'usp_UpdateLoyalty: Loyalty points updated successfully.';
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog (ErrorMessage, ProcedureName, Severity)
        VALUES (ERROR_MESSAGE(), ERROR_PROCEDURE(), ERROR_SEVERITY());

        PRINT 'usp_UpdateLoyalty: ERROR occurred - logged in ErrorLog.';
    END CATCH;
END;
GO

--=====================================================
-- Step 3: EXECUTE procedure with valid ID (success expected)
--=====================================================
EXEC dbo.usp_UpdateLoyalty @CustomerID = 100;
GO

--=====================================================
-- Step 4: EXECUTE procedure with invalid ID (forced error)
--     Example: CustomerID that does not exist.
--=====================================================
EXEC dbo.usp_UpdateLoyalty @CustomerID = 999999;
GO

--=====================================================
-- Step 5: Verification — show last logged errors
--=====================================================
SELECT TOP 5 *
FROM dbo.ErrorLog
ORDER BY ErrorLogID DESC;
GO

/**************************************************************************
    SQL Assignment 3
    Question 15
    Task:
        Insert ten rows of data into a new table named Cars that includes
        at least 5 columns. The data must vary for each record by using
        variables that are incremented and/or changed within the routine.
**************************************************************************/

--=====================================================
-- Step 1: Drop Cars table if it already exists
--=====================================================
IF OBJECT_ID('dbo.Cars', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Cars;
END;
GO

--=====================================================
-- Step 2: Create Cars table with at least 5 columns
--=====================================================
CREATE TABLE dbo.Cars
(
    CarID      INT IDENTITY(1,1) PRIMARY KEY,
    Make       VARCHAR(50)   NOT NULL,
    Model      VARCHAR(50)   NOT NULL,
    ModelYear  INT           NOT NULL,
    Color      VARCHAR(20)   NOT NULL,
    BasePrice  DECIMAL(10,2) NOT NULL
);
GO

--=====================================================
-- Step 3: Insert 10 rows using variables that change
--=====================================================
DECLARE @Counter   INT = 1;
DECLARE @Year      INT = 2020;
DECLARE @BasePrice DECIMAL(10,2) = 20000.00;
DECLARE @Color     VARCHAR(20);

WHILE @Counter <= 10
BEGIN
    -- Simple color rotation based on counter
    SET @Color = CASE 
                    WHEN @Counter % 3 = 1 THEN 'Red'
                    WHEN @Counter % 3 = 2 THEN 'Blue'
                    ELSE 'Black'
                 END;

    INSERT INTO dbo.Cars (Make, Model, ModelYear, Color, BasePrice)
    VALUES
    (
        'Toyota',                                      -- same make
        CONCAT('Model_', @Counter),                    -- unique model
        @Year,                                         -- changing year
        @Color,                                        -- changing color
        @BasePrice                                    -- changing price
    );

    -- Change values for next iteration
    SET @Counter   = @Counter + 1;
    SET @Year      = @Year + 1;          -- next model year
    SET @BasePrice = @BasePrice + 500.00;-- slightly higher price
END;
GO

--=====================================================
-- Step 4: Verification for Question 15
--=====================================================
SELECT *
FROM dbo.Cars
ORDER BY CarID;
GO

/**************************************************************************
    SQL Assignment 3
    Question 16
    Task:
        Create a table named HikingLocations that has the appropriate
        structure to remove duplicates when loading the table.
        Requirement: use IGNORE_DUP_KEY = ON.
        This routine:
            1. Drops HikingLocations if it exists.
            2. Creates HikingLocations table.
            3. Creates a UNIQUE index with IGNORE_DUP_KEY = ON.
            4. Attempts to insert duplicate rows to show they are ignored.
            5. Displays the final contents of the table.
**************************************************************************/

--=====================================================
-- Step 1: Drop table if it already exists
--=====================================================
IF OBJECT_ID('dbo.HikingLocations', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.HikingLocations;
END;
GO

--=====================================================
-- Step 2: Create HikingLocations table
--=====================================================
CREATE TABLE dbo.HikingLocations
(
    LocationID  INT IDENTITY(1,1) PRIMARY KEY,
    TrailName   VARCHAR(100) NOT NULL,
    State       CHAR(2)      NOT NULL,
    Difficulty  VARCHAR(20)  NOT NULL
);
GO

--=====================================================
-- Step 3: Create UNIQUE index with IGNORE_DUP_KEY = ON
--     This prevents duplicate TrailName + State combinations.
--=====================================================
CREATE UNIQUE NONCLUSTERED INDEX IX_HikingLocations_Trail_State
ON dbo.HikingLocations (TrailName, State)
WITH (IGNORE_DUP_KEY = ON);
GO

--=====================================================
-- Step 4: Insert data including intentional duplicates
--     Duplicate rows (same TrailName + State) will be ignored.
--=====================================================
INSERT INTO dbo.HikingLocations (TrailName, State, Difficulty) VALUES
('Pine Ridge Trail',  'MI', 'Moderate'),
('River Bend Trail',  'MI', 'Easy'),
('Summit Peak Trail', 'CO', 'Hard'),
('Pine Ridge Trail',  'MI', 'Moderate'),  -- duplicate key, ignored
('Canyon Loop',       'UT', 'Moderate'),
('Summit Peak Trail', 'CO', 'Hard');      -- duplicate key, ignored
GO

--=====================================================
-- Step 5: Verification for Question 16
--     Shows that duplicates were not inserted.
--=====================================================
SELECT *
FROM dbo.HikingLocations
ORDER BY LocationID;
GO

/**************************************************************************
    SQL Assignment 3
    Question 17
    Task:
        1) Create a table named HikingLocations2 that has 10 records and
           3 of the records are duplicates (by key).
        2) Create a routine that identifies duplicate records by key value.
        3) Create a second routine that displays only the duplicate rows.
        Key definition for duplicates: TrailName + State.
**************************************************************************/

--=====================================================
-- Step 1: Drop and recreate HikingLocations2
--=====================================================
IF OBJECT_ID('dbo.HikingLocations2', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.HikingLocations2;
END;
GO

CREATE TABLE dbo.HikingLocations2
(
    LocationID  INT IDENTITY(1,1) PRIMARY KEY,
    TrailName   VARCHAR(100) NOT NULL,
    State       CHAR(2)      NOT NULL,
    Difficulty  VARCHAR(20)  NOT NULL
);
GO

--=====================================================
-- Step 2: Insert 10 rows, with 3 duplicates by (TrailName, State)
--     Duplicates:
--         - Pine Ridge Trail, MI   (appears more than once)
--         - Summit Peak Trail, CO  (appears more than once)
--         - Canyon Loop, UT        (appears more than once)
--=====================================================
INSERT INTO dbo.HikingLocations2 (TrailName, State, Difficulty) VALUES
('Pine Ridge Trail',   'MI', 'Moderate'),   -- 1
('River Bend Trail',   'MI', 'Easy'),       -- 2
('Summit Peak Trail',  'CO', 'Hard'),       -- 3
('Canyon Loop',        'UT', 'Moderate'),   -- 4
('Pine Ridge Trail',   'MI', 'Moderate'),   -- 5 duplicate
('Canyon Loop',        'UT', 'Hard'),       -- 6 duplicate (same key)
('Lakeview Path',      'MI', 'Easy'),       -- 7
('Summit Peak Trail',  'CO', 'Hard'),       -- 8 duplicate
('Forest Run',         'WA', 'Moderate'),   -- 9
('Canyon Loop',        'UT', 'Moderate');   -- 10 duplicate
GO

/**************************************************************************
    Part 1: Identify duplicate key values
    (shows each duplicate key and how many times it appears)
**************************************************************************/

--=====================================================
-- Question 17 - Routine A: Identify duplicate keys
--=====================================================
SELECT 
    TrailName,
    State,
    COUNT(*) AS Occurrences
FROM dbo.HikingLocations2
GROUP BY TrailName, State
HAVING COUNT(*) > 1;
GO

/**************************************************************************
    Part 2: Display only the duplicate rows
    (shows all rows whose (TrailName, State) are duplicates)
**************************************************************************/

--=====================================================
-- Question 17 - Routine B: Display only duplicate rows
--=====================================================
SELECT h.*
FROM dbo.HikingLocations2 AS h
JOIN
(
    SELECT 
        TrailName,
        State,
        COUNT(*) AS Occurrences
    FROM dbo.HikingLocations2
    GROUP BY TrailName, State
    HAVING COUNT(*) > 1
) d
    ON h.TrailName = d.TrailName
   AND h.State     = d.State
ORDER BY h.TrailName, h.State, h.LocationID;
GO

/**************************************************************************
    SQL Assignment 3
    Question 18
    Task:
        Create an INSERT routine for HikingLocations2 that:
            - Uses variables
            - Performs error checking and error logging
        This routine:
            1. Inserts several new rows using variables in a TRY block.
            2. Intentionally causes an error in a second TRY block to show
               that the error is logged in dbo.ErrorLog.
**************************************************************************/

--=====================================================
-- Step 1: Successful INSERT using variables with TRY/CATCH
--=====================================================
DECLARE @Counter    INT = 1;
DECLARE @TrailName  VARCHAR(100);
DECLARE @State      CHAR(2);
DECLARE @Difficulty VARCHAR(20);

BEGIN TRY
    WHILE @Counter <= 3
    BEGIN
        SET @TrailName = CONCAT('New Trail ', @Counter);
        SET @State = CASE 
                        WHEN @Counter = 1 THEN 'MI'
                        WHEN @Counter = 2 THEN 'CO'
                        ELSE 'UT'
                     END;
        SET @Difficulty = CASE 
                            WHEN @Counter = 1 THEN 'Easy'
                            WHEN @Counter = 2 THEN 'Moderate'
                            ELSE 'Hard'
                          END;

        INSERT INTO dbo.HikingLocations2 (TrailName, State, Difficulty)
        VALUES (@TrailName, @State, @Difficulty);

        SET @Counter = @Counter + 1;
    END;

    PRINT 'Question 18: Successful INSERT routine completed with no errors.';
END TRY
BEGIN CATCH
    INSERT INTO dbo.ErrorLog (ErrorMessage, ProcedureName, Severity)
    VALUES (ERROR_MESSAGE(), 'Q18_Insert_HikingLocations2_Success', ERROR_SEVERITY());

    PRINT 'Question 18: ERROR occurred during successful INSERT routine (logged).';
END CATCH;
GO

--=====================================================
-- Step 2: Forced error to demonstrate error logging
--     This attempt violates NOT NULL constraint on State.
--=====================================================
DECLARE @BadTrailName  VARCHAR(100) = 'Bad Trail';
DECLARE @BadState      CHAR(2) = NULL;          -- invalid, State is NOT NULL
DECLARE @BadDifficulty VARCHAR(20) = 'Easy';

BEGIN TRY
    INSERT INTO dbo.HikingLocations2 (TrailName, State, Difficulty)
    VALUES (@BadTrailName, @BadState, @BadDifficulty);

    PRINT 'Question 18 (Forced Error): INSERT unexpectedly succeeded.';
END TRY
BEGIN CATCH
    INSERT INTO dbo.ErrorLog (ErrorMessage, ProcedureName, Severity)
    VALUES (ERROR_MESSAGE(), 'Q18_Insert_HikingLocations2_ForcedError', ERROR_SEVERITY());

    PRINT 'Question 18 (Forced Error): Error occurred and was logged in ErrorLog.';
END CATCH;
GO

--=====================================================
-- Step 3: Verification for Question 18
--     Show the latest HikingLocations2 rows and recent ErrorLog entries.
--=====================================================
SELECT TOP 15 *
FROM dbo.HikingLocations2
ORDER BY LocationID DESC;

SELECT TOP 5
    ErrorLogID,
    ErrorDateTime,
    ErrorMessage,
    ProcedureName,
    Severity
FROM dbo.ErrorLog
ORDER BY ErrorLogID DESC;
GO















