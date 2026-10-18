USE Medicare_Analytics;
GO

SELECT
    name,
    create_date
FROM sys.tables
WHERE name = 'Carrier_clean';

SELECT
    SUM(row_count) AS Rows_Loaded
FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('dbo.Carrier_clean')
  AND index_id IN (0,1);

SELECT COUNT(*) AS Row_Count
FROM dbo.Carrier_clean;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_Claim_IDs
FROM dbo.Carrier_clean;

USE Medicare_Analytics;
GO

SELECT COUNT(*) AS Row_Count
FROM dbo.Inpatient_clean;

SELECT TOP 10 *
FROM dbo.Inpatient_clean;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(CLM_ID, '|', SEGMENT)) AS Unique_Claim_Segments
FROM dbo.Inpatient_clean;

USE Medicare_Analytics;
GO

SELECT COUNT(*) AS Row_Count
FROM dbo.Outpatient_clean;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segment_Keys
FROM dbo.Outpatient_clean;

USE Medicare_Analytics;
GO

SELECT COUNT(*) AS Row_Count
FROM dbo.PDE_clean;

SELECT TOP 10 *
FROM dbo.PDE_clean;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT PDE_ID) AS Unique_PDE_ID
FROM dbo.PDE_clean;
========================================================
USE Medicare_Analytics;
GO

/* ============================================================
   MEDICARE ANALYTICS
   MASTER SQL VALIDATION
   ============================================================ */


/* ============================================================
   1. ROW COUNTS
   ============================================================ */

SELECT
    'Beneficiary_clean' AS Table_Name,
    COUNT(*) AS Row_Count
FROM dbo.Beneficiary_clean

UNION ALL

SELECT
    'Carrier_clean',
    COUNT(*)
FROM dbo.Carrier_clean

UNION ALL

SELECT
    'Inpatient_clean',
    COUNT(*)
FROM dbo.Inpatient_clean

UNION ALL

SELECT
    'Outpatient_clean',
    COUNT(*)
FROM dbo.Outpatient_clean

UNION ALL

SELECT
    'PDE_clean',
    COUNT(*)
FROM dbo.PDE_clean;


/* ============================================================
   2. BENEFICIARY VALIDATION
   ============================================================ */

SELECT
    BENEFICIARY_YEAR,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Beneficiary_clean
GROUP BY BENEFICIARY_YEAR
ORDER BY BENEFICIARY_YEAR;


/* ============================================================
   3. CARRIER KEY VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_CLM_ID
FROM dbo.Carrier_clean;


/* ============================================================
   4. INPATIENT KEY VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_CLM_ID,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segment_Key
FROM dbo.Inpatient_clean;


/* ============================================================
   5. OUTPATIENT KEY VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_CLM_ID,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segment_Key
FROM dbo.Outpatient_clean;


/* ============================================================
   6. PDE KEY VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT PDE_ID) AS Unique_PDE_ID
FROM dbo.PDE_clean;


/* ============================================================
   7. CHECK FOR DUPLICATE CARRIER CLAIM IDs
   ============================================================ */

SELECT
    CLM_ID,
    COUNT(*) AS Row_Count
FROM dbo.Carrier_clean
GROUP BY CLM_ID
HAVING COUNT(*) > 1;


/* ============================================================
   8. CHECK FOR DUPLICATE INPATIENT
      CLAIM + SEGMENT
   ============================================================ */

SELECT
    CLM_ID,
    SEGMENT,
    COUNT(*) AS Row_Count
FROM dbo.Inpatient_clean
GROUP BY
    CLM_ID,
    SEGMENT
HAVING COUNT(*) > 1;


/* ============================================================
   9. CHECK FOR DUPLICATE OUTPATIENT
      CLAIM + SEGMENT
   ============================================================ */

SELECT
    CLM_ID,
    SEGMENT,
    COUNT(*) AS Row_Count
FROM dbo.Outpatient_clean
GROUP BY
    CLM_ID,
    SEGMENT
HAVING COUNT(*) > 1;


/* ============================================================
   10. CHECK FOR DUPLICATE PDE IDs
   ============================================================ */

SELECT
    PDE_ID,
    COUNT(*) AS Row_Count
FROM dbo.PDE_clean
GROUP BY PDE_ID
HAVING COUNT(*) > 1;

=======================================================================
/* Validate all five table row counts
*/
USE Medicare_Analytics;
GO

SELECT
    'Beneficiary_clean' AS Table_Name,
    COUNT(*) AS Row_Count
FROM dbo.Beneficiary_clean

UNION ALL

SELECT
    'Carrier_clean',
    COUNT(*)
FROM dbo.Carrier_clean

UNION ALL

SELECT
    'Inpatient_clean',
    COUNT(*)
FROM dbo.Inpatient_clean

UNION ALL

SELECT
    'Outpatient_clean',
    COUNT(*)
FROM dbo.Outpatient_clean

UNION ALL

SELECT
    'PDE_clean',
    COUNT(*)
FROM dbo.PDE_clean;

==============================================
/* Step 3 — Validate the primary/business keys
*/
USE Medicare_Analytics;
GO


/* ============================================================
   1. BENEFICIARY
   DESYNPUF_ID should be unique within each year
   ============================================================ */

SELECT
    BENEFICIARY_YEAR,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Beneficiary_clean
GROUP BY BENEFICIARY_YEAR
ORDER BY BENEFICIARY_YEAR;


/* ============================================================
   2. CARRIER
   CLM_ID should be unique
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_CLM_ID
FROM dbo.Carrier_clean;


/* ============================================================
   3. INPATIENT
   CLM_ID + SEGMENT should be unique
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segment_Key
FROM dbo.Inpatient_clean;


/* ============================================================
   4. OUTPATIENT
   CLM_ID + SEGMENT should be unique
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segment_Key
FROM dbo.Outpatient_clean;


/* ============================================================
   5. PRESCRIPTION DRUG EVENTS
   PDE_ID should be unique
   ============================================================ */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT PDE_ID) AS Unique_PDE_ID
FROM dbo.PDE_clean;
===========================================================
/* Step 4 — Validate Beneficiary → Claims relationships
*/
USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Inpatient_Rows,
    COUNT(DISTINCT i.DESYNPUF_ID) AS Inpatient_Beneficiaries,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Inpatient_clean i
LEFT JOIN dbo.Beneficiary_clean b
    ON i.DESYNPUF_ID = b.DESYNPUF_ID;
===================================================
/*Step 5 — Inpatient → Beneficiary
*/
USE Medicare_Analytics;
GO

SELECT
    COUNT(DISTINCT i.CLAIM_SEGMENT_KEY) AS Inpatient_Rows,
    COUNT(DISTINCT i.DESYNPUF_ID) AS Inpatient_Beneficiaries,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Inpatient_clean i
LEFT JOIN dbo.Beneficiary_clean b
    ON i.DESYNPUF_ID = b.DESYNPUF_ID;
===============================================================
/*Step 6 — Outpatient → Beneficiary
*/
USE Medicare_Analytics;
GO

SELECT
    COUNT(DISTINCT o.CLAIM_SEGMENT_KEY) AS Outpatient_Rows,
    COUNT(DISTINCT o.DESYNPUF_ID) AS Outpatient_Beneficiaries,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Outpatient_clean o
LEFT JOIN dbo.Beneficiary_clean b
    ON o.DESYNPUF_ID = b.DESYNPUF_ID;
=================================================================
/* Step 7 — PDE → Beneficiary
*/
USE Medicare_Analytics;
GO

SELECT
    COUNT(DISTINCT p.PDE_ID) AS PDE_Rows,
    COUNT(DISTINCT p.DESYNPUF_ID) AS PDE_Beneficiaries,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.PDE_clean p
LEFT JOIN dbo.Beneficiary_clean b
    ON p.DESYNPUF_ID = b.DESYNPUF_ID;
======================================================================
/* Step 8 — The Important Year-Level Check
Step 8A — Check Inpatient Year Matching
*/
USE Medicare_Analytics;
GO

SELECT
    YEAR(i.CLM_FROM_DT) AS Claim_Year,
    COUNT(DISTINCT i.CLAIM_SEGMENT_KEY) AS Inpatient_Claims,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Inpatient_clean i
INNER JOIN dbo.Beneficiary_clean b
    ON i.DESYNPUF_ID = b.DESYNPUF_ID
    AND YEAR(i.CLM_FROM_DT) = b.BENEFICIARY_YEAR
GROUP BY
    YEAR(i.CLM_FROM_DT)
ORDER BY
    Claim_Year;
======================================================
/* Step 8B — Carrier year matching
*/
USE Medicare_Analytics;
GO

SELECT
    YEAR(c.CLM_FROM_DT) AS Claim_Year,
    COUNT(DISTINCT c.CLM_ID) AS Carrier_Claims,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Carrier_clean c
INNER JOIN dbo.Beneficiary_clean b
    ON c.DESYNPUF_ID = b.DESYNPUF_ID
    AND YEAR(c.CLM_FROM_DT) = b.BENEFICIARY_YEAR
GROUP BY
    YEAR(c.CLM_FROM_DT)
ORDER BY
    Claim_Year;
============================================================
/*  Outpatient year matching
*/
USE Medicare_Analytics;
GO

SELECT
    YEAR(o.CLM_FROM_DT) AS Claim_Year,
    COUNT(DISTINCT o.CLAIM_SEGMENT_KEY) AS Outpatient_Claims,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.Outpatient_clean o
INNER JOIN dbo.Beneficiary_clean b
    ON o.DESYNPUF_ID = b.DESYNPUF_ID
    AND YEAR(o.CLM_FROM_DT) = b.BENEFICIARY_YEAR
GROUP BY
    YEAR(o.CLM_FROM_DT)
ORDER BY
    Claim_Year;
============================================
/*One last year-level check: PDE
*/
USE Medicare_Analytics;
GO

SELECT
    YEAR(p.SRVC_DT) AS Service_Year,
    COUNT(DISTINCT p.PDE_ID) AS PDE_Events,
    COUNT(DISTINCT b.DESYNPUF_ID) AS Matching_Beneficiaries
FROM dbo.PDE_clean p
INNER JOIN dbo.Beneficiary_clean b
    ON p.DESYNPUF_ID = b.DESYNPUF_ID
    AND YEAR(p.SRVC_DT) = b.BENEFICIARY_YEAR
GROUP BY
    YEAR(p.SRVC_DT)
ORDER BY
    Service_Year;
========================================================================
/* Step 9A — Create Dim_Beneficiary */
USE Medicare_Analytics;
GO

/* ============================================================
   CREATE BENEFICIARY DIMENSION
   One row per unique beneficiary
   ============================================================ */

