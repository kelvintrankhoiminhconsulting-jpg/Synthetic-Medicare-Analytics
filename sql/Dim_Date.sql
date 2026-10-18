/*create dim_date */
/* =========================================================
   CREATE MEDICARE DATE DIMENSION
   Date range: 2007-11-27 through 2010-12-31
   ========================================================= */

DROP TABLE IF EXISTS dbo.Dim_Date;

CREATE TABLE dbo.Dim_Date
(
    Date_Key        int         NOT NULL PRIMARY KEY,
    Full_Date       date        NOT NULL,
    Year            int         NOT NULL,
    Quarter         int         NOT NULL,
    Quarter_Name    varchar(10) NOT NULL,
    Month_Number    int         NOT NULL,
    Month_Name      varchar(20) NOT NULL,
    Year_Month      char(7)     NOT NULL,
    Day_Number      int         NOT NULL,
    Day_Name        varchar(20) NOT NULL
);


/* =========================================================
   INSERT ONE ROW FOR EACH DATE
   ========================================================= */

DECLARE @StartDate date = '2007-11-27';
DECLARE @EndDate   date = '2010-12-31';

;WITH Date_CTE AS
(
    SELECT @StartDate AS Full_Date

    UNION ALL

    SELECT DATEADD(DAY, 1, Full_Date)
    FROM Date_CTE
    WHERE Full_Date < @EndDate
)
INSERT INTO dbo.Dim_Date
(
    Date_Key,
    Full_Date,
    Year,
    Quarter,
    Quarter_Name,
    Month_Number,
    Month_Name,
    Year_Month,
    Day_Number,
    Day_Name
)
SELECT
    CONVERT(int, CONVERT(char(8), Full_Date, 112)) AS Date_Key,
    Full_Date,
    YEAR(Full_Date) AS Year,
    DATEPART(QUARTER, Full_Date) AS Quarter,
    CONCAT('Q', DATEPART(QUARTER, Full_Date)) AS Quarter_Name,
    MONTH(Full_Date) AS Month_Number,
    DATENAME(MONTH, Full_Date) AS Month_Name,
    CONVERT(char(7), Full_Date, 120) AS Year_Month,
    DAY(Full_Date) AS Day_Number,
    DATENAME(WEEKDAY, Full_Date) AS Day_Name
FROM Date_CTE
OPTION (MAXRECURSION 0);


/* =========================================================
   VERIFY
   ========================================================= */

SELECT
    COUNT(*) AS Total_Dates,
    MIN(Full_Date) AS Minimum_Date,
    MAX(Full_Date) AS Maximum_Date
FROM dbo.Dim_Date;
/*
====================================================
look at the date dimension */
SELECT TOP 20
    Date_Key,
    Full_Date,
    Year,
    Quarter_Name,
    Month_Number,
    Month_Name,
    Year_Month,
    Day_Number,
    Day_Name
FROM dbo.Dim_Date
ORDER BY Full_Date;
/*====================================
validate date keys */
SELECT
    'Carrier' AS Table_Name,
    COUNT(*) AS Missing_Dates
FROM dbo.carrier_clean c
LEFT JOIN dbo.Dim_Date d
    ON c.CLM_FROM_DT = d.Full_Date
WHERE c.CLM_FROM_DT IS NOT NULL
  AND d.Full_Date IS NULL

UNION ALL

SELECT
    'Inpatient',
    COUNT(*)
FROM dbo.inpatient_clean i
LEFT JOIN dbo.Dim_Date d
    ON i.CLM_FROM_DT = d.Full_Date
WHERE i.CLM_FROM_DT IS NOT NULL
  AND d.Full_Date IS NULL

UNION ALL

SELECT
    'Outpatient',
    COUNT(*)
FROM dbo.outpatient_clean o
LEFT JOIN dbo.Dim_Date d
    ON o.CLM_FROM_DT = d.Full_Date
WHERE o.CLM_FROM_DT IS NOT NULL
  AND d.Full_Date IS NULL

UNION ALL

SELECT
    'PDE',
    COUNT(*)
FROM dbo.pde_clean p
LEFT JOIN dbo.Dim_Date d
    ON p.SRVC_DT = d.Full_Date
WHERE p.SRVC_DT IS NOT NULL
  AND d.Full_Date IS NULL;
/*===================================
validate beneficiary relationships */
SELECT
    'Carrier' AS Table_Name,
    COUNT(*) AS Orphan_Rows
FROM dbo.carrier_clean c
LEFT JOIN dbo.Dim_Beneficiary b
    ON c.DESYNPUF_ID = b.DESYNPUF_ID
WHERE b.DESYNPUF_ID IS NULL

UNION ALL

SELECT
    'Inpatient',
    COUNT(*)
FROM dbo.inpatient_clean i
LEFT JOIN dbo.Dim_Beneficiary b
    ON i.DESYNPUF_ID = b.DESYNPUF_ID
WHERE b.DESYNPUF_ID IS NULL

UNION ALL

SELECT
    'Outpatient',
    COUNT(*)
FROM dbo.outpatient_clean o
LEFT JOIN dbo.Dim_Beneficiary b
    ON o.DESYNPUF_ID = b.DESYNPUF_ID
WHERE b.DESYNPUF_ID IS NULL

UNION ALL

SELECT
    'PDE',
    COUNT(*)
FROM dbo.pde_clean p
LEFT JOIN dbo.Dim_Beneficiary b
    ON p.DESYNPUF_ID = b.DESYNPUF_ID
WHERE b.DESYNPUF_ID IS NULL;
/*================================================
*/