/* STEP 1: Create the two databases */
CREATE DATABASE RateDB;
GO

CREATE DATABASE CustomerDB;
GO

/* Use RateDB */
USE RateDB;
GO

/* STEP 2: Create the Rate table with age ranges in 5-year increments */
CREATE TABLE dbo.Rate (
    RateID   INT IDENTITY(1,1) PRIMARY KEY,   -- unique ID per rate row
    BeginAge INT NOT NULL,                    -- starting age of the band
    EndAge   INT NOT NULL,                    -- ending age of the band
    Rate     DECIMAL(10,2) NOT NULL          -- dollar amount for that band
);
GO

/* STEP 3: Populate the Rate table.
   Age ranges: 0-4, 5-9, 10-14, ... , 95-99  */

INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (0, 4,   50.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (5, 9,   55.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (10, 14, 60.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (15, 19, 70.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (20, 24, 80.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (25, 29, 90.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (30, 34, 100.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (35, 39, 110.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (40, 44, 120.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (45, 49, 135.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (50, 54, 150.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (55, 59, 170.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (60, 64, 190.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (65, 69, 210.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (70, 74, 235.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (75, 79, 260.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (80, 84, 290.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (85, 89, 325.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (90, 94, 360.00);
INSERT INTO dbo.Rate (BeginAge, EndAge, Rate) VALUES (95, 99, 400.00);
GO

/* STEP 4: Create the Customer table */
USE CustomerDB;
GO

CREATE TABLE dbo.Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,  -- unique ID
    FName      VARCHAR(50) NOT NULL,           -- first name
    LName      VARCHAR(50) NOT NULL,           -- last name
    DOB        DATE        NOT NULL,           -- date of birth
    Gender     CHAR(1)     NOT NULL            -- 'M' or 'F' (or whatever your prof wants)
    -- Rider flag will be added later with ALTER TABLE
);
GO

/* STEP 5: Insert customers (example rows; you must get to 50 total) */
USE CustomerDB;
GO

INSERT INTO dbo.Customer (FName, LName, DOB, Gender)
VALUES ('John',   'Smith',     '2000-05-05', 'M'),  -- age 25 range 25-29
       ('Emily',  'Johnson',   '1988-11-20', 'F'),  -- age 37 range 35-39
       ('Michael','Brown',     '1975-02-10', 'M'),  -- age 50 range 50-54
       ('Sarah',  'Davis',     '1960-09-01', 'F'),  -- age 65 range 65-69
       ('David',  'Wilson',    '2015-03-15', 'M'),  -- age 10 range 10-14
       ('Olivia', 'Taylor',    '1999-12-25', 'F'),  -- age 25 range 25-29
       ('Liam',   'Anderson',  '2010-01-30', 'M'),  -- age 15 range 15-19
       ('Sophia', 'Thomas',    '1990-07-07', 'F'),  -- age 35 range 35-39
       ('Noah',   'Moore',     '1945-04-18', 'M'),  -- older range
       ('Ava',    'Jackson',   '1980-08-09', 'F');  -- 40-44 range

-- Keep adding customers with different DOBs until you reach 50 rows.
-- Make sure they cover many age ranges so your report shows all bands.
GO

/* STEP 6: Add RiderFlag column to Customer table */

USE CustomerDB;
GO

ALTER TABLE dbo.Customer
ADD RiderFlag BIT NOT NULL DEFAULT 0;  -- default means "no rider"
GO

/* STEP 6b: Set RiderFlag = 1 for any 10 customers (example) */

-- Example: make customers with IDs 1–10 have the rider
UPDATE dbo.Customer
SET RiderFlag = 1
WHERE CustomerID BETWEEN 1 AND 10;
GO

-- You can choose any 10 customers; this is just easy.

/* STEP 7: Test query: calculate age from DOB */

USE CustomerDB;
GO

SELECT 
    CustomerID,
    FName,
    LName,
    DOB,
    DATEDIFF(YEAR, DOB, GETDATE()) 
      - CASE 
            WHEN MONTH(DOB) > MONTH(GETDATE()) 
                 OR (MONTH(DOB) = MONTH(GETDATE()) 
                 AND DAY(DOB) > DAY(GETDATE())) 
            THEN 1 
            ELSE 0 
        END AS Age
FROM dbo.Customer;
GO

/* STEP 8: Routine to assign people an insurance rate based on DOB (age) */

USE CustomerDB;
GO

SELECT 
    c.CustomerID,
    c.FName,
    c.LName,
    c.DOB,
    -- Compute age (same logic as given)
    Age = DATEDIFF(YEAR, c.DOB, GETDATE()) 
          - CASE 
                WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                     OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                     AND DAY(c.DOB) > DAY(GETDATE())) 
                THEN 1 
                ELSE 0 
            END,
    r.BeginAge,
    r.EndAge,
    r.Rate AS BaseRate
FROM dbo.Customer AS c
JOIN RateDB.dbo.Rate AS r
    ON (
        DATEDIFF(YEAR, c.DOB, GETDATE()) 
        - CASE 
              WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                   OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                   AND DAY(c.DOB) > DAY(GETDATE())) 
              THEN 1 
              ELSE 0 
          END
       ) BETWEEN r.BeginAge AND r.EndAge
ORDER BY r.BeginAge, c.LName, c.FName;
GO

/* STEP 9: Report with Rider cost (Rate x Rider factor) */

/* Note: still using CustomerDB as the current DB */
USE CustomerDB;
GO

SELECT 
    c.CustomerID,
    c.FName,
    c.LName,
    c.DOB,
    -- Compute Age
    Age = DATEDIFF(YEAR, c.DOB, GETDATE()) 
          - CASE 
                WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                     OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                     AND DAY(c.DOB) > DAY(GETDATE())) 
                THEN 1 
                ELSE 0 
            END,
    AgeRange = CONCAT(r.BeginAge, '-', r.EndAge),   -- helpful display of range
    r.Rate AS BaseRate,
    c.RiderFlag,
    -- FinalRate: if rider, multiply by 1.5
    FinalRate = CASE 
                    WHEN c.RiderFlag = 1 THEN r.Rate * 1.5 
                    ELSE r.Rate 
                END
FROM dbo.Customer AS c
JOIN RateDB.dbo.Rate AS r
    ON (
        DATEDIFF(YEAR, c.DOB, GETDATE()) 
        - CASE 
              WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                   OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                   AND DAY(c.DOB) > DAY(GETDATE())) 
              THEN 1 
              ELSE 0 
          END
       ) BETWEEN r.BeginAge AND r.EndAge
ORDER BY 
    r.BeginAge,        -- age range first
    c.LName,
    c.FName;           -- then by last & first name
GO

/* ----------------------------------------------------------
   Routine 1: List all customers with calculated Age
   Purpose: Verify DOB → Age calculation
-----------------------------------------------------------*/
USE CustomerDB;
GO

SELECT 
    CustomerID,
    FName,
    LName,
    DOB,
    -- Calculate exact age as of today
    DATEDIFF(YEAR, DOB, GETDATE()) 
      - CASE 
            WHEN MONTH(DOB) > MONTH(GETDATE()) 
                 OR (MONTH(DOB) = MONTH(GETDATE()) 
                 AND DAY(DOB) > DAY(GETDATE())) 
            THEN 1 
            ELSE 0 
        END AS Age
FROM dbo.Customer
ORDER BY LName, FName;
GO

/* ----------------------------------------------------------
   Routine 2: Assign insurance rate based on DOB (Age)
   Purpose: Match each customer to the correct rate band
            in RateDB.dbo.Rate using their calculated Age.
-----------------------------------------------------------*/
USE CustomerDB;
GO

SELECT 
    c.CustomerID,
    c.FName,
    c.LName,
    c.DOB,
    -- Calculate age
    Age = DATEDIFF(YEAR, c.DOB, GETDATE()) 
          - CASE 
                WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                     OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                     AND DAY(c.DOB) > DAY(GETDATE())) 
                THEN 1 
                ELSE 0 
            END,
    r.BeginAge,
    r.EndAge,
    r.Rate AS BaseRate
FROM dbo.Customer AS c
JOIN RateDB.dbo.Rate AS r
    ON (
        DATEDIFF(YEAR, c.DOB, GETDATE()) 
        - CASE 
              WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                   OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                   AND DAY(c.DOB) > DAY(GETDATE())) 
              THEN 1 
              ELSE 0 
          END
       ) BETWEEN r.BeginAge AND r.EndAge
ORDER BY 
    r.BeginAge,      -- age range first
    c.LName,
    c.FName;
GO

/* ----------------------------------------------------------
   Routine 3: Customer Rate Report with Rider
   Purpose: Report all customers sorted by Age Range,
            LName, FName, showing Base Rate and
            Rider-adjusted rate (Rate x 1.5 when RiderFlag = 1).
-----------------------------------------------------------*/
USE CustomerDB;
GO

SELECT 
    c.CustomerID,
    c.FName,
    c.LName,
    c.DOB,
    -- Calculate age
    Age = DATEDIFF(YEAR, c.DOB, GETDATE()) 
          - CASE 
                WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                     OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                     AND DAY(c.DOB) > DAY(GETDATE())) 
                THEN 1 
                ELSE 0 
            END,
    AgeRange = CONCAT(r.BeginAge, '-', r.EndAge),
    r.Rate AS BaseRate,
    c.RiderFlag,
    -- Rider increases rate by 1.5 when RiderFlag = 1
    FinalRate = CASE 
                    WHEN c.RiderFlag = 1 THEN r.Rate * 1.5
                    ELSE r.Rate
                END
FROM dbo.Customer AS c
JOIN RateDB.dbo.Rate AS r
    ON (
        DATEDIFF(YEAR, c.DOB, GETDATE()) 
        - CASE 
              WHEN MONTH(c.DOB) > MONTH(GETDATE()) 
                   OR (MONTH(c.DOB) = MONTH(GETDATE()) 
                   AND DAY(c.DOB) > DAY(GETDATE())) 
              THEN 1 
              ELSE 0 
          END
       ) BETWEEN r.BeginAge AND r.EndAge
ORDER BY 
    r.BeginAge,      -- age range
    c.LName,         -- then last name
    c.FName;         -- then first name
GO




