
# ============================================================
# MEDICARE DATA ANALYTICS PROJECT
# 06 - FINAL DATA CLEANING
# ============================================================
#
# Purpose:
#   Create cleaned Medicare datasets for SQL Server and Tableau.
#
# Workflow:
#   Raw CSV -> Python cleaning -> Cleaned CSV -> SQL Server
#
# IMPORTANT:
#   - Raw files are NEVER modified.
#   - NULL values are preserved when they represent missing data.
#   - Zero values are preserved.
#   - Negative payment/reimbursement values are preserved.
#   - Claim segments are preserved.
#
# ============================================================


# ============================================================
# 1. IMPORT LIBRARIES
# ============================================================

import pandas as pd
from pathlib import Path


# ============================================================
# 2. DEFINE PROJECT PATHS
# ============================================================

BASE_DIR = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics"
)

RAW_DIR = BASE_DIR / "raw_data"
CLEAN_DIR = BASE_DIR / "cleaned_data"

CLEAN_DIR.mkdir(exist_ok=True)


# ============================================================
# 3. HELPER FUNCTION - CONVERT YYYYMMDD TO DATE
# ============================================================

def convert_yyyymmdd(df, columns):

    for column in columns:

        if column in df.columns:

            df[column] = pd.to_datetime(
                df[column],
                format="%Y%m%d",
                errors="coerce"
            )

    return df


# ============================================================
# 4. LOAD RAW DATA
# ============================================================

print("=" * 70)
print("LOADING RAW MEDICARE DATA")
print("=" * 70)


beneficiary_2008 = pd.read_csv(
    RAW_DIR / "DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv"
)

beneficiary_2009 = pd.read_csv(
    RAW_DIR / "DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv"
)

beneficiary_2010 = pd.read_csv(
    RAW_DIR / "DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv"
)

carrier_1a = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv"
)

carrier_1b = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv"
)

inpatient = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv"
)

outpatient = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"
)

pde = pd.read_csv(
    RAW_DIR / "DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv"
)


print()
print("Raw files loaded successfully.")
print()


# ============================================================
# 5. CLEAN BENEFICIARY 2008
# ============================================================

print("=" * 70)
print("CLEANING BENEFICIARY DATA")
print("=" * 70)


beneficiary_2008 = convert_yyyymmdd(
    beneficiary_2008,
    [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ]
)

beneficiary_2008["BENEFICIARY_YEAR"] = 2008


# ============================================================
# 6. CLEAN BENEFICIARY 2009
# ============================================================

beneficiary_2009 = convert_yyyymmdd(
    beneficiary_2009,
    [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ]
)

beneficiary_2009["BENEFICIARY_YEAR"] = 2009


# ============================================================
# 7. CLEAN BENEFICIARY 2010
# ============================================================

beneficiary_2010 = convert_yyyymmdd(
    beneficiary_2010,
    [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ]
)

beneficiary_2010["BENEFICIARY_YEAR"] = 2010


# ============================================================
# 8. COMBINE BENEFICIARY YEARS
# ============================================================
#
# IMPORTANT:
# DESYNPUF_ID can appear in multiple annual files.
#
# BENEFICIARY_YEAR keeps the annual snapshot information.
#
# Therefore we do NOT drop duplicate DESYNPUF_ID values
# across years.
#
# ============================================================

beneficiary = pd.concat(
    [
        beneficiary_2008,
        beneficiary_2009,
        beneficiary_2010
    ],
    ignore_index=True
)


# ============================================================
# 9. CLEAN CARRIER CLAIMS
# ============================================================

print("Combining Carrier 1A and Carrier 1B...")


carrier_1a["CARRIER_SOURCE"] = "1A"
carrier_1b["CARRIER_SOURCE"] = "1B"


carrier = pd.concat(
    [
        carrier_1a,
        carrier_1b
    ],
    ignore_index=True
)


carrier = convert_yyyymmdd(
    carrier,
    [
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ]
)


# ============================================================
# 10. CLEAN INPATIENT CLAIMS
# ============================================================

print("Cleaning inpatient claims...")


inpatient = convert_yyyymmdd(
    inpatient,
    [
        "CLM_FROM_DT",
        "CLM_THRU_DT",
        "CLM_ADMSN_DT",
        "NCH_BENE_DSCHRG_DT"
    ]
)


# ------------------------------------------------------------
# INPATIENT DATE QUALITY FLAG
# ------------------------------------------------------------