IF OBJECT_ID('dbo.Dim_Beneficiary', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Beneficiary;
GO

SELECT DISTINCT
    DESYNPUF_ID
INTO dbo.Dim_Beneficiary
FROM dbo.Beneficiary_clean;
GO

/* Add primary key */
ALTER TABLE dbo.Dim_Beneficiary
ADD CONSTRAINT PK_Dim_Beneficiary
PRIMARY KEY (DESYNPUF_ID);
GO

/* Validate */
SELECT
    COUNT(*) AS Beneficiary_Count
FROM dbo.Dim_Beneficiary;
GO
===================================================
/* Step 9B — Create Beneficiary_Year
*/
USE Medicare_Analytics;
GO

/* ============================================================
   CREATE BENEFICIARY YEAR SNAPSHOT
   One row per beneficiary per year
   ============================================================ */

IF OBJECT_ID('dbo.Beneficiary_Year', 'U') IS NOT NULL
    DROP TABLE dbo.Beneficiary_Year;
GO

SELECT
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    BENE_BIRTH_DT,
    BENE_DEATH_DT,
    BENE_SEX_IDENT_CD,
    BENE_RACE_CD,
    BENE_ESRD_IND,
    SP_STATE_CODE,
    BENE_COUNTY_CD,
    BENE_HI_CVRAGE_TOT_MONS,
    BENE_SMI_CVRAGE_TOT_MONS,
    BENE_HMO_CVRAGE_TOT_MONS,
    PLAN_CVRG_MOS_NUM,

    /* Chronic condition indicators */
    SP_ALZHDMTA,
    SP_CHF,
    SP_CHRNKIDN,
    SP_CNCR,
    SP_COPD,
    SP_DEPRESSN,
    SP_DIABETES,
    SP_ISCHMCHT,
    SP_OSTEOPRS,
    SP_RA_OA,
    SP_STRKETIA,

    /* Annual reimbursement/payment fields */
    MEDREIMB_IP,
    BENRES_IP,
    PPPYMT_IP,

    MEDREIMB_OP,
    BENRES_OP,
    PPPYMT_OP,

    MEDREIMB_CAR,
    BENRES_CAR,
    PPPYMT_CAR

INTO dbo.Beneficiary_Year
FROM dbo.Beneficiary_clean;
GO

/* Add composite primary key */
ALTER TABLE dbo.Beneficiary_Year
ADD CONSTRAINT PK_Beneficiary_Year
PRIMARY KEY (
    DESYNPUF_ID,
    BENEFICIARY_YEAR
);
GO
==============================================
/* Step 9C — Validate the new table
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Beneficiary_Year
GROUP BY BENEFICIARY_YEAR
ORDER BY BENEFICIARY_YEAR;
=============================================================
/* Step 10 — Validate the new relational tables
*/
USE Medicare_Analytics;
GO


/* ============================================================
   1. DIM_BENEFICIARY
   One row per unique person
   ============================================================ */

SELECT
    COUNT(*) AS Total_Beneficiaries,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Dim_Beneficiary;


/* ============================================================
   2. BENEFICIARY_YEAR
   One row per person per year
   ============================================================ */

SELECT
    COUNT(*) AS Total_Beneficiary_Year_Rows,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries,
    COUNT(DISTINCT BENEFICIARY_YEAR) AS Number_of_Years
FROM dbo.Beneficiary_Year;


/* ============================================================
   3. CHECK FOR DUPLICATE PERSON + YEAR
   Should return ZERO rows
   ============================================================ */

SELECT
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    COUNT(*) AS Row_Count
FROM dbo.Beneficiary_Year
GROUP BY
    DESYNPUF_ID,
    BENEFICIARY_YEAR
HAVING COUNT(*) > 1;
===========================================================
/* Step 10 — Create indexes for the SQL model
*/
USE Medicare_Analytics;
GO

-- ============================================================
-- STEP 10: CREATE PERFORMANCE INDEXES
-- ============================================================

-- 1. Beneficiary dimension
CREATE INDEX IX_Dim_Beneficiary_ID
ON dbo.Dim_Beneficiary (DESYNPUF_ID);


-- 2. Beneficiary annual records
CREATE INDEX IX_Beneficiary_Year_ID_Year
ON dbo.Beneficiary_Year (DESYNPUF_ID, BENEFICIARY_YEAR);


-- 3. Carrier claims
CREATE INDEX IX_Carrier_Beneficiary
ON dbo.Carrier_clean (DESYNPUF_ID);

CREATE INDEX IX_Carrier_Claim_Date
ON dbo.Carrier_clean (CLM_FROM_DT);


-- 4. Inpatient claims
CREATE INDEX IX_Inpatient_Beneficiary
ON dbo.Inpatient_clean (DESYNPUF_ID);

CREATE INDEX IX_Inpatient_Claim_Date
ON dbo.Inpatient_clean (CLM_FROM_DT);


-- 5. Outpatient claims
CREATE INDEX IX_Outpatient_Beneficiary
ON dbo.Outpatient_clean (DESYNPUF_ID);

CREATE INDEX IX_Outpatient_Claim_Date
ON dbo.Outpatient_clean (CLM_FROM_DT);


-- 6. Prescription Drug Events
CREATE INDEX IX_PDE_Beneficiary
ON dbo.PDE_clean (DESYNPUF_ID);

CREATE INDEX IX_PDE_Service_Date
ON dbo.PDE_clean (SRVC_DT);
GO
==========================================================
/* Step 11 — Add year information to the claim tables
11A — Create the Carrier view
*/
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_Carrier
AS
SELECT
    *,
    YEAR(CLM_FROM_DT) AS CLAIM_YEAR
FROM dbo.Carrier_clean;
GO
============================================================
/* 11B — Create the Inpatient view
*/
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_Inpatient
AS
SELECT
    *,
    YEAR(CLM_FROM_DT) AS CLAIM_YEAR
FROM dbo.Inpatient_clean;
GO
===============================================
/* 11C — Create the Outpatient view
*/
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_Outpatient
AS
SELECT
    *,
    YEAR(CLM_FROM_DT) AS CLAIM_YEAR
FROM dbo.Outpatient_clean;
GO
=============================================================
/*11D — Create the PDE view */
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_PDE
AS
SELECT
    *,
    YEAR(SRVC_DT) AS SERVICE_YEAR
FROM dbo.PDE_clean;
GO
======================================================
/* Step 12 — Validate the claim/service years
*/
USE Medicare_Analytics;
GO

-- ============================================================
-- STEP 12: VALIDATE CLAIM / SERVICE YEARS
-- ============================================================

-- 1. Carrier
SELECT
    CLAIM_YEAR,
    COUNT(*) AS Claim_Count
FROM dbo.vw_Carrier
GROUP BY CLAIM_YEAR
ORDER BY CLAIM_YEAR;


-- 2. Inpatient
SELECT
    CLAIM_YEAR,
    COUNT(*) AS Claim_Segment_Count
FROM dbo.vw_Inpatient
GROUP BY CLAIM_YEAR
ORDER BY CLAIM_YEAR;


-- 3. Outpatient
SELECT
    CLAIM_YEAR,
    COUNT(*) AS Claim_Segment_Count
FROM dbo.vw_Outpatient
GROUP BY CLAIM_YEAR
ORDER BY CLAIM_YEAR;


-- 4. Prescription Drug Events
SELECT
    SERVICE_YEAR,
    COUNT(*) AS Prescription_Event_Count
FROM dbo.vw_PDE
GROUP BY SERVICE_YEAR
ORDER BY SERVICE_YEAR;
=========================================================
/* CREATE A VIEW THAT EXPOSES THE BENEFICIARY YEAR INFORMATION CLEANLY */
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_Beneficiary_Year
AS
SELECT
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    BENE_BIRTH_DT,
    BENE_DEATH_DT,
    BENE_SEX_IDENT_CD,
    BENE_RACE_CD,
    BENE_ESRD_IND,
    SP_STATE_CODE,
    BENE_COUNTY_CD,
    BENE_HI_CVRAGE_TOT_MONS,
    BENE_SMI_CVRAGE_TOT_MONS,
    BENE_HMO_CVRAGE_TOT_MONS,
    PLAN_CVRG_MOS_NUM,

    -- Chronic condition indicators
    SP_ALZHDMTA,
    SP_CHF,
    SP_CHRNKIDN,
    SP_CNCR,
    SP_COPD,
    SP_DEPRESSN,
    SP_DIABETES,
    SP_ISCHMCHT,
    SP_OSTEOPRS,
    SP_RA_OA,
    SP_STRKETIA,

    -- Medicare reimbursement/payment fields
    MEDREIMB_IP,
    BENRES_IP,
    PPPYMT_IP,
    MEDREIMB_OP,
    BENRES_OP,
    PPPYMT_OP,
    MEDREIMB_CAR,
    BENRES_CAR,
    PPPYMT_CAR

FROM dbo.Beneficiary_Year;
GO
=======================================================
/* Step 14 — Validate the beneficiary-year analytical view
*/

USE Medicare_Analytics;
GO

-- ============================================================
-- STEP 14: VALIDATE vw_Beneficiary_Year
-- ============================================================

-- 1. Total row count
SELECT
    COUNT(*) AS Total_Rows
FROM dbo.vw_Beneficiary_Year;


-- 2. Beneficiary count
SELECT
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.vw_Beneficiary_Year;


-- 3. Beneficiary-year combinations
SELECT
    COUNT(*) AS Unique_Beneficiary_Year_Rows
FROM
(
    SELECT DISTINCT
        DESYNPUF_ID,
        BENEFICIARY_YEAR
    FROM dbo.vw_Beneficiary_Year
) AS x;


-- 4. Records by year
SELECT
    BENEFICIARY_YEAR,
    COUNT(*) AS Beneficiary_Count,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.vw_Beneficiary_Year
GROUP BY BENEFICIARY_YEAR
ORDER BY BENEFICIARY_YEAR;


-- 5. Check for duplicate beneficiary-year combinations
SELECT
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    COUNT(*) AS Row_Count
FROM dbo.vw_Beneficiary_Year
GROUP BY
    DESYNPUF_ID,
    BENEFICIARY_YEAR
HAVING COUNT(*) > 1;
===============================================================
/* Step 15 — Build the Carrier claims analytical view
*/
/*get column names 8?*/
USE Medicare_Analytics;
GO

SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Carrier_clean'
ORDER BY ORDINAL_POSITION;
=============================================================
/* Step 15A — Replace the incorrect Carrier view
*/

USE Medicare_Analytics;
GO

-- ============================================================
-- STEP 15A: CREATE CORRECTED CARRIER ANALYTICAL VIEW
-- ============================================================

CREATE VIEW dbo.vw_Carrier_Analysis
AS
SELECT
    DESYNPUF_ID,
    CLM_ID,
    CLAIM_YEAR,

    -- Claim dates
    CLM_FROM_DT,
    CLM_THRU_DT,

    -- Diagnosis codes
    ICD9_DGNS_CD_1,
    ICD9_DGNS_CD_2,
    ICD9_DGNS_CD_3,
    ICD9_DGNS_CD_4,
    ICD9_DGNS_CD_5,
    ICD9_DGNS_CD_6,
    ICD9_DGNS_CD_7,
    ICD9_DGNS_CD_8,

    -- Provider NPI
    PRF_PHYSN_NPI_1,
    PRF_PHYSN_NPI_2,
    PRF_PHYSN_NPI_3,
    PRF_PHYSN_NPI_4,
    PRF_PHYSN_NPI_5,
    PRF_PHYSN_NPI_6,
    PRF_PHYSN_NPI_7,
    PRF_PHYSN_NPI_8,
    PRF_PHYSN_NPI_9,
    PRF_PHYSN_NPI_10,
    PRF_PHYSN_NPI_11,
    PRF_PHYSN_NPI_12,
    PRF_PHYSN_NPI_13,

    -- Tax identification numbers
    TAX_NUM_1,
    TAX_NUM_2,
    TAX_NUM_3,
    TAX_NUM_4,
    TAX_NUM_5,
    TAX_NUM_6,
    TAX_NUM_7,
    TAX_NUM_8,
    TAX_NUM_9,
    TAX_NUM_10,
    TAX_NUM_11,
    TAX_NUM_12,
    TAX_NUM_13,

    -- HCPCS procedure/service codes
    HCPCS_CD_1,
    HCPCS_CD_2,
    HCPCS_CD_3,
    HCPCS_CD_4,
    HCPCS_CD_5,
    HCPCS_CD_6,
    HCPCS_CD_7,
    HCPCS_CD_8,
    HCPCS_CD_9,
    HCPCS_CD_10,
    HCPCS_CD_11,
    HCPCS_CD_12,
    HCPCS_CD_13,

    -- Medicare payment amounts
    LINE_NCH_PMT_AMT_1,
    LINE_NCH_PMT_AMT_2,
    LINE_NCH_PMT_AMT_3,
    LINE_NCH_PMT_AMT_4,
    LINE_NCH_PMT_AMT_5,
    LINE_NCH_PMT_AMT_6,
    LINE_NCH_PMT_AMT_7,
    LINE_NCH_PMT_AMT_8,
    LINE_NCH_PMT_AMT_9,
    LINE_NCH_PMT_AMT_10,
    LINE_NCH_PMT_AMT_11,
    LINE_NCH_PMT_AMT_12,
    LINE_NCH_PMT_AMT_13,

    -- Beneficiary deductible amounts
    LINE_BENE_PTB_DDCTBL_AMT_1,
    LINE_BENE_PTB_DDCTBL_AMT_2,
    LINE_BENE_PTB_DDCTBL_AMT_3,
    LINE_BENE_PTB_DDCTBL_AMT_4,
    LINE_BENE_PTB_DDCTBL_AMT_5,
    LINE_BENE_PTB_DDCTBL_AMT_6,
    LINE_BENE_PTB_DDCTBL_AMT_7,
    LINE_BENE_PTB_DDCTBL_AMT_8,
    LINE_BENE_PTB_DDCTBL_AMT_9,
    LINE_BENE_PTB_DDCTBL_AMT_10,
    LINE_BENE_PTB_DDCTBL_AMT_11,
    LINE_BENE_PTB_DDCTBL_AMT_12,
    LINE_BENE_PTB_DDCTBL_AMT_13,

    -- Primary payer payments
    LINE_BENE_PRMRY_PYR_PD_AMT_1,
    LINE_BENE_PRMRY_PYR_PD_AMT_2,
    LINE_BENE_PRMRY_PYR_PD_AMT_3,
    LINE_BENE_PRMRY_PYR_PD_AMT_4,
    LINE_BENE_PRMRY_PYR_PD_AMT_5,
    LINE_BENE_PRMRY_PYR_PD_AMT_6,
    LINE_BENE_PRMRY_PYR_PD_AMT_7,
    LINE_BENE_PRMRY_PYR_PD_AMT_8,
    LINE_BENE_PRMRY_PYR_PD_AMT_9,
    LINE_BENE_PRMRY_PYR_PD_AMT_10,
    LINE_BENE_PRMRY_PYR_PD_AMT_11,
    LINE_BENE_PRMRY_PYR_PD_AMT_12,
    LINE_BENE_PRMRY_PYR_PD_AMT_13,

    -- Coinsurance amounts
    LINE_COINSRNC_AMT_1,
    LINE_COINSRNC_AMT_2,
    LINE_COINSRNC_AMT_3,
    LINE_COINSRNC_AMT_4,
    LINE_COINSRNC_AMT_5,
    LINE_COINSRNC_AMT_6,
    LINE_COINSRNC_AMT_7,
    LINE_COINSRNC_AMT_8,
    LINE_COINSRNC_AMT_9,
    LINE_COINSRNC_AMT_10,
    LINE_COINSRNC_AMT_11,
    LINE_COINSRNC_AMT_12,
    LINE_COINSRNC_AMT_13,

    -- Allowed charges
    LINE_ALOWD_CHRG_AMT_1,
    LINE_ALOWD_CHRG_AMT_2,
    LINE_ALOWD_CHRG_AMT_3,
    LINE_ALOWD_CHRG_AMT_4,
    LINE_ALOWD_CHRG_AMT_5,
    LINE_ALOWD_CHRG_AMT_6,
    LINE_ALOWD_CHRG_AMT_7,
    LINE_ALOWD_CHRG_AMT_8,
    LINE_ALOWD_CHRG_AMT_9,
    LINE_ALOWD_CHRG_AMT_10,
    LINE_ALOWD_CHRG_AMT_11,
    LINE_ALOWD_CHRG_AMT_12,
    LINE_ALOWD_CHRG_AMT_13,

    -- Processing indicators
    LINE_PRCSG_IND_CD_1,
    LINE_PRCSG_IND_CD_2,
    LINE_PRCSG_IND_CD_3,
    LINE_PRCSG_IND_CD_4,
    LINE_PRCSG_IND_CD_5,
    LINE_PRCSG_IND_CD_6,
    LINE_PRCSG_IND_CD_7,
    LINE_PRCSG_IND_CD_8,
    LINE_PRCSG_IND_CD_9,
    LINE_PRCSG_IND_CD_10,
    LINE_PRCSG_IND_CD_11,
    LINE_PRCSG_IND_CD_12,
    LINE_PRCSG_IND_CD_13,

    -- Line-level diagnosis codes
    LINE_ICD9_DGNS_CD_1,
    LINE_ICD9_DGNS_CD_2,
    LINE_ICD9_DGNS_CD_3,
    LINE_ICD9_DGNS_CD_4,
    LINE_ICD9_DGNS_CD_5,
    LINE_ICD9_DGNS_CD_6,
    LINE_ICD9_DGNS_CD_7,
    LINE_ICD9_DGNS_CD_8,
    LINE_ICD9_DGNS_CD_9,
    LINE_ICD9_DGNS_CD_10,
    LINE_ICD9_DGNS_CD_11,
    LINE_ICD9_DGNS_CD_12,
    LINE_ICD9_DGNS_CD_13,

    CARRIER_SOURCE

FROM dbo.vw_Carrier;
GO
======================================
/* Step 15B — Validate the Carrier analytical view
*/

USE Medicare_Analytics;
GO

-- ============================================================
-- STEP 15B: VALIDATE CARRIER ANALYTICAL VIEW
-- ============================================================

-- 1. Total rows
SELECT
    COUNT(*) AS Total_Rows
FROM dbo.vw_Carrier_Analysis;


-- 2. Unique claims
SELECT
    COUNT(DISTINCT CLM_ID) AS Unique_Claims
FROM dbo.vw_Carrier_Analysis;


-- 3. Unique beneficiaries
SELECT
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.vw_Carrier_Analysis;


-- 4. Claims by year
SELECT
    CLAIM_YEAR,
    COUNT(*) AS Claim_Count,
    COUNT(DISTINCT DESYNPUF_ID) AS Beneficiary_Count
FROM dbo.vw_Carrier_Analysis
GROUP BY CLAIM_YEAR
ORDER BY CLAIM_YEAR;


-- 5. Check for duplicate claim IDs
SELECT
    CLM_ID,
    COUNT(*) AS Row_Count
FROM dbo.vw_Carrier_Analysis
GROUP BY CLM_ID
HAVING COUNT(*) > 1;
=================================================
/* Step 16 — Create Carrier claim-level payment metrics
*/
USE Medicare_Analytics;
GO

CREATE VIEW dbo.vw_Carrier_Claim_Analysis
AS
SELECT
    DESYNPUF_ID,
    CLM_ID,
    CLAIM_YEAR,
    CLM_FROM_DT,
    CLM_THRU_DT,
    CARRIER_SOURCE,

    -- ========================================================
    -- TOTAL MEDICARE PAYMENT
    -- ========================================================
    COALESCE(LINE_NCH_PMT_AMT_1, 0)
    + COALESCE(LINE_NCH_PMT_AMT_2, 0)
    + COALESCE(LINE_NCH_PMT_AMT_3, 0)
    + COALESCE(LINE_NCH_PMT_AMT_4, 0)
    + COALESCE(LINE_NCH_PMT_AMT_5, 0)
    + COALESCE(LINE_NCH_PMT_AMT_6, 0)
    + COALESCE(LINE_NCH_PMT_AMT_7, 0)
    + COALESCE(LINE_NCH_PMT_AMT_8, 0)
    + COALESCE(LINE_NCH_PMT_AMT_9, 0)
    + COALESCE(LINE_NCH_PMT_AMT_10, 0)
    + COALESCE(LINE_NCH_PMT_AMT_11, 0)
    + COALESCE(LINE_NCH_PMT_AMT_12, 0)
    + COALESCE(LINE_NCH_PMT_AMT_13, 0)
    AS TOTAL_MEDICARE_PAYMENT,

    -- ========================================================
    -- TOTAL ALLOWED CHARGES
    -- ========================================================
    COALESCE(LINE_ALOWD_CHRG_AMT_1, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_2, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_3, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_4, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_5, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_6, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_7, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_8, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_9, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_10, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_11, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_12, 0)
    + COALESCE(LINE_ALOWD_CHRG_AMT_13, 0)
    AS TOTAL_ALLOWED_CHARGES,

    -- ========================================================
    -- TOTAL BENEFICIARY DEDUCTIBLE
    -- ========================================================
    COALESCE(LINE_BENE_PTB_DDCTBL_AMT_1, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_2, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_3, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_4, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_5, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_6, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_7, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_8, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_9, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_10, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_11, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_12, 0)
    + COALESCE(LINE_BENE_PTB_DDCTBL_AMT_13, 0)
    AS TOTAL_BENEFICIARY_DEDUCTIBLE,

    -- ========================================================
    -- TOTAL PRIMARY PAYER PAYMENT
    -- ========================================================
    COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_1, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_2, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_3, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_4, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_5, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_6, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_7, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_8, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_9, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_10, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_11, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_12, 0)
    + COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_13, 0)
    AS TOTAL_PRIMARY_PAYER_PAYMENT,

    -- ========================================================
    -- TOTAL COINSURANCE
    -- ========================================================
    COALESCE(LINE_COINSRNC_AMT_1, 0)
    + COALESCE(LINE_COINSRNC_AMT_2, 0)
    + COALESCE(LINE_COINSRNC_AMT_3, 0)
    + COALESCE(LINE_COINSRNC_AMT_4, 0)
    + COALESCE(LINE_COINSRNC_AMT_5, 0)
    + COALESCE(LINE_COINSRNC_AMT_6, 0)
    + COALESCE(LINE_COINSRNC_AMT_7, 0)
    + COALESCE(LINE_COINSRNC_AMT_8, 0)
    + COALESCE(LINE_COINSRNC_AMT_9, 0)
    + COALESCE(LINE_COINSRNC_AMT_10, 0)
    + COALESCE(LINE_COINSRNC_AMT_11, 0)
    + COALESCE(LINE_COINSRNC_AMT_12, 0)
    + COALESCE(LINE_COINSRNC_AMT_13, 0)
    AS TOTAL_COINSURANCE,

    -- ========================================================
    -- NUMBER OF SERVICE LINES WITH A HCPCS CODE
    -- ========================================================
    (
        CASE WHEN HCPCS_CD_1 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_2 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_3 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_4 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_5 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_6 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_7 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_8 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_9 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_10 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_11 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_12 IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN HCPCS_CD_13 IS NOT NULL THEN 1 ELSE 0 END
    ) AS SERVICE_LINE_COUNT

