/* Step 1 — Get table sizes
*/
SELECT 
    t.name AS Table_Name,
    SUM(p.rows) AS Row_Count
FROM sys.tables t
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE t.name IN (
    'beneficiary.clean',
    'Beneficiary_Year',
    'carrier_clean',
    'dim_Beneficiary',
    'inpatient_clean',
    'outpatient_clean',
    'pde_clean'
)
AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;
=========================
/* inspect beneficiary_clean for column names
*/
SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'beneficiary_clean',
    'Beneficiary_Year',
    'carrier_clean',
    'dim_Beneficiary',
    'inpatient_clean',
    'outpatient_clean',
    'pde_clean'
)
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

=========================================
/*inspect beneficiary_clean for row count for all columns*/
SELECT 'beneficiary_clean' AS Table_Name, COUNT(*) AS Row_Count
FROM dbo.beneficiary_clean

UNION ALL

SELECT 'Beneficiary_Year', COUNT(*)
FROM dbo.Beneficiary_Year

UNION ALL

SELECT 'carrier_clean', COUNT(*)
FROM dbo.carrier_clean

UNION ALL

SELECT 'dim_Beneficiary', COUNT(*)
FROM dbo.dim_Beneficiary

UNION ALL

SELECT 'inpatient_clean', COUNT(*)
FROM dbo.inpatient_clean

UNION ALL

SELECT 'outpatient_clean', COUNT(*)
FROM dbo.outpatient_clean

UNION ALL

SELECT 'pde_clean', COUNT(*)
FROM dbo.pde_clean;
/*===========================================
check How many unique beneficiaries?
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Dim_Beneficiary;
/*====================*/
/* Is BenefiDim_Beneficiaryciary_Year unique by beneficiary + year?
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(DESYNPUF_ID, '-', BENEFICIARY_YEAR)) AS Unique_Beneficiary_Years
FROM dbo.Beneficiary_Year;
/*====================================
 What years are actually in the data?
*/
SELECT
    BENEFICIARY_YEAR,
    COUNT(*) AS Beneficiary_Year_Rows,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.Beneficiary_Year
GROUP BY BENEFICIARY_YEAR
ORDER BY BENEFICIARY_YEAR;
/*=================================================
Check the claim date ranges
*/
SELECT
    'Carrier' AS Claim_Type,
    MIN(CLM_FROM_DT) AS Min_Date,
    MAX(CLM_FROM_DT) AS Max_Date
FROM dbo.carrier_clean

UNION ALL

SELECT
    'Inpatient',
    MIN(CLM_FROM_DT),
    MAX(CLM_FROM_DT)
FROM dbo.inpatient_clean

UNION ALL

SELECT
    'Outpatient',
    MIN(CLM_FROM_DT),
    MAX(CLM_FROM_DT)
FROM dbo.outpatient_clean

UNION ALL

SELECT
    'Prescription',
    MIN(SRVC_DT),
    MAX(SRVC_DT)
FROM dbo.pde_clean;
/*========================================================
verify claim keys
*/
SELECT
    'Carrier' AS Table_Name,
    COUNT(*) AS Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_Claim_IDs
FROM dbo.carrier_clean

UNION ALL

SELECT
    'Inpatient',
    COUNT(*),
    COUNT(DISTINCT CLM_ID)
FROM dbo.inpatient_clean

UNION ALL

SELECT
    'Outpatient',
    COUNT(*),
    COUNT(DISTINCT CLM_ID)
FROM dbo.outpatient_clean;
========================================
/* see grain of each claim table */
SELECT
    'Carrier' AS Table_Name,
    COUNT(*) AS Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_Claim_IDs
FROM dbo.carrier_clean

UNION ALL

SELECT
    'Inpatient',
    COUNT(*),
    COUNT(DISTINCT CLM_ID)
FROM dbo.inpatient_clean

UNION ALL

SELECT
    'Outpatient',
    COUNT(*),
    COUNT(DISTINCT CLM_ID)
