from pathlib import Path
import pandas as pd


# ============================================================
# 1. SETTINGS
# ============================================================

DATA_PATH = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics\raw_data"
)


# ============================================================
# 2. FILE NAMES
# ============================================================

BENEFICIARY_2008 = DATA_PATH / "DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv"
BENEFICIARY_2009 = DATA_PATH / "DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv"
BENEFICIARY_2010 = DATA_PATH / "DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv"

CARRIER_1A = DATA_PATH / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv"
CARRIER_1B = DATA_PATH / "DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv"

INPATIENT = DATA_PATH / "DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv"
OUTPATIENT = DATA_PATH / "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv"

PDE = DATA_PATH / "DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv"


# ============================================================
# 3. LOAD BENEFICIARY IDs
# ============================================================

print("=" * 70)
print("LOADING BENEFICIARY FILES")
print("=" * 70)

bene_2008 = pd.read_csv(
    BENEFICIARY_2008,
    usecols=["DESYNPUF_ID"],
    dtype={"DESYNPUF_ID": "string"}
)

bene_2009 = pd.read_csv(
    BENEFICIARY_2009,
    usecols=["DESYNPUF_ID"],
    dtype={"DESYNPUF_ID": "string"}
)

bene_2010 = pd.read_csv(
    BENEFICIARY_2010,
    usecols=["DESYNPUF_ID"],
    dtype={"DESYNPUF_ID": "string"}
)

ids_2008 = set(bene_2008["DESYNPUF_ID"].dropna())
ids_2009 = set(bene_2009["DESYNPUF_ID"].dropna())
ids_2010 = set(bene_2010["DESYNPUF_ID"].dropna())

all_beneficiary_ids = ids_2008 | ids_2009 | ids_2010

print(f"2008 beneficiaries: {len(ids_2008):,}")
print(f"2009 beneficiaries: {len(ids_2009):,}")
print(f"2010 beneficiaries: {len(ids_2010):,}")
print(f"Unique beneficiaries across all 3 years: {len(all_beneficiary_ids):,}")


# ============================================================
# 4. BENEFICIARY YEAR-TO-YEAR OVERLAP
# ============================================================

print()
print("=" * 70)
print("BENEFICIARY YEAR-TO-YEAR OVERLAP")
print("=" * 70)

overlap_2008_2009 = ids_2008 & ids_2009
overlap_2009_2010 = ids_2009 & ids_2010
overlap_2008_2010 = ids_2008 & ids_2010
overlap_all_three = ids_2008 & ids_2009 & ids_2010

print(f"Present in both 2008 and 2009: {len(overlap_2008_2009):,}")
print(f"Present in both 2009 and 2010: {len(overlap_2009_2010):,}")
print(f"Present in both 2008 and 2010: {len(overlap_2008_2010):,}")
print(f"Present in all three years:    {len(overlap_all_three):,}")


# ============================================================
# 5. BENEFICIARIES APPEARING IN ONLY ONE YEAR
# ============================================================

print()
print("=" * 70)
print("BENEFICIARIES PRESENT IN ONLY ONE YEAR")
print("=" * 70)

only_2008 = ids_2008 - ids_2009 - ids_2010
only_2009 = ids_2009 - ids_2008 - ids_2010
only_2010 = ids_2010 - ids_2008 - ids_2009

print(f"Only in 2008: {len(only_2008):,}")
print(f"Only in 2009: {len(only_2009):,}")
print(f"Only in 2010: {len(only_2010):,}")


# ============================================================
# 6. FUNCTION TO CHECK CLAIM TABLE RELATIONSHIPS
# ============================================================

def check_beneficiary_relationship(
    file_path,
    table_name,
    columns
):
    df = pd.read_csv(
        file_path,
        usecols=columns,
        dtype={col: "string" for col in columns}
    )

    total_rows = len(df)

    unique_beneficiaries = df["DESYNPUF_ID"].dropna().nunique()

    matching_rows = df["DESYNPUF_ID"].isin(all_beneficiary_ids).sum()

    matching_unique_ids = (
        set(df["DESYNPUF_ID"].dropna())
        & all_beneficiary_ids
    )

    unique_match_rate = (
        len(matching_unique_ids) / unique_beneficiaries * 100
        if unique_beneficiaries > 0
        else 0
    )

    row_match_rate = (
        matching_rows / total_rows * 100
        if total_rows > 0
        else 0
    )

    print()
    print(f"{table_name}")
    print("-" * 70)
    print(f"Total rows:                    {total_rows:,}")
    print(f"Unique beneficiaries:          {unique_beneficiaries:,}")
    print(f"Matching beneficiary IDs:      {len(matching_unique_ids):,}")
    print(f"Unique ID match rate:           {unique_match_rate:.2f}%")
    print(f"Rows with matching beneficiary: {matching_rows:,}")
    print(f"Row match rate:                 {row_match_rate:.2f}%")

    unmatched_ids = (
        set(df["DESYNPUF_ID"].dropna())
        - all_beneficiary_ids
    )

    if len(unmatched_ids) > 0:
        print(f"Unmatched beneficiary IDs:      {len(unmatched_ids):,}")
        print("Sample unmatched IDs:")
        for value in list(unmatched_ids)[:5]:
            print(f"  {value}")
    else:
        print("Unmatched beneficiary IDs:      0")

    return df


# ============================================================
# 7. CHECK CLAIM/EVENT BENEFICIARY RELATIONSHIPS
# ============================================================