FROM dbo.vw_Carrier_Analysis;
GO
============================================
/* Step 17 — Validate the Carrier Claim Analysis View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Carrier_Service_Line_Analysis
AS

SELECT
    C.DESYNPUF_ID,
    C.CLM_ID,
    C.CLAIM_YEAR,
    C.CLM_FROM_DT,
    C.CLM_THRU_DT,
    C.CARRIER_SOURCE,

    V.SERVICE_LINE_NUMBER,
    V.HCPCS_CODE,
    V.LINE_NCH_PMT_AMT,
    V.LINE_BENE_PTB_DDCTBL_AMT,
    V.LINE_BENE_PRMRY_PYR_PD_AMT,
    V.LINE_COINSRNC_AMT,
    V.LINE_ALOWD_CHRG_AMT,
    V.LINE_PRCSG_IND_CD,
    V.LINE_ICD9_DGNS_CD,

    CASE
        WHEN V.HCPCS_CODE IS NOT NULL THEN 1
        ELSE 0
    END AS HAS_HCPCS_CODE

FROM dbo.vw_Carrier_Analysis AS C

CROSS APPLY
(
    VALUES
        (
            1,
            C.HCPCS_CD_1,
            C.LINE_NCH_PMT_AMT_1,
            C.LINE_BENE_PTB_DDCTBL_AMT_1,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_1,
            C.LINE_COINSRNC_AMT_1,
            C.LINE_ALOWD_CHRG_AMT_1,
            C.LINE_PRCSG_IND_CD_1,
            C.LINE_ICD9_DGNS_CD_1
        ),
        (
            2,
            C.HCPCS_CD_2,
            C.LINE_NCH_PMT_AMT_2,
            C.LINE_BENE_PTB_DDCTBL_AMT_2,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_2,
            C.LINE_COINSRNC_AMT_2,
            C.LINE_ALOWD_CHRG_AMT_2,
            C.LINE_PRCSG_IND_CD_2,
            C.LINE_ICD9_DGNS_CD_2
        ),
        (
            3,
            C.HCPCS_CD_3,
            C.LINE_NCH_PMT_AMT_3,
            C.LINE_BENE_PTB_DDCTBL_AMT_3,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_3,
            C.LINE_COINSRNC_AMT_3,
            C.LINE_ALOWD_CHRG_AMT_3,
            C.LINE_PRCSG_IND_CD_3,
            C.LINE_ICD9_DGNS_CD_3
        ),
        (
            4,
            C.HCPCS_CD_4,
            C.LINE_NCH_PMT_AMT_4,
            C.LINE_BENE_PTB_DDCTBL_AMT_4,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_4,
            C.LINE_COINSRNC_AMT_4,
            C.LINE_ALOWD_CHRG_AMT_4,
            C.LINE_PRCSG_IND_CD_4,
            C.LINE_ICD9_DGNS_CD_4
        ),
        (
            5,
            C.HCPCS_CD_5,
            C.LINE_NCH_PMT_AMT_5,
            C.LINE_BENE_PTB_DDCTBL_AMT_5,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_5,
            C.LINE_COINSRNC_AMT_5,
            C.LINE_ALOWD_CHRG_AMT_5,
            C.LINE_PRCSG_IND_CD_5,
            C.LINE_ICD9_DGNS_CD_5
        ),
        (
            6,
            C.HCPCS_CD_6,
            C.LINE_NCH_PMT_AMT_6,
            C.LINE_BENE_PTB_DDCTBL_AMT_6,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_6,
            C.LINE_COINSRNC_AMT_6,
            C.LINE_ALOWD_CHRG_AMT_6,
            C.LINE_PRCSG_IND_CD_6,
            C.LINE_ICD9_DGNS_CD_6
        ),
        (
            7,
            C.HCPCS_CD_7,
            C.LINE_NCH_PMT_AMT_7,
            C.LINE_BENE_PTB_DDCTBL_AMT_7,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_7,
            C.LINE_COINSRNC_AMT_7,
            C.LINE_ALOWD_CHRG_AMT_7,
            C.LINE_PRCSG_IND_CD_7,
            C.LINE_ICD9_DGNS_CD_7
        ),
        (
            8,
            C.HCPCS_CD_8,
            C.LINE_NCH_PMT_AMT_8,
            C.LINE_BENE_PTB_DDCTBL_AMT_8,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_8,
            C.LINE_COINSRNC_AMT_8,
            C.LINE_ALOWD_CHRG_AMT_8,
            C.LINE_PRCSG_IND_CD_8,
            C.LINE_ICD9_DGNS_CD_8
        ),
        (
            9,
            C.HCPCS_CD_9,
            C.LINE_NCH_PMT_AMT_9,
            C.LINE_BENE_PTB_DDCTBL_AMT_9,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_9,
            C.LINE_COINSRNC_AMT_9,
            C.LINE_ALOWD_CHRG_AMT_9,
            C.LINE_PRCSG_IND_CD_9,
            C.LINE_ICD9_DGNS_CD_9
        ),
        (
            10,
            C.HCPCS_CD_10,
            C.LINE_NCH_PMT_AMT_10,
            C.LINE_BENE_PTB_DDCTBL_AMT_10,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_10,
            C.LINE_COINSRNC_AMT_10,
            C.LINE_ALOWD_CHRG_AMT_10,
            C.LINE_PRCSG_IND_CD_10,
            C.LINE_ICD9_DGNS_CD_10
        ),
        (
            11,
            C.HCPCS_CD_11,
            C.LINE_NCH_PMT_AMT_11,
            C.LINE_BENE_PTB_DDCTBL_AMT_11,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_11,
            C.LINE_COINSRNC_AMT_11,
            C.LINE_ALOWD_CHRG_AMT_11,
            C.LINE_PRCSG_IND_CD_11,
            C.LINE_ICD9_DGNS_CD_11
        ),
        (
            12,
            C.HCPCS_CD_12,
            C.LINE_NCH_PMT_AMT_12,
            C.LINE_BENE_PTB_DDCTBL_AMT_12,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_12,
            C.LINE_COINSRNC_AMT_12,
            C.LINE_ALOWD_CHRG_AMT_12,
            C.LINE_PRCSG_IND_CD_12,
            C.LINE_ICD9_DGNS_CD_12
        ),
        (
            13,
            C.HCPCS_CD_13,
            C.LINE_NCH_PMT_AMT_13,
            C.LINE_BENE_PTB_DDCTBL_AMT_13,
            C.LINE_BENE_PRMRY_PYR_PD_AMT_13,
            C.LINE_COINSRNC_AMT_13,
            C.LINE_ALOWD_CHRG_AMT_13,
            C.LINE_PRCSG_IND_CD_13,
            C.LINE_ICD9_DGNS_CD_13
        )

) AS V
(
    SERVICE_LINE_NUMBER,
    HCPCS_CODE,
    LINE_NCH_PMT_AMT,
    LINE_BENE_PTB_DDCTBL_AMT,
    LINE_BENE_PRMRY_PYR_PD_AMT,
    LINE_COINSRNC_AMT,
    LINE_ALOWD_CHRG_AMT,
    LINE_PRCSG_IND_CD,
    LINE_ICD9_DGNS_CD
);

GO
=======================================================
/*  Step 19 — Validate Service-Line View
*/