inpatient["FLAG_MISSING_CLAIM_DATE"] = (
    inpatient["CLM_FROM_DT"].isna()
    | inpatient["CLM_THRU_DT"].isna()
)


# ------------------------------------------------------------
# INPATIENT NEGATIVE PAYMENT FLAG
# ------------------------------------------------------------

inpatient["FLAG_NEGATIVE_PAYMENT"] = (
    inpatient["CLM_PMT_AMT"] < 0
)


# ------------------------------------------------------------
# INPATIENT ZERO PAYMENT FLAG
# ------------------------------------------------------------

inpatient["FLAG_ZERO_PAYMENT"] = (
    inpatient["CLM_PMT_AMT"] == 0
)


# ------------------------------------------------------------
# INPATIENT KEY
# ------------------------------------------------------------
#
# CLM_ID alone is NOT unique.
#
# CLM_ID + SEGMENT is the claim-segment key.
#
# ------------------------------------------------------------

inpatient["CLAIM_SEGMENT_KEY"] = (
    inpatient["CLM_ID"].astype(str)
    + "_"
    + inpatient["SEGMENT"].astype(str)
)


# ============================================================
# 11. CLEAN OUTPATIENT CLAIMS
# ============================================================

print("Cleaning outpatient claims...")


outpatient = convert_yyyymmdd(
    outpatient,
    [
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ]
)


# ============================================================
# 12. OUTPATIENT QUALITY FLAGS
# ============================================================


# ------------------------------------------------------------
# MISSING CLAIM DATE
# ------------------------------------------------------------

outpatient["FLAG_MISSING_CLAIM_DATE"] = (
    outpatient["CLM_FROM_DT"].isna()
    | outpatient["CLM_THRU_DT"].isna()
)


# ------------------------------------------------------------
# SEGMENT 2 WITH MISSING DATES
# ------------------------------------------------------------

outpatient["FLAG_SEGMENT_2_MISSING_DATE"] = (
    (outpatient["SEGMENT"] == 2)
    & outpatient["CLM_FROM_DT"].isna()
    & outpatient["CLM_THRU_DT"].isna()
)


# ------------------------------------------------------------
# NEGATIVE PAYMENT
# ------------------------------------------------------------

outpatient["FLAG_NEGATIVE_PAYMENT"] = (
    outpatient["CLM_PMT_AMT"] < 0
)


# ------------------------------------------------------------
# ZERO PAYMENT
# ------------------------------------------------------------

outpatient["FLAG_ZERO_PAYMENT"] = (
    outpatient["CLM_PMT_AMT"] == 0
)


# ============================================================
# 13. IDENTIFY OUTPATIENT ORPHAN SEGMENT 2 RECORDS
# ============================================================

segment_1_claim_ids = set(
    outpatient.loc[
        outpatient["SEGMENT"] == 1,
        "CLM_ID"
    ]
)


outpatient["FLAG_ORPHAN_SEGMENT_2"] = (
    (outpatient["SEGMENT"] == 2)
    & outpatient["CLM_FROM_DT"].isna()
    & outpatient["CLM_THRU_DT"].isna()
    & ~outpatient["CLM_ID"].isin(segment_1_claim_ids)
)


# ============================================================
# 14. OUTPATIENT DATE QUALITY CATEGORY
# ============================================================

def outpatient_date_quality(row):

    if (
        pd.notna(row["CLM_FROM_DT"])
        and pd.notna(row["CLM_THRU_DT"])
    ):
        return "COMPLETE"

    if row["FLAG_ORPHAN_SEGMENT_2"]:
        return "ORPHAN_SEGMENT_2"

    if row["FLAG_SEGMENT_2_MISSING_DATE"]:
        return "SEGMENT_2_MISSING_DATE"

    if row["FLAG_MISSING_CLAIM_DATE"]:
        return "OTHER_MISSING_DATE"

    return "CHECK"


outpatient["OUTPATIENT_DATE_QUALITY"] = outpatient.apply(
    outpatient_date_quality,
    axis=1
)


# ============================================================
# 15. OUTPATIENT PAYMENT QUALITY
# ============================================================

def outpatient_payment_quality(row):

    if row["FLAG_NEGATIVE_PAYMENT"]:
        return "NEGATIVE_PAYMENT"

    if row["FLAG_ZERO_PAYMENT"]:
        return "ZERO_PAYMENT"

    if row["CLM_PMT_AMT"] > 0:
        return "POSITIVE_PAYMENT"

    return "MISSING_PAYMENT"


