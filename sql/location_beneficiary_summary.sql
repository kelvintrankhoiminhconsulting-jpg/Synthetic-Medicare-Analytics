/* check for state code in beneficiary table */

SELECT TOP 10 *
FROM dbo.beneficiary_clean;

SELECT
    SP_STATE_CODE,
    COUNT(*) AS Beneficiary_Year_Rows
FROM dbo.beneficiary_clean
GROUP BY SP_STATE_CODE
ORDER BY SP_STATE_CODE;
===============================================
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND (
      TABLE_NAME LIKE '%state%'
      OR TABLE_NAME LIKE '%county%'
      OR TABLE_NAME LIKE '%geo%'
  )
ORDER BY TABLE_NAME;

SELECT
    COUNT(*) AS Beneficiaries_With_Multiple_State_Codes
FROM (
    SELECT DESYNPUF_ID
    FROM dbo.beneficiary_clean
    GROUP BY DESYNPUF_ID
    HAVING COUNT(DISTINCT SP_STATE_CODE) > 1
) AS State_Check;