USE Medicare_Analytics;
GO

SELECT TOP 20
    CLM_ID,
    DESYNPUF_ID,
    CLAIM_YEAR,
    SERVICE_LINE_NUMBER,
    HCPCS_CODE,
    LINE_NCH_PMT_AMT,
    LINE_ALOWD_CHRG_AMT,
    HAS_HCPCS_CODE
FROM dbo.vw_Carrier_Service_Line_Analysis
ORDER BY CLM_ID, SERVICE_LINE_NUMBER;
GO

=========================================================
/* Step 20 — Make a More Useful Service-Line View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Carrier_Service_Lines
AS

SELECT
    DESYNPUF_ID,
    CLM_ID,
    CLAIM_YEAR,
    CLM_FROM_DT,
    CLM_THRU_DT,
    CARRIER_SOURCE,
    SERVICE_LINE_NUMBER,
    HCPCS_CODE,
    LINE_NCH_PMT_AMT,
    LINE_BENE_PTB_DDCTBL_AMT,
    LINE_BENE_PRMRY_PYR_PD_AMT,
    LINE_COINSRNC_AMT,
    LINE_ALOWD_CHRG_AMT,
    LINE_PRCSG_IND_CD,
    LINE_ICD9_DGNS_CD
FROM dbo.vw_Carrier_Service_Line_Analysis
WHERE HCPCS_CODE IS NOT NULL;

GO

==================================================================
/* Step 21 — Move to Inpatient Analysis
*/
USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Inpatient_Analysis
AS

SELECT
    DESYNPUF_ID,
    CLM_ID,
    SEGMENT,
    CLAIM_SEGMENT_KEY,

    CLAIM_YEAR,

    CLM_FROM_DT,
    CLM_THRU_DT,
    CLM_ADMSN_DT,
    NCH_BENE_DSCHRG_DT,

    CASE
        WHEN CLM_FROM_DT IS NOT NULL
         AND CLM_THRU_DT IS NOT NULL
        THEN DATEDIFF(DAY, CLM_FROM_DT, CLM_THRU_DT) + 1
        ELSE NULL
    END AS CLAIM_LENGTH_DAYS,

    CLM_PMT_AMT,

    CASE
        WHEN CLM_PMT_AMT > 0 THEN 'POSITIVE'
        WHEN CLM_PMT_AMT = 0 THEN 'ZERO'
        WHEN CLM_PMT_AMT < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS PAYMENT_STATUS,

    CASE
        WHEN CLM_FROM_DT IS NULL
          OR CLM_THRU_DT IS NULL
        THEN 1
        ELSE 0
    END AS FLAG_MISSING_CLAIM_DATE,

    CASE
        WHEN SEGMENT = 2
         AND (CLM_FROM_DT IS NULL OR CLM_THRU_DT IS NULL)
        THEN 1
        ELSE 0
    END AS FLAG_SEGMENT_2_MISSING_DATE,

    CASE
        WHEN CLM_PMT_AMT < 0 THEN 1
        ELSE 0
    END AS FLAG_NEGATIVE_PAYMENT,

    CASE
        WHEN CLM_PMT_AMT = 0 THEN 1
        ELSE 0
    END AS FLAG_ZERO_PAYMENT,

    ICD9_DGNS_CD_1,
    ICD9_DGNS_CD_2,
    ICD9_DGNS_CD_3,
    ICD9_DGNS_CD_4,
    ICD9_DGNS_CD_5,
    ICD9_DGNS_CD_6,
    ICD9_DGNS_CD_7,
    ICD9_DGNS_CD_8,
    ICD9_DGNS_CD_9,
    ICD9_DGNS_CD_10,

    ICD9_PRCDR_CD_1,
    ICD9_PRCDR_CD_2,
    ICD9_PRCDR_CD_3,
    ICD9_PRCDR_CD_4,
    ICD9_PRCDR_CD_5,
    ICD9_PRCDR_CD_6,

    ADMTNG_ICD9_DGNS_CD,

    AT_PHYSN_NPI,
    OP_PHYSN_NPI,
    OT_PHYSN_NPI,

    CLM_DRG_CD

FROM dbo.vw_Inpatient;

GO

========================================
/* Step 22 — Validate the Inpatient Analysis View
*/

USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CLAIM_SEGMENT_KEY) AS Unique_Claim_Segments,
    COUNT(DISTINCT CLM_ID) AS Unique_Claims,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries,

    MIN(CLAIM_LENGTH_DAYS) AS Min_Claim_Length_Days,
    MAX(CLAIM_LENGTH_DAYS) AS Max_Claim_Length_Days,
    AVG(CAST(CLAIM_LENGTH_DAYS AS DECIMAL(10,2))) AS Avg_Claim_Length_Days,

    SUM(CASE WHEN PAYMENT_STATUS = 'POSITIVE' THEN 1 ELSE 0 END)
        AS Positive_Payments,

    SUM(CASE WHEN PAYMENT_STATUS = 'ZERO' THEN 1 ELSE 0 END)
        AS Zero_Payments,

    SUM(CASE WHEN PAYMENT_STATUS = 'NEGATIVE' THEN 1 ELSE 0 END)
        AS Negative_Payments,

    SUM(FLAG_MISSING_CLAIM_DATE) AS Missing_Date_Rows

FROM dbo.vw_Inpatient_Analysis;
GO

==============================================================================
/* Step 23 — Create the Inpatient Claim-Level Analysis View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Inpatient_Claim_Analysis
AS

SELECT
    DESYNPUF_ID,
    CLM_ID,

    MIN(CLAIM_YEAR) AS CLAIM_YEAR,

    MIN(CLM_FROM_DT) AS CLM_FROM_DT,
    MAX(CLM_THRU_DT) AS CLM_THRU_DT,

    MIN(CLM_ADMSN_DT) AS CLM_ADMSN_DT,
    MAX(NCH_BENE_DSCHRG_DT) AS NCH_BENE_DSCHRG_DT,

    CASE
        WHEN MIN(CLM_FROM_DT) IS NOT NULL
         AND MAX(CLM_THRU_DT) IS NOT NULL
        THEN DATEDIFF(
            DAY,
            MIN(CLM_FROM_DT),
            MAX(CLM_THRU_DT)
        ) + 1
        ELSE NULL
    END AS CLAIM_LENGTH_DAYS,

    CASE
        WHEN MIN(CLM_ADMSN_DT) IS NOT NULL
         AND MAX(NCH_BENE_DSCHRG_DT) IS NOT NULL
        THEN DATEDIFF(
            DAY,
            MIN(CLM_ADMSN_DT),
            MAX(NCH_BENE_DSCHRG_DT)
        ) + 1
        ELSE NULL
    END AS LENGTH_OF_STAY_DAYS,

    SUM(CLM_PMT_AMT) AS TOTAL_CLAIM_PAYMENT,

    COUNT(*) AS SEGMENT_COUNT,

    CASE
        WHEN SUM(CLM_PMT_AMT) > 0 THEN 'POSITIVE'
        WHEN SUM(CLM_PMT_AMT) = 0 THEN 'ZERO'
        WHEN SUM(CLM_PMT_AMT) < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS PAYMENT_STATUS,

    MAX(FLAG_MISSING_CLAIM_DATE) AS FLAG_MISSING_CLAIM_DATE,

    MAX(FLAG_SEGMENT_2_MISSING_DATE)
        AS FLAG_SEGMENT_2_MISSING_DATE,

    MAX(FLAG_NEGATIVE_PAYMENT) AS FLAG_NEGATIVE_PAYMENT,

    MAX(FLAG_ZERO_PAYMENT) AS FLAG_ZERO_PAYMENT,

    MAX(ICD9_DGNS_CD_1) AS ICD9_DGNS_CD_1,
    MAX(ICD9_DGNS_CD_2) AS ICD9_DGNS_CD_2,
    MAX(ICD9_DGNS_CD_3) AS ICD9_DGNS_CD_3,
    MAX(ICD9_DGNS_CD_4) AS ICD9_DGNS_CD_4,
    MAX(ICD9_DGNS_CD_5) AS ICD9_DGNS_CD_5,
    MAX(ICD9_DGNS_CD_6) AS ICD9_DGNS_CD_6,
    MAX(ICD9_DGNS_CD_7) AS ICD9_DGNS_CD_7,
    MAX(ICD9_DGNS_CD_8) AS ICD9_DGNS_CD_8,
    MAX(ICD9_DGNS_CD_9) AS ICD9_DGNS_CD_9,
    MAX(ICD9_DGNS_CD_10) AS ICD9_DGNS_CD_10,

    MAX(ICD9_PRCDR_CD_1) AS ICD9_PRCDR_CD_1,
    MAX(ICD9_PRCDR_CD_2) AS ICD9_PRCDR_CD_2,
    MAX(ICD9_PRCDR_CD_3) AS ICD9_PRCDR_CD_3,
    MAX(ICD9_PRCDR_CD_4) AS ICD9_PRCDR_CD_4,
    MAX(ICD9_PRCDR_CD_5) AS ICD9_PRCDR_CD_5,
    MAX(ICD9_PRCDR_CD_6) AS ICD9_PRCDR_CD_6,

    MAX(ADMTNG_ICD9_DGNS_CD) AS ADMTNG_ICD9_DGNS_CD,

    MAX(AT_PHYSN_NPI) AS AT_PHYSN_NPI,
    MAX(OP_PHYSN_NPI) AS OP_PHYSN_NPI,
    MAX(OT_PHYSN_NPI) AS OT_PHYSN_NPI,

    MAX(CLM_DRG_CD) AS CLM_DRG_CD

FROM dbo.vw_Inpatient_Analysis

GROUP BY
    DESYNPUF_ID,
    CLM_ID;

GO

========================================================
/* Step 24 — Validate the Claim-Level View
*/

USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Total_Claims,
    COUNT(DISTINCT CLM_ID) AS Unique_Claims,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries,

    MIN(SEGMENT_COUNT) AS Min_Segments_Per_Claim,
    MAX(SEGMENT_COUNT) AS Max_Segments_Per_Claim,
    AVG(CAST(SEGMENT_COUNT AS DECIMAL(10,2)))
        AS Avg_Segments_Per_Claim,

    MIN(LENGTH_OF_STAY_DAYS) AS Min_Length_Of_Stay,
    MAX(LENGTH_OF_STAY_DAYS) AS Max_Length_Of_Stay,
    AVG(CAST(LENGTH_OF_STAY_DAYS AS DECIMAL(10,2)))
        AS Avg_Length_Of_Stay,

    MIN(TOTAL_CLAIM_PAYMENT) AS Min_Total_Payment,
    MAX(TOTAL_CLAIM_PAYMENT) AS Max_Total_Payment,
    AVG(CAST(TOTAL_CLAIM_PAYMENT AS DECIMAL(18,2)))
        AS Avg_Total_Payment,

    SUM(
        CASE
            WHEN PAYMENT_STATUS = 'NEGATIVE' THEN 1
            ELSE 0
        END
    ) AS Negative_Payment_Claims,

    SUM(
        CASE
            WHEN FLAG_MISSING_CLAIM_DATE = 1 THEN 1
            ELSE 0
        END
    ) AS Claims_With_Missing_Dates