outpatient["OUTPATIENT_PAYMENT_QUALITY"] = outpatient.apply(
    outpatient_payment_quality,
    axis=1
)


# ============================================================
# 16. OUTPATIENT CLAIM-SEGMENT KEY
# ============================================================

outpatient["CLAIM_SEGMENT_KEY"] = (
    outpatient["CLM_ID"].astype(str)
    + "_"
    + outpatient["SEGMENT"].astype(str)
)


# ============================================================
# 17. CLEAN PDE
# ============================================================

print("Cleaning prescription drug events...")


pde = convert_yyyymmdd(
    pde,
    [
        "SRVC_DT"
    ]
)


# ============================================================
# 18. FINAL VALIDATION
# ============================================================

print()
print("=" * 70)
print("FINAL VALIDATION")
print("=" * 70)


# ------------------------------------------------------------
# ROW COUNTS
# ------------------------------------------------------------

print()
print("ROW COUNTS")
print("-" * 70)

print("Beneficiary:", len(beneficiary))
print("Carrier:", len(carrier))
print("Inpatient:", len(inpatient))
print("Outpatient:", len(outpatient))
print("PDE:", len(pde))


# ------------------------------------------------------------
# KEY VALIDATION
# ------------------------------------------------------------

print()
print("KEY VALIDATION")
print("-" * 70)

print(
    "Carrier unique CLM_ID:",
    carrier["CLM_ID"].nunique()
)

print(
    "Carrier total rows:",
    len(carrier)
)

print(
    "Inpatient unique CLM_ID + SEGMENT:",
    inpatient["CLAIM_SEGMENT_KEY"].nunique()
)

print(
    "Inpatient total rows:",
    len(inpatient)
)

print(
    "Outpatient unique CLM_ID + SEGMENT:",
    outpatient["CLAIM_SEGMENT_KEY"].nunique()
)

print(
    "Outpatient total rows:",
    len(outpatient)
)

print(
    "PDE unique PDE_ID:",
    pde["PDE_ID"].nunique()
)

print(
    "PDE total rows:",
    len(pde)
)


# ------------------------------------------------------------
# OUTPATIENT QUALITY VALIDATION
# ------------------------------------------------------------

print()
print("OUTPATIENT DATE QUALITY")
print("-" * 70)

print(
    outpatient["OUTPATIENT_DATE_QUALITY"]
    .value_counts(dropna=False)
)


print()
print("OUTPATIENT PAYMENT QUALITY")
print("-" * 70)

print(
    outpatient["OUTPATIENT_PAYMENT_QUALITY"]
    .value_counts(dropna=False)
)


# ------------------------------------------------------------
# NEGATIVE PAYMENT COUNTS
# ------------------------------------------------------------

print()
print("NEGATIVE PAYMENT COUNTS")
print("-" * 70)

print(
    "Inpatient:",
    inpatient["FLAG_NEGATIVE_PAYMENT"].sum()
)

print(
    "Outpatient:",
    outpatient["FLAG_NEGATIVE_PAYMENT"].sum()
)


# ============================================================
# 19. SAVE CLEANED DATA
# ============================================================

print()
print("=" * 70)
print("SAVING CLEANED DATA")
print("=" * 70)


beneficiary.to_csv(
    CLEAN_DIR / "beneficiary_clean.csv",
    index=False
)

carrier.to_csv(
    CLEAN_DIR / "carrier_clean.csv",
    index=False
)

inpatient.to_csv(
    CLEAN_DIR / "inpatient_clean.csv",
    index=False
)

outpatient.to_csv(
    CLEAN_DIR / "outpatient_clean.csv",
    index=False
)

pde.to_csv(
    CLEAN_DIR / "pde_clean.csv",
    index=False
)


# ============================================================
# 20. FINAL FILE SUMMARY
# ============================================================

print()
print("=" * 70)
print("CLEANING COMPLETE")
print("=" * 70)

print()
print("Cleaned files created:")

print(" - beneficiary_clean.csv")
print(" - carrier_clean.csv")
print(" - inpatient_clean.csv")
print(" - outpatient_clean.csv")
print(" - pde_clean.csv")

print()
print("Location:")
print(CLEAN_DIR)

print()
print("Raw data was NOT modified.")

print()
print("=" * 70)
print("READY FOR SQL SERVER")
print("=" * 70)

