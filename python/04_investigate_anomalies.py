# ============================================================
# MEDICARE DATA ANALYTICS PROJECT
# 04 - TARGETED DATA QUALITY INVESTIGATION
# ============================================================

import pandas as pd
from pathlib import Path


# ============================================================
# 1. FILE PATHS
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
# 3. LOAD DATA
# ============================================================

print_section("LOADING DATA")

beneficiary_2008 = pd.read_csv(
    RAW_PATH / "DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv"
)

beneficiary_2009 = pd.read_csv(
    RAW_PATH / "DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv"
)

beneficiary_2010 = pd.read_csv(
    RAW_PATH / "DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv"
)

carrier_1a = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv"
)

carrier_1b = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv"
)

inpatient = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv"
)

outpatient = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"
)

pde = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv"
)

print("All datasets loaded successfully.")


# ============================================================
# 4. INVESTIGATE INPATIENT MISSING CLAIM DATES
# ============================================================

print_section("INPATIENT - MISSING CLAIM DATES")

inpatient_missing_dates = inpatient[
    inpatient["CLM_FROM_DT"].isna()
    | inpatient["CLM_THRU_DT"].isna()
]

print("Rows with missing claim dates:", len(inpatient_missing_dates))

print()
print("First 20 records:")

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "CLM_PMT_AMT",
    "CLM_UTLZTN_DAY_CNT",
    "PRVDR_NUM"
]

available_columns = [
    col for col in columns_to_show
    if col in inpatient_missing_dates.columns
]

print(
    inpatient_missing_dates[available_columns]
    .head(20)
    .to_string(index=False)
)


# ============================================================
# 5. INVESTIGATE OUTPATIENT MISSING CLAIM DATES
# ============================================================

print_section("OUTPATIENT - MISSING CLAIM DATES")

outpatient_missing_dates = outpatient[
    outpatient["CLM_FROM_DT"].isna()
    | outpatient["CLM_THRU_DT"].isna()
]

print("Rows with missing claim dates:", len(outpatient_missing_dates))

print()
print("First 20 records:")

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "CLM_PMT_AMT",
    "PRVDR_NUM"
]

available_columns = [
    col for col in columns_to_show
    if col in outpatient_missing_dates.columns
]

print(
    outpatient_missing_dates[available_columns]
    .head(20)
    .to_string(index=False)
)


# ============================================================
# 6. INVESTIGATE NEGATIVE BENEFICIARY REIMBURSEMENTS
# ============================================================

print_section("BENEFICIARY - NEGATIVE REIMBURSEMENTS")


def investigate_negative_beneficiary(df, year):

    negative_ip = df[df["MEDREIMB_IP"] < 0]
    negative_op = df[df["MEDREIMB_OP"] < 0]

    print()
    print(f"Beneficiary {year}")
    print("-" * 40)

    print("Negative MEDREIMB_IP:", len(negative_ip))
    print("Negative MEDREIMB_OP:", len(negative_op))

    if len(negative_ip) > 0:
        print()
        print("Negative MEDREIMB_IP records:")

        print(
            negative_ip[
                [
                    "DESYNPUF_ID",
                    "MEDREIMB_IP",
                    "BENRES_IP",
                    "PPPYMT_IP"
                ]
            ].to_string(index=False)
        )

    if len(negative_op) > 0:
        print()
        print("Negative MEDREIMB_OP records:")

        print(
            negative_op[
                [
                    "DESYNPUF_ID",
                    "MEDREIMB_OP",
                    "BENRES_OP",
                    "PPPYMT_OP"
                ]
            ].to_string(index=False)
        )


investigate_negative_beneficiary(
    beneficiary_2008,
    2008
)

investigate_negative_beneficiary(
    beneficiary_2009,
    2009
)

investigate_negative_beneficiary(
    beneficiary_2010,
    2010
)


# ============================================================
# 7. INVESTIGATE NEGATIVE INPATIENT PAYMENTS
# ============================================================

print_section("INPATIENT - NEGATIVE CLAIM PAYMENTS")

negative_inpatient = inpatient[
    inpatient["CLM_PMT_AMT"] < 0
]

print("Negative inpatient payment records:", len(negative_inpatient))

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "CLM_PMT_AMT",
    "NCH_PRMRY_PYR_CLM_PD_AMT",
    "CLM_UTLZTN_DAY_CNT",
    "PRVDR_NUM"
]

available_columns = [
    col for col in columns_to_show
    if col in negative_inpatient.columns
]

print()
print("First 30 negative payment records:")

print(
    negative_inpatient[available_columns]
    .head(30)
    .to_string(index=False)
)


# ============================================================
# 8. INVESTIGATE NEGATIVE OUTPATIENT PAYMENTS
# ============================================================

print_section("OUTPATIENT - NEGATIVE CLAIM PAYMENTS")

negative_outpatient = outpatient[
    outpatient["CLM_PMT_AMT"] < 0
]

print("Negative outpatient payment records:", len(negative_outpatient))

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
    col for col in columns_to_show
    if col in negative_outpatient.columns
]

print()
print("First 30 negative payment records:")

print(
    negative_outpatient[available_columns]
    .head(30)
    .to_string(index=False)
)


# ============================================================
# 9. CHECK NEGATIVE PAYMENTS BY SEGMENT
# ============================================================

print_section("NEGATIVE PAYMENTS BY SEGMENT")

if "SEGMENT" in negative_inpatient.columns:

    print()
    print("INPATIENT")
    print(
        negative_inpatient["SEGMENT"]
        .value_counts(dropna=False)
        .sort_index()
    )


if "SEGMENT" in negative_outpatient.columns:

    print()
    print("OUTPATIENT")
    print(
        negative_outpatient["SEGMENT"]
        .value_counts(dropna=False)
        .sort_index()
    )


# ============================================================
# 10. CHECK NEGATIVE PAYMENT SUMMARY
# ============================================================

print_section("NEGATIVE PAYMENT SUMMARY")

print()
print("INPATIENT")
print("-" * 40)

print(
    negative_inpatient[
        [
            "CLM_PMT_AMT",
            "NCH_PRMRY_PYR_CLM_PD_AMT"
        ]
    ].describe()
)


print()
print("OUTPATIENT")
print("-" * 40)

print(
    negative_outpatient[
        [
            "CLM_PMT_AMT",
            "NCH_PRMRY_PYR_CLM_PD_AMT"
        ]
    ].describe()
)


# ============================================================
# 11. FINAL INVESTIGATION SUMMARY
# ============================================================

print_section("INVESTIGATION SUMMARY")

print(
    "Inpatient missing claim-date rows:",
    len(inpatient_missing_dates)
)

print(
    "Outpatient missing claim-date rows:",
    len(outpatient_missing_dates)
)

print(
    "Negative inpatient payments:",
    len(negative_inpatient)
)

print(
    "Negative outpatient payments:",
    len(negative_outpatient)
)

print()
print("Investigation complete.")
print("No raw data was modified.")