FROM dbo.vw_Inpatient_Claim_Analysis;
GO

==============================================
/* Step 25 — Build the Outpatient Analysis View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Outpatient_Analysis
AS

SELECT
    DESYNPUF_ID,
    CLM_ID,
    SEGMENT,
    CLAIM_SEGMENT_KEY,

    CLAIM_YEAR,

    CLM_FROM_DT,
    CLM_THRU_DT,

    CASE
        WHEN CLM_FROM_DT IS NOT NULL
         AND CLM_THRU_DT IS NOT NULL
        THEN DATEDIFF(DAY, CLM_FROM_DT, CLM_THRU_DT) + 1
        ELSE NULL
    END AS CLAIM_LENGTH_DAYS,

    CLM_PMT_AMT,

    CASE
        WHEN CLM_PMT_AMT > 0 THEN 'POSITIVE'
        WHEN CLM_PMT_AMT = 0 THEN 'ZERO'
        WHEN CLM_PMT_AMT < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS PAYMENT_STATUS,

    FLAG_MISSING_CLAIM_DATE,

    FLAG_SEGMENT_2_MISSING_DATE,

    FLAG_NEGATIVE_PAYMENT,

    FLAG_ZERO_PAYMENT,

    FLAG_ORPHAN_SEGMENT_2,

    OUTPATIENT_DATE_QUALITY,

    OUTPATIENT_PAYMENT_QUALITY,

    ICD9_DGNS_CD_1,
    ICD9_DGNS_CD_2,
    ICD9_DGNS_CD_3,
    ICD9_DGNS_CD_4,
    ICD9_DGNS_CD_5,
    ICD9_DGNS_CD_6,
    ICD9_DGNS_CD_7,
    ICD9_DGNS_CD_8,
    ICD9_DGNS_CD_9,
    ICD9_DGNS_CD_10,

    HCPCS_CD_1,
    HCPCS_CD_2,
    HCPCS_CD_3,
    HCPCS_CD_4,
    HCPCS_CD_5,
    HCPCS_CD_6,
    HCPCS_CD_7,
    HCPCS_CD_8,
    HCPCS_CD_9,
    HCPCS_CD_10,
    HCPCS_CD_11,
    HCPCS_CD_12,
    HCPCS_CD_13,

    AT_PHYSN_NPI,
    OP_PHYSN_NPI,
    OT_PHYSN_NPI

FROM dbo.vw_Outpatient;

GO

=========================================
/* Step 26 — Validate the Outpatient Analysis View
*/

USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Total_Rows,

    COUNT(DISTINCT CLAIM_SEGMENT_KEY)
        AS Unique_Claim_Segments,

    COUNT(DISTINCT CLM_ID)
        AS Unique_Claims,

    COUNT(DISTINCT DESYNPUF_ID)
        AS Unique_Beneficiaries,

    MIN(CLAIM_LENGTH_DAYS)
        AS Min_Claim_Length_Days,

    MAX(CLAIM_LENGTH_DAYS)
        AS Max_Claim_Length_Days,

    AVG(CAST(CLAIM_LENGTH_DAYS AS DECIMAL(10,2)))
        AS Avg_Claim_Length_Days,

    SUM(
        CASE
            WHEN PAYMENT_STATUS = 'POSITIVE'
            THEN 1 ELSE 0
        END
    ) AS Positive_Payments,

    SUM(
        CASE
            WHEN PAYMENT_STATUS = 'ZERO'
            THEN 1 ELSE 0
        END
    ) AS Zero_Payments,

    SUM(
        CASE
            WHEN PAYMENT_STATUS = 'NEGATIVE'
            THEN 1 ELSE 0
        END
    ) AS Negative_Payments,

    SUM(
        CAST(FLAG_MISSING_CLAIM_DATE AS INT)
    ) AS Missing_Date_Rows,

    SUM(
        CAST(FLAG_ORPHAN_SEGMENT_2 AS INT)
    ) AS Orphan_Segment_2_Rows

FROM dbo.vw_Outpatient_Analysis;
GO
==================================================
/* Step 27 — Create the Outpatient Claim-Level View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Outpatient_Claim_Analysis
AS

SELECT
    DESYNPUF_ID,
    CLM_ID,

    MIN(CLAIM_YEAR) AS CLAIM_YEAR,

    MIN(CLM_FROM_DT) AS CLM_FROM_DT,
    MAX(CLM_THRU_DT) AS CLM_THRU_DT,

    CASE
        WHEN MIN(CLM_FROM_DT) IS NOT NULL
         AND MAX(CLM_THRU_DT) IS NOT NULL
        THEN DATEDIFF(
            DAY,
            MIN(CLM_FROM_DT),
            MAX(CLM_THRU_DT)
        ) + 1
        ELSE NULL
    END AS CLAIM_LENGTH_DAYS,

    SUM(CLM_PMT_AMT) AS TOTAL_CLAIM_PAYMENT,

    COUNT(*) AS SEGMENT_COUNT,

    CASE
        WHEN SUM(CLM_PMT_AMT) > 0 THEN 'POSITIVE'
        WHEN SUM(CLM_PMT_AMT) = 0 THEN 'ZERO'
        WHEN SUM(CLM_PMT_AMT) < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS PAYMENT_STATUS,

    MAX(CAST(FLAG_MISSING_CLAIM_DATE AS INT))
        AS FLAG_MISSING_CLAIM_DATE,

    MAX(CAST(FLAG_SEGMENT_2_MISSING_DATE AS INT))
        AS FLAG_SEGMENT_2_MISSING_DATE,

    MAX(CAST(FLAG_NEGATIVE_PAYMENT AS INT))
        AS FLAG_NEGATIVE_PAYMENT,

    MAX(CAST(FLAG_ZERO_PAYMENT AS INT))
        AS FLAG_ZERO_PAYMENT,

    MAX(CAST(FLAG_ORPHAN_SEGMENT_2 AS INT))
        AS FLAG_ORPHAN_SEGMENT_2,

    MAX(OUTPATIENT_DATE_QUALITY)
        AS OUTPATIENT_DATE_QUALITY,

    MAX(OUTPATIENT_PAYMENT_QUALITY)
        AS OUTPATIENT_PAYMENT_QUALITY,

    MAX(ICD9_DGNS_CD_1) AS ICD9_DGNS_CD_1,
    MAX(ICD9_DGNS_CD_2) AS ICD9_DGNS_CD_2,
    MAX(ICD9_DGNS_CD_3) AS ICD9_DGNS_CD_3,
    MAX(ICD9_DGNS_CD_4) AS ICD9_DGNS_CD_4,
    MAX(ICD9_DGNS_CD_5) AS ICD9_DGNS_CD_5,
    MAX(ICD9_DGNS_CD_6) AS ICD9_DGNS_CD_6,
    MAX(ICD9_DGNS_CD_7) AS ICD9_DGNS_CD_7,
    MAX(ICD9_DGNS_CD_8) AS ICD9_DGNS_CD_8,
    MAX(ICD9_DGNS_CD_9) AS ICD9_DGNS_CD_9,
    MAX(ICD9_DGNS_CD_10) AS ICD9_DGNS_CD_10,

    MAX(HCPCS_CD_1) AS HCPCS_CD_1,
    MAX(HCPCS_CD_2) AS HCPCS_CD_2,
    MAX(HCPCS_CD_3) AS HCPCS_CD_3,
    MAX(HCPCS_CD_4) AS HCPCS_CD_4,
    MAX(HCPCS_CD_5) AS HCPCS_CD_5,
    MAX(HCPCS_CD_6) AS HCPCS_CD_6,
    MAX(HCPCS_CD_7) AS HCPCS_CD_7,
    MAX(HCPCS_CD_8) AS HCPCS_CD_8,
    MAX(HCPCS_CD_9) AS HCPCS_CD_9,
    MAX(HCPCS_CD_10) AS HCPCS_CD_10,
    MAX(HCPCS_CD_11) AS HCPCS_CD_11,
    MAX(HCPCS_CD_12) AS HCPCS_CD_12,
    MAX(HCPCS_CD_13) AS HCPCS_CD_13,

    MAX(AT_PHYSN_NPI) AS AT_PHYSN_NPI,
    MAX(OP_PHYSN_NPI) AS OP_PHYSN_NPI,
    MAX(OT_PHYSN_NPI) AS OT_PHYSN_NPI

FROM dbo.vw_Outpatient_Analysis

GROUP BY
    DESYNPUF_ID,
    CLM_ID;

GO

=================================================
/* Step 28 — Validate the Outpatient Claim-Level View
*/

USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Total_Claims,

    COUNT(DISTINCT CLM_ID)
        AS Unique_Claims,

    COUNT(DISTINCT DESYNPUF_ID)
        AS Unique_Beneficiaries,

    MIN(SEGMENT_COUNT)
        AS Min_Segments_Per_Claim,

    MAX(SEGMENT_COUNT)
        AS Max_Segments_Per_Claim,

    AVG(CAST(SEGMENT_COUNT AS DECIMAL(10,2)))
        AS Avg_Segments_Per_Claim,

    MIN(CLAIM_LENGTH_DAYS)
        AS Min_Claim_Length_Days,

    MAX(CLAIM_LENGTH_DAYS)
        AS Max_Claim_Length_Days,

    AVG(CAST(CLAIM_LENGTH_DAYS AS DECIMAL(10,2)))
        AS Avg_Claim_Length_Days,

    MIN(TOTAL_CLAIM_PAYMENT)
        AS Min_Total_Payment,

    MAX(TOTAL_CLAIM_PAYMENT)
        AS Max_Total_Payment,

    AVG(CAST(TOTAL_CLAIM_PAYMENT AS DECIMAL(18,2)))
        AS Avg_Total_Payment,

    SUM(
        CASE
            WHEN PAYMENT_STATUS = 'NEGATIVE'
            THEN 1 ELSE 0
        END
    ) AS Negative_Payment_Claims,

    SUM(
        CAST(FLAG_MISSING_CLAIM_DATE AS INT)
    ) AS Claims_With_Missing_Dates,

    SUM(
        CAST(FLAG_ORPHAN_SEGMENT_2 AS INT)
    ) AS Orphan_Segment_2_Claims

FROM dbo.vw_Outpatient_Claim_Analysis;
GO

============================================================
/* Step 29 — Create PDE Analysis View
*/

USE Medicare_Analytics;
GO

SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'PDE_clean'
ORDER BY ORDINAL_POSITION;
GO
===================================================
/* Step 29B — Create the Corrected PDE Analysis View
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_PDE_Analysis
AS

SELECT
    DESYNPUF_ID,

    PDE_ID,

    SRVC_DT,

    SERVICE_YEAR,

    PROD_SRVC_ID,

    QTY_DSPNSD_NUM,

    DAYS_SUPLY_NUM,

    PTNT_PAY_AMT,

    TOT_RX_CST_AMT,

    CASE
        WHEN TOT_RX_CST_AMT > 0 THEN 'POSITIVE'
        WHEN TOT_RX_CST_AMT = 0 THEN 'ZERO'
        WHEN TOT_RX_CST_AMT < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS COST_STATUS,

    CASE
        WHEN PTNT_PAY_AMT > 0 THEN 'POSITIVE'
        WHEN PTNT_PAY_AMT = 0 THEN 'ZERO'
        WHEN PTNT_PAY_AMT < 0 THEN 'NEGATIVE'
        ELSE 'MISSING'
    END AS PATIENT_PAYMENT_STATUS

FROM dbo.vw_PDE;

GO

=======================================
/* Step 30 — Validate the PDE Analysis View
*/

USE Medicare_Analytics;
GO

SELECT
    COUNT(*) AS Total_PDE_Events,

    COUNT(DISTINCT PDE_ID)
        AS Unique_PDE_IDs,

    COUNT(DISTINCT DESYNPUF_ID)
        AS Unique_Beneficiaries,

    MIN(SRVC_DT)
        AS Earliest_Service_Date,

    MAX(SRVC_DT)
        AS Latest_Service_Date,

    MIN(TOT_RX_CST_AMT)
        AS Min_Prescription_Cost,

    MAX(TOT_RX_CST_AMT)
        AS Max_Prescription_Cost,

    AVG(CAST(TOT_RX_CST_AMT AS DECIMAL(18,2)))
        AS Avg_Prescription_Cost,

    SUM(
        CASE
            WHEN COST_STATUS = 'POSITIVE'
            THEN 1 ELSE 0
        END
    ) AS Positive_Cost_Events,

    SUM(
        CASE
            WHEN COST_STATUS = 'ZERO'
            THEN 1 ELSE 0
        END
    ) AS Zero_Cost_Events,

    SUM(
        CASE
            WHEN COST_STATUS = 'NEGATIVE'
            THEN 1 ELSE 0
        END
    ) AS Negative_Cost_Events,

    SUM(
        CASE
            WHEN PATIENT_PAYMENT_STATUS = 'POSITIVE'
            THEN 1 ELSE 0
        END
    ) AS Positive_Patient_Payments,

    SUM(
        CASE
            WHEN PATIENT_PAYMENT_STATUS = 'ZERO'
            THEN 1 ELSE 0
        END
    ) AS Zero_Patient_Payments,

    SUM(
        CASE
            WHEN PATIENT_PAYMENT_STATUS = 'NEGATIVE'
            THEN 1 ELSE 0
        END
    ) AS Negative_Patient_Payments

