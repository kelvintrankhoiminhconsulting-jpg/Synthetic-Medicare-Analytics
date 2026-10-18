# ============================================================
# MEDICARE DATA ANALYTICS PROJECT
# 04B - CLAIM SEGMENT INVESTIGATION
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
# 3. LOAD DATA
# ============================================================

print_section("LOADING DATA")

inpatient = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv"
)

outpatient = pd.read_csv(
    RAW_PATH / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"
)

print("Inpatient rows:", len(inpatient))
print("Outpatient rows:", len(outpatient))


# ============================================================
# 4. INPATIENT - MISSING DATE SEGMENTS
# ============================================================

print_section("INPATIENT - MISSING DATE SEGMENTS")

inpatient_missing_dates = inpatient[
    inpatient["CLM_FROM_DT"].isna()
    | inpatient["CLM_THRU_DT"].isna()
].copy()

print("Missing-date rows:", len(inpatient_missing_dates))

print()
print(
    "Segment distribution:"
)

print(
    inpatient_missing_dates["SEGMENT"]
    .value_counts(dropna=False)
    .sort_index()
)


# ============================================================
# 5. INPATIENT - DO MISSING SEGMENT 2 CLAIMS HAVE SEGMENT 1?
# ============================================================

print_section(
    "INPATIENT - SEGMENT 2 CLAIM PARTNER CHECK"
)

inpatient_segment_2_missing = inpatient_missing_dates[
    inpatient_missing_dates["SEGMENT"] == 2
].copy()

segment_1_claims = set(
    inpatient.loc[
        inpatient["SEGMENT"] == 1,
        "CLM_ID"
    ]
)

inpatient_segment_2_missing["HAS_SEGMENT_1"] = (
    inpatient_segment_2_missing["CLM_ID"]
    .isin(segment_1_claims)
)

print(
    "Missing-date segment-2 rows:",
    len(inpatient_segment_2_missing)
)

print(
    "Segment-2 rows with segment-1 partner:",
    inpatient_segment_2_missing["HAS_SEGMENT_1"].sum()
)

print(
    "Segment-2 rows WITHOUT segment-1 partner:",
    (~inpatient_segment_2_missing["HAS_SEGMENT_1"]).sum()
)


# ============================================================
# 6. INPATIENT - COMPARE DATES BETWEEN SEGMENTS
# ============================================================

print_section(
    "INPATIENT - COMPARE SEGMENT DATES"
)

inpatient_segment_1 = inpatient[
    inpatient["SEGMENT"] == 1
][
    [
        "CLM_ID",
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ]
].copy()

inpatient_segment_1 = inpatient_segment_1.rename(
    columns={
        "CLM_FROM_DT": "SEGMENT_1_FROM_DT",
        "CLM_THRU_DT": "SEGMENT_1_THRU_DT"
    }
)

inpatient_compare = inpatient_segment_2_missing.merge(
    inpatient_segment_1,
    on="CLM_ID",
    how="left"
)

print(
    "Segment-2 records successfully matched to segment 1:",
    inpatient_compare["SEGMENT_1_FROM_DT"].notna().sum()
)

print(
    "Segment-2 records still missing segment-1 dates:",
    inpatient_compare["SEGMENT_1_FROM_DT"].isna().sum()
)

print()
print("First 20 matched claims:")

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "SEGMENT_1_FROM_DT",
    "SEGMENT_1_THRU_DT",
    "CLM_PMT_AMT"
]

print(
    inpatient_compare[
        columns_to_show
    ]
    .head(20)
    .to_string(index=False)
)


# ============================================================
# 7. OUTPATIENT - MISSING DATE SEGMENTS
# ============================================================

print_section("OUTPATIENT - MISSING DATE SEGMENTS")

outpatient_missing_dates = outpatient[
    outpatient["CLM_FROM_DT"].isna()
    | outpatient["CLM_THRU_DT"].isna()
].copy()

print(
    "Missing-date rows:",
    len(outpatient_missing_dates)
)

print()
print("Segment distribution:")

print(
    outpatient_missing_dates["SEGMENT"]
    .value_counts(dropna=False)
    .sort_index()
)


# ============================================================
# 8. OUTPATIENT - DO MISSING SEGMENT 2 CLAIMS HAVE SEGMENT 1?
# ============================================================

print_section(
    "OUTPATIENT - SEGMENT 2 CLAIM PARTNER CHECK"
)

outpatient_segment_2_missing = outpatient_missing_dates[
    outpatient_missing_dates["SEGMENT"] == 2
].copy()

segment_1_claims = set(
    outpatient.loc[
        outpatient["SEGMENT"] == 1,
        "CLM_ID"
    ]
)

outpatient_segment_2_missing["HAS_SEGMENT_1"] = (
    outpatient_segment_2_missing["CLM_ID"]
    .isin(segment_1_claims)
)

print(
    "Missing-date segment-2 rows:",
    len(outpatient_segment_2_missing)
)

print(
    "Segment-2 rows with segment-1 partner:",
    outpatient_segment_2_missing["HAS_SEGMENT_1"].sum()
)

print(
    "Segment-2 rows WITHOUT segment-1 partner:",
    (~outpatient_segment_2_missing["HAS_SEGMENT_1"]).sum()
)