FROM dbo.outpatient_clean;
=========================================================
/* confirm segment structure */
SELECT
    'Inpatient' AS Table_Name,
    SEGMENT,
    COUNT(*) AS Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_Claims
FROM dbo.inpatient_clean
GROUP BY SEGMENT

UNION ALL

SELECT
    'Outpatient' AS Table_Name,
    SEGMENT,
    COUNT(*) AS Rows,
    COUNT(DISTINCT CLM_ID) AS Unique_Claims
FROM dbo.outpatient_clean
GROUP BY SEGMENT

ORDER BY Table_Name, SEGMENT;
/*=======================================================
validate prescription drug events
*/
SELECT
    COUNT(*) AS Rows,
    COUNT(DISTINCT PDE_ID) AS Unique_PDE_IDs,
    COUNT(DISTINCT DESYNPUF_ID) AS Unique_Beneficiaries
FROM dbo.pde_clean;
=======================================================
/* check count of outpatient clean due to nulls
*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(CLM_FROM_DT) AS Rows_With_CLM_FROM_DT,
    COUNT(*) - COUNT(CLM_FROM_DT) AS Rows_With_NULL_CLM_FROM_DT
FROM dbo.outpatient_clean;
/*check other fact tables for nulls */
SELECT
    'Carrier' AS Table_Name,
    COUNT(*) AS Total_Rows,
    COUNT(CLM_FROM_DT) AS Rows_With_Date,
    COUNT(*) - COUNT(CLM_FROM_DT) AS Rows_With_NULL_Date
FROM dbo.carrier_clean

UNION ALL

SELECT
    'Inpatient',
    COUNT(*),
    COUNT(CLM_FROM_DT),
    COUNT(*) - COUNT(CLM_FROM_DT)
FROM dbo.inpatient_clean

UNION ALL

SELECT
    'Outpatient',
    COUNT(*),
    COUNT(CLM_FROM_DT),
    COUNT(*) - COUNT(CLM_FROM_DT)
FROM dbo.outpatient_clean

UNION ALL

SELECT
    'PDE',
    COUNT(*),
    COUNT(SRVC_DT),
    COUNT(*) - COUNT(SRVC_DT)
FROM dbo.pde_clean;
/*========================================
create or add Date_key to carrier clean */
ALTER TABLE dbo.carrier_clean
ADD DATE_KEY int;
/*populate date_key for carrier*/
UPDATE dbo.carrier_clean
SET DATE_KEY = CONVERT(int, CONVERT(char(8), CLM_FROM_DT, 112))
WHERE CLM_FROM_DT IS NOT NULL;
/*=====================================
verify carrier date_key
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DATE_KEY) AS Rows_With_Date_Key,
    MIN(DATE_KEY) AS Min_Date_Key,
    MAX(DATE_KEY) AS Max_Date_Key
FROM dbo.carrier_clean;
/*=========================================================
add date_key to inpatient clean
*/
ALTER TABLE dbo.inpatient_clean
ADD DATE_KEY int;
/*==========================================
populate patient date_key
*/
UPDATE dbo.inpatient_clean
SET DATE_KEY = CONVERT(int, CONVERT(char(8), CLM_FROM_DT, 112))
WHERE CLM_FROM_DT IS NOT NULL;
/*==========================================
verify inpatient date_key
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DATE_KEY) AS Rows_With_Date_Key,
    COUNT(*) - COUNT(DATE_KEY) AS Rows_With_NULL_Date_Key,
    MIN(DATE_KEY) AS Min_Date_Key,
    MAX(DATE_KEY) AS Max_Date_Key
FROM dbo.inpatient_clean;
/*==========================================
Add DATE_KEY to Outpatient
*/
ALTER TABLE dbo.outpatient_clean
ADD DATE_KEY int;
/*==========================================
Populate Outpatient DATE_KEY
*/
UPDATE dbo.outpatient_clean
SET DATE_KEY = CONVERT(int, CONVERT(char(8), CLM_FROM_DT, 112))
WHERE CLM_FROM_DT IS NOT NULL;
/*==========================================
Verify Outpatient DATE_KEY
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DATE_KEY) AS Rows_With_Date_Key,
    COUNT(*) - COUNT(DATE_KEY) AS Rows_With_NULL_Date_Key,
    MIN(DATE_KEY) AS Min_Date_Key,
    MAX(DATE_KEY) AS Max_Date_Key
FROM dbo.outpatient_clean;

/*==========================================
Add DATE_KEY to PDE
*/
ALTER TABLE dbo.pde_clean
ADD DATE_KEY int;
/*==========================================
Populate PDE DATE_KEY
*/
UPDATE dbo.pde_clean
SET DATE_KEY = CONVERT(int, CONVERT(char(8), SRVC_DT, 112))
WHERE SRVC_DT IS NOT NULL;
/*==========================================
Verify PDE DATE_KEY
*/
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DATE_KEY) AS Rows_With_Date_Key,
    COUNT(*) - COUNT(DATE_KEY) AS Rows_With_NULL_Date_Key,
    MIN(DATE_KEY) AS Min_Date_Key,
    MAX(DATE_KEY) AS Max_Date_Key