FROM dbo.vw_PDE_Analysis;
GO
===================================
/* Step 31 — Build the Year-Aware Beneficiary Relationship
test this with Carrier claims.
*/
USE Medicare_Analytics;
GO

SELECT
    c.CLAIM_YEAR,

    COUNT(DISTINCT c.CLM_ID)
        AS TOTAL_CARRIER_CLAIMS,

    COUNT(DISTINCT c.DESYNPUF_ID)
        AS CARRIER_BENEFICIARIES,

    COUNT(DISTINCT
        CASE
            WHEN b.DESYNPUF_ID IS NOT NULL
            THEN c.DESYNPUF_ID
        END
    ) AS YEAR_MATCHED_BENEFICIARIES

FROM dbo.vw_Carrier_Claim_Analysis c

LEFT JOIN dbo.Beneficiary_Year b
    ON c.DESYNPUF_ID = b.DESYNPUF_ID
    AND c.CLAIM_YEAR = b.BENEFICIARY_YEAR

GROUP BY
    c.CLAIM_YEAR

ORDER BY
    c.CLAIM_YEAR;
GO

===========================================================
/* Step 32 — Test the Same Year-Aware Relationship Across All Four Event Types
*/
USE Medicare_Analytics;
GO

SELECT
    'Carrier' AS CLAIM_TYPE,
    c.CLAIM_YEAR AS CLAIM_YEAR,
    COUNT(DISTINCT c.CLM_ID) AS TOTAL_EVENTS,
    COUNT(DISTINCT c.DESYNPUF_ID) AS UNIQUE_BENEFICIARIES,
    COUNT(DISTINCT
        CASE
            WHEN b.DESYNPUF_ID IS NOT NULL
            THEN c.DESYNPUF_ID
        END
    ) AS YEAR_MATCHED_BENEFICIARIES
FROM dbo.vw_Carrier_Claim_Analysis c
LEFT JOIN dbo.Beneficiary_Year b
    ON c.DESYNPUF_ID = b.DESYNPUF_ID
    AND c.CLAIM_YEAR = b.BENEFICIARY_YEAR
GROUP BY c.CLAIM_YEAR

UNION ALL

SELECT
    'Inpatient',
    i.CLAIM_YEAR,
    COUNT(DISTINCT i.CLM_ID),
    COUNT(DISTINCT i.DESYNPUF_ID),
    COUNT(DISTINCT
        CASE
            WHEN b.DESYNPUF_ID IS NOT NULL
            THEN i.DESYNPUF_ID
        END
    )
FROM dbo.vw_Inpatient_Claim_Analysis i
LEFT JOIN dbo.Beneficiary_Year b
    ON i.DESYNPUF_ID = b.DESYNPUF_ID
    AND i.CLAIM_YEAR = b.BENEFICIARY_YEAR
GROUP BY i.CLAIM_YEAR

UNION ALL

SELECT
    'Outpatient',
    o.CLAIM_YEAR,
    COUNT(DISTINCT o.CLM_ID),
    COUNT(DISTINCT o.DESYNPUF_ID),
    COUNT(DISTINCT
        CASE
            WHEN b.DESYNPUF_ID IS NOT NULL
            THEN o.DESYNPUF_ID
        END
    )
FROM dbo.vw_Outpatient_Claim_Analysis o
LEFT JOIN dbo.Beneficiary_Year b
    ON o.DESYNPUF_ID = b.DESYNPUF_ID
    AND o.CLAIM_YEAR = b.BENEFICIARY_YEAR
GROUP BY o.CLAIM_YEAR

UNION ALL

SELECT
    'PDE',
    p.SERVICE_YEAR,
    COUNT(DISTINCT p.PDE_ID),
    COUNT(DISTINCT p.DESYNPUF_ID),
    COUNT(DISTINCT
        CASE
            WHEN b.DESYNPUF_ID IS NOT NULL
            THEN p.DESYNPUF_ID
        END
    )
FROM dbo.vw_PDE_Analysis p
LEFT JOIN dbo.Beneficiary_Year b
    ON p.DESYNPUF_ID = b.DESYNPUF_ID
    AND p.SERVICE_YEAR = b.BENEFICIARY_YEAR
GROUP BY p.SERVICE_YEAR

ORDER BY
    CLAIM_TYPE,
    CLAIM_YEAR;
GO

===============================================================
/* Step 33 — Create the Tableau-ready annual summary
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Beneficiary_Annual_Summary
AS

WITH CarrierSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS CARRIER_CLAIM_COUNT,

        SUM(TOTAL_MEDICARE_PAYMENT) AS CARRIER_MEDICARE_PAYMENT,

        SUM(TOTAL_ALLOWED_CHARGES) AS CARRIER_ALLOWED_CHARGES,

        SUM(TOTAL_BENEFICIARY_DEDUCTIBLE) AS CARRIER_BENEFICIARY_DEDUCTIBLE,

        SUM(TOTAL_PRIMARY_PAYER_PAYMENT) AS CARRIER_PRIMARY_PAYER_PAYMENT,

        SUM(TOTAL_COINSURANCE) AS CARRIER_COINSURANCE

    FROM dbo.vw_Carrier_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

InpatientSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS INPATIENT_CLAIM_COUNT,

        SUM(TOTAL_CLAIM_PAYMENT) AS INPATIENT_MEDICARE_PAYMENT,

        AVG(CLAIM_LENGTH_DAYS) AS AVG_INPATIENT_CLAIM_LENGTH_DAYS,

        AVG(LENGTH_OF_STAY_DAYS) AS AVG_INPATIENT_LENGTH_OF_STAY_DAYS,

        SUM(SEGMENT_COUNT) AS INPATIENT_SEGMENT_COUNT

    FROM dbo.vw_Inpatient_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

OutpatientSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS OUTPATIENT_CLAIM_COUNT,

        SUM(TOTAL_CLAIM_PAYMENT) AS OUTPATIENT_MEDICARE_PAYMENT,

        AVG(CLAIM_LENGTH_DAYS) AS AVG_OUTPATIENT_CLAIM_LENGTH_DAYS,

        SUM(SEGMENT_COUNT) AS OUTPATIENT_SEGMENT_COUNT

    FROM dbo.vw_Outpatient_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

PDESummary AS
(
    SELECT
        DESYNPUF_ID,
        SERVICE_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT PDE_ID) AS PRESCRIPTION_EVENT_COUNT,

        SUM(TOT_RX_CST_AMT) AS TOTAL_PRESCRIPTION_COST,

        SUM(PTNT_PAY_AMT) AS TOTAL_PRESCRIPTION_PATIENT_PAYMENT

    FROM dbo.vw_PDE_Analysis

    WHERE SERVICE_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        SERVICE_YEAR
)

SELECT

    /* Beneficiary information */
    b.DESYNPUF_ID,
    b.BENEFICIARY_YEAR,

    b.BENE_BIRTH_DT,
    b.BENE_DEATH_DT,
    b.BENE_SEX_IDENT_CD,
    b.BENE_RACE_CD,
    b.BENE_ESRD_IND,
    b.SP_STATE_CODE,
    b.BENE_COUNTY_CD,

    /* Medicare coverage */
    b.BENE_HI_CVRAGE_TOT_MONS,
    b.BENE_SMI_CVRAGE_TOT_MONS,
    b.BENE_HMO_CVRAGE_TOT_MONS,
    b.PLAN_CVRG_MOS_NUM,

    /* Chronic conditions */
    b.SP_ALZHDMTA,
    b.SP_CHF,
    b.SP_CHRNKIDN,
    b.SP_CNCR,
    b.SP_COPD,
    b.SP_DEPRESSN,
    b.SP_DIABETES,
    b.SP_ISCHMCHT,
    b.SP_OSTEOPRS,
    b.SP_RA_OA,
    b.SP_STRKETIA,

    /* Beneficiary annual reimbursement fields */
    b.MEDREIMB_IP,
    b.BENRES_IP,
    b.PPPYMT_IP,

    b.MEDREIMB_OP,
    b.BENRES_OP,
    b.PPPYMT_OP,

    b.MEDREIMB_CAR,
    b.BENRES_CAR,
    b.PPPYMT_CAR,

    /* Carrier */
    COALESCE(c.CARRIER_CLAIM_COUNT, 0) AS CARRIER_CLAIM_COUNT,
    COALESCE(c.CARRIER_MEDICARE_PAYMENT, 0) AS CARRIER_MEDICARE_PAYMENT,
    COALESCE(c.CARRIER_ALLOWED_CHARGES, 0) AS CARRIER_ALLOWED_CHARGES,
    COALESCE(c.CARRIER_BENEFICIARY_DEDUCTIBLE, 0) AS CARRIER_BENEFICIARY_DEDUCTIBLE,
    COALESCE(c.CARRIER_PRIMARY_PAYER_PAYMENT, 0) AS CARRIER_PRIMARY_PAYER_PAYMENT,
    COALESCE(c.CARRIER_COINSURANCE, 0) AS CARRIER_COINSURANCE,

    /* Inpatient */
    COALESCE(i.INPATIENT_CLAIM_COUNT, 0) AS INPATIENT_CLAIM_COUNT,
    COALESCE(i.INPATIENT_MEDICARE_PAYMENT, 0) AS INPATIENT_MEDICARE_PAYMENT,
    COALESCE(i.AVG_INPATIENT_CLAIM_LENGTH_DAYS, 0) AS AVG_INPATIENT_CLAIM_LENGTH_DAYS,
    COALESCE(i.AVG_INPATIENT_LENGTH_OF_STAY_DAYS, 0) AS AVG_INPATIENT_LENGTH_OF_STAY_DAYS,
    COALESCE(i.INPATIENT_SEGMENT_COUNT, 0) AS INPATIENT_SEGMENT_COUNT,

    /* Outpatient */
    COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0) AS OUTPATIENT_CLAIM_COUNT,
    COALESCE(o.OUTPATIENT_MEDICARE_PAYMENT, 0) AS OUTPATIENT_MEDICARE_PAYMENT,
    COALESCE(o.AVG_OUTPATIENT_CLAIM_LENGTH_DAYS, 0) AS AVG_OUTPATIENT_CLAIM_LENGTH_DAYS,
    COALESCE(o.OUTPATIENT_SEGMENT_COUNT, 0) AS OUTPATIENT_SEGMENT_COUNT,

    /* Prescription drugs */
    COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0) AS PRESCRIPTION_EVENT_COUNT,
    COALESCE(p.TOTAL_PRESCRIPTION_COST, 0) AS TOTAL_PRESCRIPTION_COST,
    COALESCE(p.TOTAL_PRESCRIPTION_PATIENT_PAYMENT, 0) AS TOTAL_PRESCRIPTION_PATIENT_PAYMENT,

    /* Overall utilization */
    COALESCE(c.CARRIER_CLAIM_COUNT, 0)
        + COALESCE(i.INPATIENT_CLAIM_COUNT, 0)
        + COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0)
        + COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0)
        AS TOTAL_MEDICARE_EVENTS

FROM dbo.Beneficiary_Year b

LEFT JOIN CarrierSummary c
    ON b.DESYNPUF_ID = c.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = c.BENEFICIARY_YEAR

LEFT JOIN InpatientSummary i
    ON b.DESYNPUF_ID = i.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = i.BENEFICIARY_YEAR

LEFT JOIN OutpatientSummary o
    ON b.DESYNPUF_ID = o.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = o.BENEFICIARY_YEAR

LEFT JOIN PDESummary p
    ON b.DESYNPUF_ID = p.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = p.BENEFICIARY_YEAR;
GO

===================================================================
/*  Step 34 — Validate the annual summary financially
*/

USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    COUNT(*) AS BENEFICIARY_YEAR_ROWS,

    COUNT(DISTINCT DESYNPUF_ID) AS UNIQUE_BENEFICIARIES,

    SUM(CARRIER_CLAIM_COUNT) AS TOTAL_CARRIER_CLAIMS,
    SUM(CARRIER_MEDICARE_PAYMENT) AS TOTAL_CARRIER_PAYMENT,

    SUM(INPATIENT_CLAIM_COUNT) AS TOTAL_INPATIENT_CLAIMS,
    SUM(INPATIENT_MEDICARE_PAYMENT) AS TOTAL_INPATIENT_PAYMENT,

    SUM(OUTPATIENT_CLAIM_COUNT) AS TOTAL_OUTPATIENT_CLAIMS,
    SUM(OUTPATIENT_MEDICARE_PAYMENT) AS TOTAL_OUTPATIENT_PAYMENT,

    SUM(PRESCRIPTION_EVENT_COUNT) AS TOTAL_PRESCRIPTION_EVENTS,
    SUM(TOTAL_PRESCRIPTION_COST) AS TOTAL_PRESCRIPTION_COST,

    SUM(TOTAL_MEDICARE_EVENTS) AS TOTAL_MEDICARE_EVENTS

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

==============================================================
/* Step 35A — Replace the annual summary with an enhanced version
*/