# ============================================================
# 9. OUTPATIENT - COMPARE DATES BETWEEN SEGMENTS
# ============================================================

print_section(
    "OUTPATIENT - COMPARE SEGMENT DATES"
)

outpatient_segment_1 = outpatient[
    outpatient["SEGMENT"] == 1
][
    [
        "CLM_ID",
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ]
].copy()

outpatient_segment_1 = outpatient_segment_1.rename(
    columns={
        "CLM_FROM_DT": "SEGMENT_1_FROM_DT",
        "CLM_THRU_DT": "SEGMENT_1_THRU_DT"
    }
)

outpatient_compare = outpatient_segment_2_missing.merge(
    outpatient_segment_1,
    on="CLM_ID",
    how="left"
)

print(
    "Segment-2 records successfully matched to segment 1:",
    outpatient_compare["SEGMENT_1_FROM_DT"].notna().sum()
)

print(
    "Segment-2 records still missing segment-1 dates:",
    outpatient_compare["SEGMENT_1_FROM_DT"].isna().sum()
)

print()
print("First 20 matched claims:")

columns_to_show = [
    "DESYNPUF_ID",
    "CLM_ID",
    "SEGMENT",
    "CLM_FROM_DT",
    "CLM_THRU_DT",
    "SEGMENT_1_FROM_DT",
    "SEGMENT_1_THRU_DT",
    "CLM_PMT_AMT"
]

print(
    outpatient_compare[
        columns_to_show
    ]
    .head(20)
    .to_string(index=False)
)


# ============================================================
# 10. NEGATIVE PAYMENTS BY SEGMENT
# ============================================================

print_section("NEGATIVE PAYMENTS BY SEGMENT")

negative_inpatient = inpatient[
    inpatient["CLM_PMT_AMT"] < 0
].copy()

negative_outpatient = outpatient[
    outpatient["CLM_PMT_AMT"] < 0
].copy()

print()
print("INPATIENT")
print("-" * 40)

print(
    negative_inpatient["SEGMENT"]
    .value_counts(dropna=False)
    .sort_index()
)

print()
print("OUTPATIENT")
print("-" * 40)

print(
    negative_outpatient["SEGMENT"]
    .value_counts(dropna=False)
    .sort_index()
)


# ============================================================
# 11. NEGATIVE PAYMENTS WITH MISSING DATES
# ============================================================

print_section(
    "NEGATIVE PAYMENTS WITH MISSING DATES"
)

negative_inpatient_missing_dates = negative_inpatient[
    negative_inpatient["CLM_FROM_DT"].isna()
    | negative_inpatient["CLM_THRU_DT"].isna()
]

negative_outpatient_missing_dates = negative_outpatient[
    negative_outpatient["CLM_FROM_DT"].isna()
    | negative_outpatient["CLM_THRU_DT"].isna()
]

print(
    "Inpatient negative payments with missing dates:",
    len(negative_inpatient_missing_dates)
)

print(
    "Outpatient negative payments with missing dates:",
    len(negative_outpatient_missing_dates)
)

print()
print("Outpatient negative payments with missing dates:")

if len(negative_outpatient_missing_dates) > 0:
    columns_to_show = [
        "DESYNPUF_ID",
        "CLM_ID",
        "SEGMENT",
        "CLM_FROM_DT",
        "CLM_THRU_DT",
        "CLM_PMT_AMT",
        "PRVDR_NUM"
    ]

    print(
        negative_outpatient_missing_dates[
            columns_to_show
        ]
        .head(20)
        .to_string(index=False)
    )
else:
    print("None")


# ============================================================
# 12. SUMMARY
# ============================================================

print_section("INVESTIGATION SUMMARY")

print()
print("INPATIENT")
print("-" * 40)
print(
    "Missing-date rows:",
    len(inpatient_missing_dates)
)
print(
    "Missing-date segment-2 rows:",
    len(inpatient_segment_2_missing)
)
print(
    "Segment-2 rows with segment-1 partner:",
    inpatient_segment_2_missing["HAS_SEGMENT_1"].sum()
)
print(
    "Segment-2 rows without segment-1 partner:",
    (~inpatient_segment_2_missing["HAS_SEGMENT_1"]).sum()
)

print()
print("OUTPATIENT")
print("-" * 40)
print(
    "Missing-date rows:",
    len(outpatient_missing_dates)
)
print(
    "Missing-date segment-2 rows:",
    len(outpatient_segment_2_missing)
)
print(
    "Segment-2 rows with segment-1 partner:",
    outpatient_segment_2_missing["HAS_SEGMENT_1"].sum()
)
print(
    "Segment-2 rows without segment-1 partner:",
    (~outpatient_segment_2_missing["HAS_SEGMENT_1"]).sum()
)

print()
print("NEGATIVE PAYMENTS")
print("-" * 40)
print(
    "Negative inpatient payments:",
    len(negative_inpatient)
)
print(
    "Negative outpatient payments:",
    len(negative_outpatient)
)
print(
    "Negative inpatient payments with missing dates:",
    len(negative_inpatient_missing_dates)
)
print(
    "Negative outpatient payments with missing dates:",
    len(negative_outpatient_missing_dates)
)

print()
print("Investigation complete.")
print("No raw data was modified.")