print()
print("=" * 70)
print("CLAIM/EVENT TO BENEFICIARY RELATIONSHIPS")
print("=" * 70)

carrier_1a = check_beneficiary_relationship(
    CARRIER_1A,
    "Carrier 1A",
    ["DESYNPUF_ID", "CLM_ID"]
)

carrier_1b = check_beneficiary_relationship(
    CARRIER_1B,
    "Carrier 1B",
    ["DESYNPUF_ID", "CLM_ID"]
)

inpatient = check_beneficiary_relationship(
    INPATIENT,
    "Inpatient",
    ["DESYNPUF_ID", "CLM_ID", "SEGMENT"]
)

outpatient = check_beneficiary_relationship(
    OUTPATIENT,
    "Outpatient",
    ["DESYNPUF_ID", "CLM_ID", "SEGMENT"]
)

pde = check_beneficiary_relationship(
    PDE,
    "Prescription Drug Events",
    ["DESYNPUF_ID", "PDE_ID"]
)


# ============================================================
# 8. CHECK CARRIER 1A VS 1B CLAIM ID OVERLAP
# ============================================================

print()
print("=" * 70)
print("CARRIER 1A VS 1B CLAIM ID VALIDATION")
print("=" * 70)

carrier_1a_claims = set(carrier_1a["CLM_ID"].dropna())
carrier_1b_claims = set(carrier_1b["CLM_ID"].dropna())

carrier_overlap = carrier_1a_claims & carrier_1b_claims

print(f"Carrier 1A unique CLM_IDs: {len(carrier_1a_claims):,}")
print(f"Carrier 1B unique CLM_IDs: {len(carrier_1b_claims):,}")
print(f"CLM_IDs appearing in BOTH:  {len(carrier_overlap):,}")

if len(carrier_overlap) == 0:
    print("RESULT: No CLM_ID overlap detected.")
else:
    print("RESULT: CLM_ID overlap detected.")
    print("Sample overlapping CLM_IDs:")
    for value in list(carrier_overlap)[:5]:
        print(f"  {value}")


# ============================================================
# 9. CHECK INPATIENT DUPLICATE CLM_IDs
# ============================================================

print()
print("=" * 70)
print("INPATIENT CLAIM ID ANALYSIS")
print("=" * 70)

inpatient_claim_counts = inpatient["CLM_ID"].value_counts()

inpatient_repeated = inpatient_claim_counts[
    inpatient_claim_counts > 1
]

print(f"Unique CLM_IDs:                 {inpatient['CLM_ID'].nunique():,}")
print(f"CLM_IDs appearing more than once: {len(inpatient_repeated):,}")
print(f"Maximum rows for one CLM_ID:    {inpatient_claim_counts.max()}")

if len(inpatient_repeated) > 0:

    repeated_claim_ids = inpatient_repeated.head(5).index

    sample_inpatient = inpatient[
        inpatient["CLM_ID"].isin(repeated_claim_ids)
    ].sort_values(["CLM_ID", "SEGMENT"])

    print()
    print("Sample repeated inpatient claims:")
    print(
        sample_inpatient[
            ["DESYNPUF_ID", "CLM_ID", "SEGMENT"]
        ].to_string(index=False)
    )


# ============================================================
# 10. CHECK OUTPATIENT DUPLICATE CLM_IDs
# ============================================================

print()
print("=" * 70)
print("OUTPATIENT CLAIM ID ANALYSIS")
print("=" * 70)

outpatient_claim_counts = outpatient["CLM_ID"].value_counts()

outpatient_repeated = outpatient_claim_counts[
    outpatient_claim_counts > 1
]

print(f"Unique CLM_IDs:                 {outpatient['CLM_ID'].nunique():,}")
print(f"CLM_IDs appearing more than once: {len(outpatient_repeated):,}")
print(f"Maximum rows for one CLM_ID:    {outpatient_claim_counts.max()}")

if len(outpatient_repeated) > 0:

    repeated_claim_ids = outpatient_repeated.head(5).index

    sample_outpatient = outpatient[
        outpatient["CLM_ID"].isin(repeated_claim_ids)
    ].sort_values(["CLM_ID", "SEGMENT"])

    print()
    print("Sample repeated outpatient claims:")
    print(
        sample_outpatient[
            ["DESYNPUF_ID", "CLM_ID", "SEGMENT"]
        ].to_string(index=False)
    )


# ============================================================
# 11. CHECK PDE_ID UNIQUENESS
# ============================================================

print()
print("=" * 70)
print("PRESCRIPTION DRUG EVENT ID VALIDATION")
print("=" * 70)

pde_unique = pde["PDE_ID"].nunique()
pde_rows = len(pde)

print(f"Total PDE rows:       {pde_rows:,}")
print(f"Unique PDE_IDs:       {pde_unique:,}")

if pde_unique == pde_rows:
    print("RESULT: PDE_ID is unique.")
else:
    print("RESULT: Duplicate PDE_IDs detected.")


# ============================================================
# 12. FINAL SUMMARY
# ============================================================

print()
print("=" * 70)
print("RELATIONSHIP VALIDATION COMPLETE")
print("=" * 70)

print()
print("Key items to review:")
print("1. Beneficiary overlap between 2008, 2009, and 2010")
print("2. Claim/event beneficiary match rates")
print("3. Carrier 1A vs 1B CLM_ID overlap")
print("4. Repeated inpatient CLM_IDs")
print("5. Repeated outpatient CLM_IDs")
print("6. PDE_ID uniqueness")