USE Medicare_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_Beneficiary_Annual_Summary
AS

WITH CarrierSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS CARRIER_CLAIM_COUNT,

        SUM(TOTAL_MEDICARE_PAYMENT) AS CARRIER_MEDICARE_PAYMENT,

        SUM(TOTAL_ALLOWED_CHARGES) AS CARRIER_ALLOWED_CHARGES,

        SUM(TOTAL_BENEFICIARY_DEDUCTIBLE) AS CARRIER_BENEFICIARY_DEDUCTIBLE,

        SUM(TOTAL_PRIMARY_PAYER_PAYMENT) AS CARRIER_PRIMARY_PAYER_PAYMENT,

        SUM(TOTAL_COINSURANCE) AS CARRIER_COINSURANCE

    FROM dbo.vw_Carrier_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

InpatientSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS INPATIENT_CLAIM_COUNT,

        SUM(TOTAL_CLAIM_PAYMENT) AS INPATIENT_MEDICARE_PAYMENT,

        AVG(CLAIM_LENGTH_DAYS) AS AVG_INPATIENT_CLAIM_LENGTH_DAYS,

        AVG(LENGTH_OF_STAY_DAYS) AS AVG_INPATIENT_LENGTH_OF_STAY_DAYS,

        SUM(SEGMENT_COUNT) AS INPATIENT_SEGMENT_COUNT

    FROM dbo.vw_Inpatient_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

OutpatientSummary AS
(
    SELECT
        DESYNPUF_ID,
        CLAIM_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT CLM_ID) AS OUTPATIENT_CLAIM_COUNT,

        SUM(TOTAL_CLAIM_PAYMENT) AS OUTPATIENT_MEDICARE_PAYMENT,

        AVG(CLAIM_LENGTH_DAYS) AS AVG_OUTPATIENT_CLAIM_LENGTH_DAYS,

        SUM(SEGMENT_COUNT) AS OUTPATIENT_SEGMENT_COUNT

    FROM dbo.vw_Outpatient_Claim_Analysis

    WHERE CLAIM_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        CLAIM_YEAR
),

PDESummary AS
(
    SELECT
        DESYNPUF_ID,
        SERVICE_YEAR AS BENEFICIARY_YEAR,

        COUNT(DISTINCT PDE_ID) AS PRESCRIPTION_EVENT_COUNT,

        SUM(TOT_RX_CST_AMT) AS TOTAL_PRESCRIPTION_COST,

        SUM(PTNT_PAY_AMT) AS TOTAL_PRESCRIPTION_PATIENT_PAYMENT

    FROM dbo.vw_PDE_Analysis

    WHERE SERVICE_YEAR IN (2008, 2009, 2010)

    GROUP BY
        DESYNPUF_ID,
        SERVICE_YEAR
)

SELECT

    /* ============================================================
       BENEFICIARY INFORMATION
       ============================================================ */

    b.DESYNPUF_ID,
    b.BENEFICIARY_YEAR,

    b.BENE_BIRTH_DT,
    b.BENE_DEATH_DT,
    b.BENE_SEX_IDENT_CD,
    b.BENE_RACE_CD,
    b.BENE_ESRD_IND,
    b.SP_STATE_CODE,
    b.BENE_COUNTY_CD,

    /* ============================================================
       MEDICARE COVERAGE
       ============================================================ */

    b.BENE_HI_CVRAGE_TOT_MONS,
    b.BENE_SMI_CVRAGE_TOT_MONS,
    b.BENE_HMO_CVRAGE_TOT_MONS,
    b.PLAN_CVRG_MOS_NUM,

    /* ============================================================
       CHRONIC CONDITIONS
       ============================================================ */

    b.SP_ALZHDMTA,
    b.SP_CHF,
    b.SP_CHRNKIDN,
    b.SP_CNCR,
    b.SP_COPD,
    b.SP_DEPRESSN,
    b.SP_DIABETES,
    b.SP_ISCHMCHT,
    b.SP_OSTEOPRS,
    b.SP_RA_OA,
    b.SP_STRKETIA,

    /* Count of chronic conditions */
    (
        COALESCE(b.SP_ALZHDMTA, 0) +
        COALESCE(b.SP_CHF, 0) +
        COALESCE(b.SP_CHRNKIDN, 0) +
        COALESCE(b.SP_CNCR, 0) +
        COALESCE(b.SP_COPD, 0) +
        COALESCE(b.SP_DEPRESSN, 0) +
        COALESCE(b.SP_DIABETES, 0) +
        COALESCE(b.SP_ISCHMCHT, 0) +
        COALESCE(b.SP_OSTEOPRS, 0) +
        COALESCE(b.SP_RA_OA, 0) +
        COALESCE(b.SP_STRKETIA, 0)
    ) AS CHRONIC_CONDITION_COUNT,

    /* ============================================================
       BENEFICIARY ANNUAL REIMBURSEMENT
       ============================================================ */

    b.MEDREIMB_IP,
    b.BENRES_IP,
    b.PPPYMT_IP,

    b.MEDREIMB_OP,
    b.BENRES_OP,
    b.PPPYMT_OP,

    b.MEDREIMB_CAR,
    b.BENRES_CAR,
    b.PPPYMT_CAR,

    /* ============================================================
       CARRIER
       ============================================================ */

    COALESCE(c.CARRIER_CLAIM_COUNT, 0) AS CARRIER_CLAIM_COUNT,

    COALESCE(c.CARRIER_MEDICARE_PAYMENT, 0) AS CARRIER_MEDICARE_PAYMENT,

    COALESCE(c.CARRIER_ALLOWED_CHARGES, 0) AS CARRIER_ALLOWED_CHARGES,

    COALESCE(c.CARRIER_BENEFICIARY_DEDUCTIBLE, 0) AS CARRIER_BENEFICIARY_DEDUCTIBLE,

    COALESCE(c.CARRIER_PRIMARY_PAYER_PAYMENT, 0) AS CARRIER_PRIMARY_PAYER_PAYMENT,

    COALESCE(c.CARRIER_COINSURANCE, 0) AS CARRIER_COINSURANCE,

    /* ============================================================
       INPATIENT
       ============================================================ */

    COALESCE(i.INPATIENT_CLAIM_COUNT, 0) AS INPATIENT_CLAIM_COUNT,

    COALESCE(i.INPATIENT_MEDICARE_PAYMENT, 0) AS INPATIENT_MEDICARE_PAYMENT,

    COALESCE(i.AVG_INPATIENT_CLAIM_LENGTH_DAYS, 0)
        AS AVG_INPATIENT_CLAIM_LENGTH_DAYS,

    COALESCE(i.AVG_INPATIENT_LENGTH_OF_STAY_DAYS, 0)
        AS AVG_INPATIENT_LENGTH_OF_STAY_DAYS,

    COALESCE(i.INPATIENT_SEGMENT_COUNT, 0)
        AS INPATIENT_SEGMENT_COUNT,

    /* ============================================================
       OUTPATIENT
       ============================================================ */

    COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0)
        AS OUTPATIENT_CLAIM_COUNT,

    COALESCE(o.OUTPATIENT_MEDICARE_PAYMENT, 0)
        AS OUTPATIENT_MEDICARE_PAYMENT,

    COALESCE(o.AVG_OUTPATIENT_CLAIM_LENGTH_DAYS, 0)
        AS AVG_OUTPATIENT_CLAIM_LENGTH_DAYS,

    COALESCE(o.OUTPATIENT_SEGMENT_COUNT, 0)
        AS OUTPATIENT_SEGMENT_COUNT,

    /* ============================================================
       PRESCRIPTION DRUG EVENTS
       ============================================================ */

    COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0)
        AS PRESCRIPTION_EVENT_COUNT,

    COALESCE(p.TOTAL_PRESCRIPTION_COST, 0)
        AS TOTAL_PRESCRIPTION_COST,

    COALESCE(p.TOTAL_PRESCRIPTION_PATIENT_PAYMENT, 0)
        AS TOTAL_PRESCRIPTION_PATIENT_PAYMENT,

    /* ============================================================
       OVERALL UTILIZATION
       ============================================================ */

    COALESCE(c.CARRIER_CLAIM_COUNT, 0)
        + COALESCE(i.INPATIENT_CLAIM_COUNT, 0)
        + COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0)
        + COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0)
        AS TOTAL_MEDICARE_EVENTS,

    /* Medical claims excluding prescriptions */
    COALESCE(c.CARRIER_CLAIM_COUNT, 0)
        + COALESCE(i.INPATIENT_CLAIM_COUNT, 0)
        + COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0)
        AS TOTAL_MEDICAL_CLAIMS,

    /* Medical payments excluding prescriptions */
    COALESCE(c.CARRIER_MEDICARE_PAYMENT, 0)
        + COALESCE(i.INPATIENT_MEDICARE_PAYMENT, 0)
        + COALESCE(o.OUTPATIENT_MEDICARE_PAYMENT, 0)
        AS TOTAL_MEDICAL_PAYMENT,

    /* Medical + prescription spending */
    COALESCE(c.CARRIER_MEDICARE_PAYMENT, 0)
        + COALESCE(i.INPATIENT_MEDICARE_PAYMENT, 0)
        + COALESCE(o.OUTPATIENT_MEDICARE_PAYMENT, 0)
        + COALESCE(p.TOTAL_PRESCRIPTION_COST, 0)
        AS TOTAL_HEALTHCARE_COST,

    /* ============================================================
       UTILIZATION FLAGS
       ============================================================ */

    CASE
        WHEN COALESCE(i.INPATIENT_CLAIM_COUNT, 0) > 0
        THEN 1
        ELSE 0
    END AS HAD_INPATIENT_CARE,

    CASE
        WHEN COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0) > 0
        THEN 1
        ELSE 0
    END AS HAD_OUTPATIENT_CARE,

    CASE
        WHEN COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0) > 0
        THEN 1
        ELSE 0
    END AS HAD_PRESCRIPTION_EVENT,

    CASE
        WHEN
            COALESCE(c.CARRIER_CLAIM_COUNT, 0)
            + COALESCE(i.INPATIENT_CLAIM_COUNT, 0)
            + COALESCE(o.OUTPATIENT_CLAIM_COUNT, 0)
            + COALESCE(p.PRESCRIPTION_EVENT_COUNT, 0)
            > 0
        THEN 1
        ELSE 0
    END AS HAD_ANY_MEDICARE_EVENT

FROM dbo.Beneficiary_Year b

LEFT JOIN CarrierSummary c
    ON b.DESYNPUF_ID = c.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = c.BENEFICIARY_YEAR

LEFT JOIN InpatientSummary i
    ON b.DESYNPUF_ID = i.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = i.BENEFICIARY_YEAR

LEFT JOIN OutpatientSummary o
    ON b.DESYNPUF_ID = o.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = o.BENEFICIARY_YEAR

LEFT JOIN PDESummary p
    ON b.DESYNPUF_ID = p.DESYNPUF_ID
    AND b.BENEFICIARY_YEAR = p.BENEFICIARY_YEAR;
GO

================================================
/* Step 35B — Validate the new fields
*/

SELECT
    BENEFICIARY_YEAR,

    COUNT(*) AS BENEFICIARY_YEAR_ROWS,

    SUM(CHRONIC_CONDITION_COUNT) AS TOTAL_CHRONIC_CONDITIONS,

    SUM(HAD_INPATIENT_CARE) AS BENEFICIARIES_WITH_INPATIENT_CARE,

    SUM(HAD_OUTPATIENT_CARE) AS BENEFICIARIES_WITH_OUTPATIENT_CARE,

    SUM(HAD_PRESCRIPTION_EVENT) AS BENEFICIARIES_WITH_PRESCRIPTIONS,

    SUM(HAD_ANY_MEDICARE_EVENT) AS BENEFICIARIES_WITH_ANY_EVENT,

    SUM(TOTAL_MEDICAL_CLAIMS) AS TOTAL_MEDICAL_CLAIMS,

    SUM(TOTAL_MEDICAL_PAYMENT) AS TOTAL_MEDICAL_PAYMENT,

    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