FROM dbo.pde_clean;
/*==========================================
Check Carrier payment columns
*/
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'carrier_clean'
  AND COLUMN_NAME LIKE 'LINE_NCH_PMT_AMT_%'
ORDER BY COLUMN_NAME;
/*===================================================
Profile the Carrier payment columns */

SELECT
    COUNT(*) AS Total_Rows,

    COUNT(LINE_NCH_PMT_AMT_1)  AS Amt_1,
    COUNT(LINE_NCH_PMT_AMT_2)  AS Amt_2,
    COUNT(LINE_NCH_PMT_AMT_3)  AS Amt_3,
    COUNT(LINE_NCH_PMT_AMT_4)  AS Amt_4,
    COUNT(LINE_NCH_PMT_AMT_5)  AS Amt_5,
    COUNT(LINE_NCH_PMT_AMT_6)  AS Amt_6,
    COUNT(LINE_NCH_PMT_AMT_7)  AS Amt_7,
    COUNT(LINE_NCH_PMT_AMT_8)  AS Amt_8,
    COUNT(LINE_NCH_PMT_AMT_9)  AS Amt_9,
    COUNT(LINE_NCH_PMT_AMT_10) AS Amt_10,
    COUNT(LINE_NCH_PMT_AMT_11) AS Amt_11,
    COUNT(LINE_NCH_PMT_AMT_12) AS Amt_12,
    COUNT(LINE_NCH_PMT_AMT_13) AS Amt_13

FROM dbo.carrier_clean;
/*===========================================
Calculate the total Carrier payments in SQL Server
*/
SELECT
    SUM(
        COALESCE(LINE_NCH_PMT_AMT_1, 0) +
        COALESCE(LINE_NCH_PMT_AMT_2, 0) +
        COALESCE(LINE_NCH_PMT_AMT_3, 0) +
        COALESCE(LINE_NCH_PMT_AMT_4, 0) +
        COALESCE(LINE_NCH_PMT_AMT_5, 0) +
        COALESCE(LINE_NCH_PMT_AMT_6, 0) +
        COALESCE(LINE_NCH_PMT_AMT_7, 0) +
        COALESCE(LINE_NCH_PMT_AMT_8, 0) +
        COALESCE(LINE_NCH_PMT_AMT_9, 0) +
        COALESCE(LINE_NCH_PMT_AMT_10, 0) +
        COALESCE(LINE_NCH_PMT_AMT_11, 0) +
        COALESCE(LINE_NCH_PMT_AMT_12, 0) +
        COALESCE(LINE_NCH_PMT_AMT_13, 0)
    ) AS Total_Carrier_Payments
FROM dbo.carrier_clean;
/*======================================================

*/

