
# ============================================================
# MEDICARE DATA ANALYTICS PROJECT
# 05b - CREATE DATA QUALITY FLAGS
# ============================================================
#
# Purpose:
#   Create quality flags for known data-quality conditions.
#
# Important:
#   - This script does NOT delete records.
#   - This script does NOT modify the raw CSV files.
#   - It creates a flagged version of the outpatient data
#     for investigation and later analysis.
#
# ============================================================


# ============================================================
# 1. IMPORT LIBRARIES
# ============================================================

import pandas as pd
from pathlib import Path


# ============================================================
# 2. DEFINE FILE PATHS
# ============================================================

BASE_DIR = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics"
)

RAW_DIR = BASE_DIR / "raw_data"
CLEAN_DIR = BASE_DIR / "cleaned_data"

CLEAN_DIR.mkdir(exist_ok=True)


# ============================================================
# 3. LOAD OUTPATIENT DATA
# ============================================================

print("=" * 70)
print("LOADING OUTPATIENT DATA")
print("=" * 70)

outpatient = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"
)

print("Rows loaded:", len(outpatient))
print()


# ============================================================
# 4. CREATE BASIC QUALITY FLAGS
# ============================================================

print("=" * 70)
print("CREATING QUALITY FLAGS")
print("=" * 70)


# ------------------------------------------------------------
# FLAG 1: MISSING CLAIM DATES
# ------------------------------------------------------------
#
# True if either claim date is missing.
#

outpatient["FLAG_MISSING_CLAIM_DATE"] = (
    outpatient["CLM_FROM_DT"].isna()
    | outpatient["CLM_THRU_DT"].isna()
)


# ------------------------------------------------------------
# FLAG 2: SEGMENT 2 WITH MISSING DATES
# ------------------------------------------------------------
#
# Identifies Segment 2 records where claim dates are missing.
#

outpatient["FLAG_SEGMENT_2_MISSING_DATE"] = (
    (outpatient["SEGMENT"] == 2)
    & outpatient["CLM_FROM_DT"].isna()
    & outpatient["CLM_THRU_DT"].isna()
)


# ------------------------------------------------------------
# FLAG 3: NEGATIVE PAYMENT
# ------------------------------------------------------------
#
# Identifies claims with a negative Medicare payment.
#

outpatient["FLAG_NEGATIVE_PAYMENT"] = (
    outpatient["CLM_PMT_AMT"] < 0
)


# ------------------------------------------------------------
# FLAG 4: ZERO PAYMENT
# ------------------------------------------------------------
#
# Identifies claims with a recorded payment of zero.
#
# Zero is NOT automatically considered an error.
# This is simply a useful analytical flag.
#

outpatient["FLAG_ZERO_PAYMENT"] = (
    outpatient["CLM_PMT_AMT"] == 0
)


# ============================================================
# 5. IDENTIFY ORPHAN SEGMENT 2 RECORDS
# ============================================================
#
# An orphan Segment 2 record is:
#
#   SEGMENT = 2
#   missing both claim dates
#   AND
#   there is no corresponding Segment 1 record
#   with the same CLM_ID.
#
# ============================================================


# Get all claim IDs that have Segment 1

segment_1_claim_ids = set(
    outpatient.loc[
        outpatient["SEGMENT"] == 1,
        "CLM_ID"
    ]
)


# Create orphan flag

outpatient["FLAG_ORPHAN_SEGMENT_2"] = (
    (outpatient["SEGMENT"] == 2)
    & outpatient["CLM_FROM_DT"].isna()
    & outpatient["CLM_THRU_DT"].isna()
    & ~outpatient["CLM_ID"].isin(segment_1_claim_ids)
)


# ============================================================
# 6. CREATE OVERALL DATE QUALITY FLAG
# ============================================================

def determine_date_quality(row):

    # Complete dates
    if pd.notna(row["CLM_FROM_DT"]) and pd.notna(row["CLM_THRU_DT"]):
        return "COMPLETE"

    # Orphan Segment 2
    if row["FLAG_ORPHAN_SEGMENT_2"]:
        return "ORPHAN_SEGMENT_2"

    # Segment 2 with missing dates but has Segment 1 partner
    if row["FLAG_SEGMENT_2_MISSING_DATE"]:
        return "SEGMENT_2_MISSING_DATE"

    # Any other missing date situation
    if row["FLAG_MISSING_CLAIM_DATE"]:
        return "OTHER_MISSING_DATE"

    return "CHECK"