========================================================
/* Step 36 — Create first real analytical question
How does healthcare utilization and spending differ by year?
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    COUNT(*) AS BENEFICIARY_COUNT,

    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    SUM(CARRIER_CLAIM_COUNT) AS CARRIER_CLAIMS,

    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,

    SUM(OUTPATIENT_CLAIM_COUNT) AS OUTPATIENT_CLAIMS,

    SUM(PRESCRIPTION_EVENT_COUNT) AS PRESCRIPTION_EVENTS,

    SUM(TOTAL_MEDICAL_CLAIMS) AS TOTAL_MEDICAL_CLAIMS,

    SUM(TOTAL_MEDICAL_PAYMENT) AS TOTAL_MEDICAL_PAYMENT,

    SUM(TOTAL_PRESCRIPTION_COST) AS TOTAL_PRESCRIPTION_COST,

    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST,

    AVG(TOTAL_HEALTHCARE_COST) AS AVG_HEALTHCARE_COST_PER_BENEFICIARY_YEAR,

    AVG(TOTAL_MEDICAL_CLAIMS) AS AVG_MEDICAL_CLAIMS_PER_BENEFICIARY_YEAR,

    AVG(PRESCRIPTION_EVENT_COUNT) AS AVG_PRESCRIPTION_EVENTS_PER_BENEFICIARY_YEAR

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

====================================================================
/* Step 37 — Break healthcare spending into categories
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    SUM(CARRIER_MEDICARE_PAYMENT) AS CARRIER_PAYMENT,

    SUM(INPATIENT_MEDICARE_PAYMENT) AS INPATIENT_PAYMENT,

    SUM(OUTPATIENT_MEDICARE_PAYMENT) AS OUTPATIENT_PAYMENT,

    SUM(TOTAL_PRESCRIPTION_COST) AS PRESCRIPTION_COST,

    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST,

    CAST(
        100.0 * SUM(CARRIER_MEDICARE_PAYMENT)
        / NULLIF(SUM(TOTAL_HEALTHCARE_COST), 0)
        AS DECIMAL(10,2)
    ) AS CARRIER_PCT_OF_TOTAL,

    CAST(
        100.0 * SUM(INPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(TOTAL_HEALTHCARE_COST), 0)
        AS DECIMAL(10,2)
    ) AS INPATIENT_PCT_OF_TOTAL,

    CAST(
        100.0 * SUM(OUTPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(TOTAL_HEALTHCARE_COST), 0)
        AS DECIMAL(10,2)
    ) AS OUTPATIENT_PCT_OF_TOTAL,

    CAST(
        100.0 * SUM(TOTAL_PRESCRIPTION_COST)
        / NULLIF(SUM(TOTAL_HEALTHCARE_COST), 0)
        AS DECIMAL(10,2)
    ) AS PRESCRIPTION_PCT_OF_TOTAL

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

===============================================
/*  Step 38 — Investigate the 2010 spending drop
*/

USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    COUNT(*) AS TOTAL_BENEFICIARIES,

    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    CAST(
        100.0 * SUM(HAD_ANY_MEDICARE_EVENT)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ACTIVE_BENEFICIARY_RATE,

    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST,

    CAST(
        SUM(TOTAL_HEALTHCARE_COST)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS COST_PER_ACTIVE_BENEFICIARY,

    CAST(
        SUM(TOTAL_HEALTHCARE_COST)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(18,2)
    ) AS COST_PER_BENEFICIARY_YEAR

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

=====================================================

/* break the cost intensity down by care category
*/

USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    -- Active population
    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    -- Carrier
    SUM(CARRIER_MEDICARE_PAYMENT) AS CARRIER_PAYMENT,

    CAST(
        SUM(CARRIER_MEDICARE_PAYMENT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS CARRIER_COST_PER_ACTIVE_BENEFICIARY,

    -- Inpatient
    SUM(INPATIENT_MEDICARE_PAYMENT) AS INPATIENT_PAYMENT,

    CAST(
        SUM(INPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS INPATIENT_COST_PER_ACTIVE_BENEFICIARY,

    -- Outpatient
    SUM(OUTPATIENT_MEDICARE_PAYMENT) AS OUTPATIENT_PAYMENT,

    CAST(
        SUM(OUTPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS OUTPATIENT_COST_PER_ACTIVE_BENEFICIARY,

    -- Prescription
    SUM(TOTAL_PRESCRIPTION_COST) AS PRESCRIPTION_COST,

    CAST(
        SUM(TOTAL_PRESCRIPTION_COST)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS PRESCRIPTION_COST_PER_ACTIVE_BENEFICIARY

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

============================
/* show the columns in the annual summary view
*/
USE Medicare_Analytics;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'vw_Beneficiary_Annual_Summary'
ORDER BY ORDINAL_POSITION;
GO
============================================
/* Step 39 — Did people use less healthcare in 2010?
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    -- Medical utilization
    SUM(CARRIER_CLAIM_COUNT) AS CARRIER_CLAIMS,
    CAST(
        SUM(CARRIER_CLAIM_COUNT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS CARRIER_CLAIMS_PER_ACTIVE_BENEFICIARY,

    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,
    CAST(
        SUM(INPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS INPATIENT_CLAIMS_PER_ACTIVE_BENEFICIARY,

    SUM(OUTPATIENT_CLAIM_COUNT) AS OUTPATIENT_CLAIMS,
    CAST(
        SUM(OUTPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS OUTPATIENT_CLAIMS_PER_ACTIVE_BENEFICIARY,

    -- Prescription utilization
    SUM(PRESCRIPTION_EVENT_COUNT) AS PRESCRIPTION_EVENTS,
    CAST(
        SUM(PRESCRIPTION_EVENT_COUNT)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS PRESCRIPTION_EVENTS_PER_ACTIVE_BENEFICIARY

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

=========================================
/* Step 40 — Calculate cost per claim/event
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    -- Carrier
    SUM(CARRIER_MEDICARE_PAYMENT) AS CARRIER_PAYMENT,
    SUM(CARRIER_CLAIM_COUNT) AS CARRIER_CLAIMS,
    CAST(
        SUM(CARRIER_MEDICARE_PAYMENT)
        / NULLIF(SUM(CARRIER_CLAIM_COUNT), 0)
        AS DECIMAL(18,2)
    ) AS CARRIER_COST_PER_CLAIM,

    -- Inpatient
    SUM(INPATIENT_MEDICARE_PAYMENT) AS INPATIENT_PAYMENT,
    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,
    CAST(
        SUM(INPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(INPATIENT_CLAIM_COUNT), 0)
        AS DECIMAL(18,2)
    ) AS INPATIENT_COST_PER_CLAIM,

    -- Outpatient
    SUM(OUTPATIENT_MEDICARE_PAYMENT) AS OUTPATIENT_PAYMENT,
    SUM(OUTPATIENT_CLAIM_COUNT) AS OUTPATIENT_CLAIMS,
    CAST(
        SUM(OUTPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(OUTPATIENT_CLAIM_COUNT), 0)
        AS DECIMAL(18,2)
    ) AS OUTPATIENT_COST_PER_CLAIM,

    -- Prescription
    SUM(TOTAL_PRESCRIPTION_COST) AS PRESCRIPTION_COST,
    SUM(PRESCRIPTION_EVENT_COUNT) AS PRESCRIPTION_EVENTS,
    CAST(
        SUM(TOTAL_PRESCRIPTION_COST)
        / NULLIF(SUM(PRESCRIPTION_EVENT_COUNT), 0)
        AS DECIMAL(18,2)
    ) AS PRESCRIPTION_COST_PER_EVENT

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO

====================================================
/* Step 41 — Let's investigate inpatient utilization
*/
USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    -- Beneficiaries receiving inpatient care
    SUM(HAD_INPATIENT_CARE) AS INPATIENT_BENEFICIARIES,

    -- Total inpatient claims
    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,

    -- Claims per inpatient beneficiary
    CAST(
        SUM(INPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_INPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS CLAIMS_PER_INPATIENT_BENEFICIARY,

    -- Total inpatient payment
    SUM(INPATIENT_MEDICARE_PAYMENT) AS INPATIENT_PAYMENT,

    -- Payment per inpatient beneficiary
    CAST(
        SUM(INPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(HAD_INPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS PAYMENT_PER_INPATIENT_BENEFICIARY,

    -- Average claim length
    CAST(
        AVG(
            CASE
                WHEN INPATIENT_CLAIM_COUNT > 0
                THEN AVG_INPATIENT_CLAIM_LENGTH_DAYS
            END
        )
        AS DECIMAL(18,2)
    ) AS AVG_CLAIM_LENGTH_DAYS,

    -- Average length of stay
    CAST(
        AVG(
            CASE
                WHEN INPATIENT_CLAIM_COUNT > 0
                THEN AVG_INPATIENT_LENGTH_OF_STAY_DAYS
            END
        )
        AS DECIMAL(18,2)
    ) AS AVG_LENGTH_OF_STAY_DAYS

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO
======================================
/* Step 42 — Fix the inpatient claims-per-beneficiary calculation
*/

USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    SUM(HAD_INPATIENT_CARE) AS INPATIENT_BENEFICIARIES,

    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,

    CAST(
        1.0 * SUM(INPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_INPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS CLAIMS_PER_INPATIENT_BENEFICIARY,

    SUM(INPATIENT_MEDICARE_PAYMENT) AS INPATIENT_PAYMENT,

    CAST(
        1.0 * SUM(INPATIENT_MEDICARE_PAYMENT)
        / NULLIF(SUM(HAD_INPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS PAYMENT_PER_INPATIENT_BENEFICIARY

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY BENEFICIARY_YEAR

ORDER BY BENEFICIARY_YEAR;
GO
===========================================
/* Step 43 — Chronic conditions and healthcare utilization
Do beneficiaries with more chronic conditions have higher healthcare utilization and healthcare costs?
*/

USE Medicare_Analytics;
GO

SELECT
    BENEFICIARY_YEAR,

    CHRONIC_CONDITION_COUNT,

    COUNT(*) AS BENEFICIARY_YEARS,

    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    SUM(TOTAL_MEDICAL_CLAIMS) AS TOTAL_MEDICAL_CLAIMS,

    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST,

    CAST(
        1.0 * SUM(TOTAL_MEDICAL_CLAIMS)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS MEDICAL_CLAIMS_PER_ACTIVE_BENEFICIARY,

    CAST(
        1.0 * SUM(TOTAL_HEALTHCARE_COST)
        / NULLIF(SUM(HAD_ANY_MEDICARE_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS HEALTHCARE_COST_PER_ACTIVE_BENEFICIARY

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY
    BENEFICIARY_YEAR,
    CHRONIC_CONDITION_COUNT

ORDER BY
    BENEFICIARY_YEAR,
    CHRONIC_CONDITION_COUNT;
GO

=====================================================
/* Step 44 — Validate the chronic-condition count
*/
USE Medicare_Analytics;
GO

SELECT
    CHRONIC_CONDITION_COUNT,
    COUNT(*) AS BENEFICIARY_YEAR_ROWS,
    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,
    SUM(TOTAL_MEDICAL_CLAIMS) AS TOTAL_MEDICAL_CLAIMS,
    SUM(TOTAL_HEALTHCARE_COST) AS TOTAL_HEALTHCARE_COST
FROM dbo.vw_Beneficiary_Annual_Summary
GROUP BY CHRONIC_CONDITION_COUNT
ORDER BY CHRONIC_CONDITION_COUNT;
GO
==============================================
/* Step 45 — Chronic conditions vs inpatient/outpatient/prescription utilization
*/
USE Medicare_Analytics;
GO

SELECT
    CHRONIC_CONDITION_COUNT,

    COUNT(*) AS BENEFICIARY_YEARS,

    SUM(HAD_ANY_MEDICARE_EVENT) AS ACTIVE_BENEFICIARIES,

    SUM(HAD_INPATIENT_CARE) AS INPATIENT_BENEFICIARIES,

    SUM(HAD_OUTPATIENT_CARE) AS OUTPATIENT_BENEFICIARIES,

    SUM(HAD_PRESCRIPTION_EVENT) AS PRESCRIPTION_BENEFICIARIES,

    SUM(INPATIENT_CLAIM_COUNT) AS INPATIENT_CLAIMS,

    SUM(OUTPATIENT_CLAIM_COUNT) AS OUTPATIENT_CLAIMS,

    SUM(PRESCRIPTION_EVENT_COUNT) AS PRESCRIPTION_EVENTS,

    CAST(
        1.0 * SUM(INPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_INPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS INPATIENT_CLAIMS_PER_INPATIENT_BENEFICIARY,

    CAST(
        1.0 * SUM(OUTPATIENT_CLAIM_COUNT)
        / NULLIF(SUM(HAD_OUTPATIENT_CARE), 0)
        AS DECIMAL(18,2)
    ) AS OUTPATIENT_CLAIMS_PER_OUTPATIENT_BENEFICIARY,

    CAST(
        1.0 * SUM(PRESCRIPTION_EVENT_COUNT)
        / NULLIF(SUM(HAD_PRESCRIPTION_EVENT), 0)
        AS DECIMAL(18,2)
    ) AS PRESCRIPTION_EVENTS_PER_PRESCRIPTION_BENEFICIARY

FROM dbo.vw_Beneficiary_Annual_Summary

GROUP BY CHRONIC_CONDITION_COUNT

ORDER BY CHRONIC_CONDITION_COUNT;
GO

========================
/* Step 47 — Identify the highest-cost beneficiary-years
*/

USE Medicare_Analytics;
GO

SELECT TOP 25
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    CHRONIC_CONDITION_COUNT,
    TOTAL_MEDICAL_CLAIMS,
    CARRIER_CLAIM_COUNT,
    INPATIENT_CLAIM_COUNT,
    OUTPATIENT_CLAIM_COUNT,
    PRESCRIPTION_EVENT_COUNT,
    TOTAL_MEDICAL_PAYMENT,
    TOTAL_PRESCRIPTION_COST,
    TOTAL_HEALTHCARE_COST
FROM dbo.vw_Beneficiary_Annual_Summary
ORDER BY TOTAL_HEALTHCARE_COST DESC;
GO
==============================
