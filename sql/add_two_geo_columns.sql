
-- Add geographic columns if they do not already exist
IF COL_LENGTH('dbo.Dim_Beneficiary', 'SP_STATE_CODE') IS NULL
BEGIN
    ALTER TABLE dbo.Dim_Beneficiary
    ADD SP_STATE_CODE INT;
END;

IF COL_LENGTH('dbo.Dim_Beneficiary', 'BENE_COUNTY_CD') IS NULL
BEGIN
    ALTER TABLE dbo.Dim_Beneficiary
    ADD BENE_COUNTY_CD INT;
END;

-- Populate state and county codes
WITH Beneficiary_Geography AS
(
    SELECT
        DESYNPUF_ID,
        SP_STATE_CODE,
        BENE_COUNTY_CD,
        ROW_NUMBER() OVER (
            PARTITION BY DESYNPUF_ID
            ORDER BY BENEFICIARY_YEAR
        ) AS rn
    FROM dbo.beneficiary_clean
)
UPDATE d
SET
    d.SP_STATE_CODE = g.SP_STATE_CODE,
    d.BENE_COUNTY_CD = g.BENE_COUNTY_CD
FROM dbo.Dim_Beneficiary AS d
INNER JOIN Beneficiary_Geography AS g
    ON d.DESYNPUF_ID = g.DESYNPUF_ID
WHERE g.rn = 1;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'beneficiary_clean'
  AND COLUMN_NAME LIKE '%STATE%'
ORDER BY COLUMN_NAME;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Dim_Beneficiary'
ORDER BY ORDINAL_POSITION;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('beneficiary_clean', 'Dim_Beneficiary')
  AND (
      COLUMN_NAME LIKE '%STATE%'
      OR COLUMN_NAME LIKE '%COUNTY%'
      OR COLUMN_NAME = 'DESYNPUF_ID'
      OR COLUMN_NAME = 'BENEFICIARY_YEAR'
  )
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*===========ADD MISSING COLUMNS STATE CODE AND BENE COUNTY CD===*/
ALTER TABLE dbo.Dim_Beneficiary
ADD
    SP_STATE_CODE TINYINT NULL,
    BENE_COUNTY_CD SMALLINT NULL;
/* RUN UPDATE TABLE*/
WITH Beneficiary_Geography AS
(
    SELECT
        DESYNPUF_ID,
        SP_STATE_CODE,
        BENE_COUNTY_CD,
        ROW_NUMBER() OVER (
            PARTITION BY DESYNPUF_ID
            ORDER BY BENEFICIARY_YEAR
        ) AS rn
    FROM dbo.beneficiary_clean
)
UPDATE d
SET
    d.SP_STATE_CODE = g.SP_STATE_CODE,
    d.BENE_COUNTY_CD = g.BENE_COUNTY_CD
FROM dbo.Dim_Beneficiary AS d
INNER JOIN Beneficiary_Geography AS g
    ON d.DESYNPUF_ID = g.DESYNPUF_ID
WHERE g.rn = 1;

/*VERIFY TABLE*/
SELECT TOP 20
    DESYNPUF_ID,
    SP_STATE_CODE,
    BENE_COUNTY_CD
FROM dbo.Dim_Beneficiary;
/* ADD STATE NAME TO TABLE DIM BENEFICIARY*/
ALTER TABLE dbo.Dim_Beneficiary
ADD State_Name VARCHAR(50) NULL;
/*RUN AN UPDATE*/
UPDATE dbo.Dim_Beneficiary
SET State_Name =
    CASE SP_STATE_CODE
        WHEN 1  THEN 'Alabama'
        WHEN 2  THEN 'Alaska'
        WHEN 3  THEN 'Arizona'
        WHEN 4  THEN 'Arkansas'
        WHEN 5  THEN 'California'
        WHEN 6  THEN 'Colorado'
        WHEN 7  THEN 'Connecticut'
        WHEN 8  THEN 'Delaware'
        WHEN 9  THEN 'District of Columbia'
        WHEN 10 THEN 'Florida'
        WHEN 11 THEN 'Georgia'
        WHEN 12 THEN 'Hawaii'
        WHEN 13 THEN 'Idaho'
        WHEN 14 THEN 'Illinois'
        WHEN 15 THEN 'Indiana'
        WHEN 16 THEN 'Iowa'
        WHEN 17 THEN 'Kansas'
        WHEN 18 THEN 'Kentucky'
        WHEN 19 THEN 'Louisiana'
        WHEN 20 THEN 'Maine'
        WHEN 21 THEN 'Maryland'
        WHEN 22 THEN 'Massachusetts'
        WHEN 23 THEN 'Michigan'
        WHEN 24 THEN 'Minnesota'
        WHEN 25 THEN 'Mississippi'
        WHEN 26 THEN 'Missouri'
        WHEN 27 THEN 'Montana'
        WHEN 28 THEN 'Nebraska'
        WHEN 29 THEN 'Nevada'
        WHEN 30 THEN 'New Hampshire'
        WHEN 31 THEN 'New Jersey'
        WHEN 32 THEN 'New Mexico'
        WHEN 33 THEN 'New York'
        WHEN 34 THEN 'North Carolina'
        WHEN 35 THEN 'North Dakota'
        WHEN 36 THEN 'Ohio'
        WHEN 37 THEN 'Oklahoma'
        WHEN 38 THEN 'Oregon'
        WHEN 39 THEN 'Pennsylvania'
        WHEN 41 THEN 'Rhode Island'
        WHEN 42 THEN 'South Carolina'
        WHEN 43 THEN 'South Dakota'
        WHEN 44 THEN 'Tennessee'
        WHEN 45 THEN 'Texas'
        WHEN 46 THEN 'Utah'
        WHEN 47 THEN 'Vermont'
        WHEN 49 THEN 'Virginia'
        WHEN 50 THEN 'Washington'
        WHEN 51 THEN 'West Virginia'
        WHEN 52 THEN 'Wisconsin'
        WHEN 53 THEN 'Wyoming'
        ELSE NULL
    END;
    /* VERIFY RESULTS*/
SELECT
    SP_STATE_CODE,
    State_Name,
    COUNT(*) AS Beneficiary_Count
FROM dbo.Dim_Beneficiary
GROUP BY
    SP_STATE_CODE,
    State_Name
ORDER BY
    SP_STATE_CODE;

/* LABEL NULL AS PUERTO RICO AND VERIFY IT*/
UPDATE dbo.Dim_Beneficiary
SET State_Name = 'Puerto Rico'
WHERE SP_STATE_CODE = 54;

SELECT
    SP_STATE_CODE,
    State_Name,
    COUNT(*) AS Beneficiary_Count
FROM dbo.Dim_Beneficiary
GROUP BY
    SP_STATE_CODE,
    State_Name
ORDER BY
    SP_STATE_CODE;