outpatient["OUTPATIENT_DATE_QUALITY"] = outpatient.apply(
    determine_date_quality,
    axis=1
)


# ============================================================
# 7. CREATE OVERALL PAYMENT QUALITY FLAG
# ============================================================

def determine_payment_quality(row):

    if row["FLAG_NEGATIVE_PAYMENT"]:
        return "NEGATIVE_PAYMENT"

    if row["FLAG_ZERO_PAYMENT"]:
        return "ZERO_PAYMENT"

    if row["CLM_PMT_AMT"] > 0:
        return "POSITIVE_PAYMENT"

    return "MISSING_PAYMENT"


outpatient["OUTPATIENT_PAYMENT_QUALITY"] = outpatient.apply(
    determine_payment_quality,
    axis=1
)


# ============================================================
# 8. DISPLAY FLAG COUNTS
# ============================================================

print()
print("=" * 70)
print("FLAG SUMMARY")
print("=" * 70)

print(
    "Missing claim dates:",
    outpatient["FLAG_MISSING_CLAIM_DATE"].sum()
)

print(
    "Segment 2 with missing dates:",
    outpatient["FLAG_SEGMENT_2_MISSING_DATE"].sum()
)

print(
    "Orphan Segment 2 records:",
    outpatient["FLAG_ORPHAN_SEGMENT_2"].sum()
)

print(
    "Negative payments:",
    outpatient["FLAG_NEGATIVE_PAYMENT"].sum()
)

print(
    "Zero payments:",
    outpatient["FLAG_ZERO_PAYMENT"].sum()
)


# ============================================================
# 9. DATE QUALITY SUMMARY
# ============================================================

print()
print("=" * 70)
print("DATE QUALITY SUMMARY")
print("=" * 70)

print(
    outpatient["OUTPATIENT_DATE_QUALITY"]
    .value_counts(dropna=False)
)


# ============================================================
# 10. PAYMENT QUALITY SUMMARY
# ============================================================

print()
print("=" * 70)
print("PAYMENT QUALITY SUMMARY")
print("=" * 70)

print(
    outpatient["OUTPATIENT_PAYMENT_QUALITY"]
    .value_counts(dropna=False)
)


# ============================================================
# 11. SHOW ORPHAN RECORDS
# ============================================================

orphans = outpatient[
    outpatient["FLAG_ORPHAN_SEGMENT_2"]
]

print()
print("=" * 70)
print("ORPHAN SEGMENT 2 RECORDS")
print("=" * 70)

print(
    orphans[
        [
            "DESYNPUF_ID",
            "CLM_ID",
            "SEGMENT",
            "CLM_FROM_DT",
            "CLM_THRU_DT",
            "CLM_PMT_AMT",
            "PRVDR_NUM",
            "OUTPATIENT_DATE_QUALITY",
            "OUTPATIENT_PAYMENT_QUALITY"
        ]
    ].head(20).to_string(index=False)
)


# ============================================================
# 12. SAVE FLAGGED DATA
# ============================================================

output_file = CLEAN_DIR / "outpatient_flagged.csv"

outpatient.to_csv(
    output_file,
    index=False
)


# ============================================================
# 13. FINAL SUMMARY
# ============================================================

print()
print("=" * 70)
print("FLAGGED DATA SAVED")
print("=" * 70)

print("Output file:")
print(output_file)

print()
print("Total rows:", len(outpatient))
print("Total columns:", len(outpatient.columns))

print()
print("Quality flag columns added:")

print(" - FLAG_MISSING_CLAIM_DATE")
print(" - FLAG_SEGMENT_2_MISSING_DATE")
print(" - FLAG_NEGATIVE_PAYMENT")
print(" - FLAG_ZERO_PAYMENT")
print(" - FLAG_ORPHAN_SEGMENT_2")
print(" - OUTPATIENT_DATE_QUALITY")
print(" - OUTPATIENT_PAYMENT_QUALITY")

print()
print("=" * 70)
print("FLAGGING COMPLETE")
print("=" * 70)



