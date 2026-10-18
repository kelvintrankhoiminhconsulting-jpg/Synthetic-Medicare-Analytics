# ============================================================
# MEDICARE DATA ANALYTICS PROJECT
# 05 - INVESTIGATE OUTPATIENT ORPHAN SEGMENT 2 RECORDS
# ============================================================

import pandas as pd
from pathlib import Path


# ============================================================
# 1. PATHS
# ============================================================

BASE_PATH = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics"
)

RAW_PATH = BASE_PATH / "raw_data"


# ============================================================
# 2. HELPER FUNCTION
# ============================================================

def print_section(title):
    print()
    print("=" * 80)
    print(title)
    print("=" * 80)


# ============================================================
# 3. LOAD OUTPATIENT DATA
# ============================================================

print_section("LOADING OUTPATIENT DATA")

outpatient = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"
)

print("Outpatient rows:", len(outpatient))


# ============================================================
# 4. IDENTIFY SEGMENT 2 RECORDS WITH MISSING DATES
# ============================================================

print_section(
    "SEGMENT 2 RECORDS WITH MISSING DATES"
)

segment_2_missing_dates = outpatient[
    (outpatient["SEGMENT"] == 2)
    & (
        outpatient["CLM_FROM_DT"].isna()
        | outpatient["CLM_THRU_DT"].isna()
    )
].copy()

print(
    "Segment 2 records with missing dates:",
    len(segment_2_missing_dates)
)


# ============================================================
# 5. FIND SEGMENT 1 PARTNERS
# ============================================================

segment_1_claims = set(
    outpatient.loc[
        outpatient["SEGMENT"] == 1,
        "CLM_ID"
    ]
)

segment_2_missing_dates["HAS_SEGMENT_1"] = (
    segment_2_missing_dates["CLM_ID"]
    .isin(segment_1_claims)
)


# ============================================================
# 6. ISOLATE THE 278 ORPHAN RECORDS
# ============================================================

orphans = segment_2_missing_dates[
    segment_2_missing_dates["HAS_SEGMENT_1"] == False
].copy()

print_section("ORPHAN SEGMENT 2 RECORDS")

print(
    "Orphan segment 2 records:",
    len(orphans)
)


# ============================================================
# 7. BASIC INFORMATION
# ============================================================

print_section("ORPHAN RECORD SUMMARY")

print()
print("Unique beneficiaries:")
print(
    orphans["DESYNPUF_ID"].nunique()
)

print()
print("Unique providers:")
print(
    orphans["PRVDR_NUM"].nunique()
)

print()
print("Unique claim IDs:")
print(
    orphans["CLM_ID"].nunique()
)


# ============================================================
# 8. PAYMENT SUMMARY
# ============================================================

print_section("ORPHAN PAYMENT SUMMARY")

print(
    orphans["CLM_PMT_AMT"].describe()
)

print()
print(
    "Negative payments:",
    (orphans["CLM_PMT_AMT"] < 0).sum()
)

print(
    "Zero payments:",
    (orphans["CLM_PMT_AMT"] == 0).sum()
)

print(
    "Positive payments:",
    (orphans["CLM_PMT_AMT"] > 0).sum()
)


# ============================================================
# 9. OTHER IMPORTANT FIELDS
# ============================================================

print_section("ORPHAN RECORD FIELD COMPLETENESS")

important_columns = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "CLM_PMT_AMT",
    "NCH_PRMRY_PYR_CLM_PD_AMT",
    "NCH_BENE_BLOOD_DDCTBL_LBLTY_AM",
    "NCH_BENE_PTB_DDCTBL_AMT",
    "NCH_BENE_PTB_COINSRNC_AMT",
    "PRVDR_NUM"
]

available_columns = [
    col
    for col in important_columns
    if col in orphans.columns
]

for column in available_columns:
    print(
        column,
        "missing:",
        orphans[column].isna().sum(),
        "of",
        len(orphans)
    )


# ============================================================
# 10. CHECK BENEFICIARY DISTRIBUTION
# ============================================================

print_section("TOP BENEFICIARIES WITH ORPHAN SEGMENTS")

print(
    orphans["DESYNPUF_ID"]
    .value_counts()
    .head(20)
)


# ============================================================
# 11. CHECK PROVIDER DISTRIBUTION
# ============================================================

print_section("TOP PROVIDERS WITH ORPHAN SEGMENTS")

print(
    orphans["PRVDR_NUM"]
    .value_counts()
    .head(20)
)


# ============================================================
# 12. DISPLAY SAMPLE RECORDS
# ============================================================

print_section("FIRST 30 ORPHAN RECORDS")

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "CLM_PMT_AMT",
    "NCH_PRMRY_PYR_CLM_PD_AMT",
    "NCH_BENE_BLOOD_DDCTBL_LBLTY_AM",
    "NCH_BENE_PTB_DDCTBL_AMT",
    "NCH_BENE_PTB_COINSRNC_AMT",
    "PRVDR_NUM"
]

available_columns = [
    col
    for col in columns_to_show
    if col in orphans.columns
]

print(
    orphans[
        available_columns
    ]
    .head(30)
    .to_string(index=False)
)


# ============================================================
# 13. FINAL SUMMARY
# ============================================================

print_section("FINAL INVESTIGATION SUMMARY")

print()
print("Total outpatient rows:", len(outpatient))
print(
    "Segment 2 with missing dates:",
    len(segment_2_missing_dates)
)
print(
    "Segment 2 with segment 1 partner:",
    segment_2_missing_dates["HAS_SEGMENT_1"].sum()
)
print(
    "Segment 2 without segment 1 partner:",
    len(orphans)
)
print(
    "Orphan records with negative payments:",
    (orphans["CLM_PMT_AMT"] < 0).sum()
)
print(
    "Orphan records with zero payments:",
    (orphans["CLM_PMT_AMT"] == 0).sum()
)
print(
    "Orphan records with positive payments:",
    (orphans["CLM_PMT_AMT"] > 0).sum()
)

print()
print("Investigation complete.")
print("No raw data was modified.")
