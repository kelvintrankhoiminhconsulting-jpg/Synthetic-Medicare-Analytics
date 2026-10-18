import pandas as pd
from sqlalchemy import create_engine


# ============================================================
# 1. SQL SERVER CONNECTION
# ============================================================

server = "CHOM-CHOM-MANG-CAU,1433"
database = "Medicare_Analytics"

connection_string = (
    "mssql+pyodbc:///?odbc_connect="
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=CHOM-CHOM-MANG-CAU,1433;"
    "DATABASE=Medicare_Analytics;"
    "Trusted_Connection=yes;"
)

engine = create_engine(connection_string)


# ============================================================
# 2. LOAD DATA FROM SQL SERVER
# ============================================================

query = """

SELECT
    DESYNPUF_ID,
    BENEFICIARY_YEAR,
    BENE_SEX_IDENT_CD,
    BENE_RACE_CD,
    SP_STATE_CODE,
    CHRONIC_CONDITION_COUNT,
    HAD_ANY_MEDICARE_EVENT,
    HAD_INPATIENT_CARE,
    HAD_OUTPATIENT_CARE,
    HAD_PRESCRIPTION_EVENT,
    CARRIER_CLAIM_COUNT,
    INPATIENT_CLAIM_COUNT,
    OUTPATIENT_CLAIM_COUNT,
    PRESCRIPTION_EVENT_COUNT,
    CARRIER_MEDICARE_PAYMENT,
    INPATIENT_MEDICARE_PAYMENT,
    OUTPATIENT_MEDICARE_PAYMENT,
    TOTAL_PRESCRIPTION_COST,
    TOTAL_MEDICAL_CLAIMS,
    TOTAL_MEDICAL_PAYMENT,
    TOTAL_HEALTHCARE_COST

FROM dbo.vw_Beneficiary_Annual_Summary

ORDER BY
    BENEFICIARY_YEAR,
    DESYNPUF_ID;

"""

df = pd.read_sql(query, engine)


# ============================================================
# 3. CHECK DATA
# ============================================================

print("=" * 70)
print("TABLEAU DATASET")
print("=" * 70)

print("Rows:", len(df))
print("Columns:", len(df.columns))

print("\nColumn names:")

for column in df.columns:
    print("-", column)


# ============================================================
# 4. SAVE CSV
# ============================================================

output_path = (
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA"
    r"\Synthetic_Medicare_Data_Analytics"
    r"\tableau"
    r"\tableau_beneficiary_annual.csv"
)

df.to_csv(
    output_path,
    index=False,
    header=True,
    encoding="utf-8-sig",
    lineterminator="\n"
)

print("\nFile saved:")
print(output_path)


# ============================================================
# 5. VERIFY THE ACTUAL FILE CONTENT
# ============================================================

print("\n" + "=" * 70)
print("FILE HEADER VERIFICATION")
print("=" * 70)

with open(output_path, "r", encoding="utf-8-sig") as file:
    first_line = file.readline().strip()

print("\nFirst line of CSV:")
print(first_line)

print("\nExpected first column:")
print(df.columns[0])

if first_line.startswith(df.columns[0]):
    print("\nSUCCESS: CSV header is physically present in the file.")
else:
    print("\nERROR: CSV header is NOT present correctly.")


# ============================================================
# 6. VERIFY ROW COUNT
# ============================================================

check = pd.read_csv(output_path)

print("\n" + "=" * 70)
print("CSV VERIFICATION")
print("=" * 70)

print("Rows:", len(check))
print("Columns:", len(check.columns))

print("\nCSV successfully created.")
