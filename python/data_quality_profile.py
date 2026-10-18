from pathlib import Path
import pandas as pd


# ============================================================
# 1. SETTINGS
# ============================================================

DATA_PATH = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics\raw_data"
)


# ============================================================
# 2. FILES
# ============================================================

FILES = {
    "Beneficiary 2008":
        "DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv",

    "Beneficiary 2009":
        "DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv",

    "Beneficiary 2010":
        "DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv",

    "Carrier 1A":
        "DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv",

    "Carrier 1B":
        "DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv",

    "Inpatient":
        "DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv",

    "Outpatient":
        "DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv",

    "Prescription Drug Events":
        "DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv"
}


# ============================================================
# 3. HELPER FUNCTION
# ============================================================

def print_section(title):
    print()
    print("=" * 80)
    print(title)
    print("=" * 80)


# ============================================================
# 4. LOAD ALL DATASETS
# ============================================================

print_section("LOADING DATASETS")

datasets = {}

for table_name, file_name in FILES.items():

    file_path = DATA_PATH / file_name

    df = pd.read_csv(
        file_path,
        low_memory=False
    )

    datasets[table_name] = df

    print(
        f"{table_name:<25} "
        f"{len(df):>12,} rows  "
        f"{len(df.columns):>4} columns"
    )


# ============================================================
# 5. COLUMN INVENTORY
# ============================================================

print_section("COLUMN INVENTORY")

for table_name, df in datasets.items():

    print()
    print(f"{table_name}")
    print("-" * 80)

    for column in df.columns:
        print(f"  {column}")


# ============================================================
# 6. DATA TYPES
# ============================================================

print_section("DATA TYPES")

for table_name, df in datasets.items():

    print()
    print(f"{table_name}")
    print("-" * 80)

    print(df.dtypes.to_string())


# ============================================================
# 7. MISSING VALUE SUMMARY
# ============================================================

print_section("MISSING VALUE SUMMARY")

for table_name, df in datasets.items():

    missing = df.isna().sum()

    missing = missing[missing > 0]

    print()
    print(f"{table_name}")
    print("-" * 80)

    if len(missing) == 0:

        print("No missing values.")

    else:

        missing_pct = (
            missing / len(df) * 100
        ).round(2)

        missing_summary = pd.DataFrame({
            "Missing_Count": missing,
            "Missing_Percent": missing_pct
        })

        print(
            missing_summary
            .sort_values(
                "Missing_Count",
                ascending=False
            )
            .to_string()
        )


# ============================================================
# 8. FULL ROW DUPLICATES
# ============================================================

print_section("FULL ROW DUPLICATE CHECK")

for table_name, df in datasets.items():

    duplicate_rows = df.duplicated().sum()

    print(
        f"{table_name:<25} "
        f"Duplicate rows: {duplicate_rows:,}"
    )


# ============================================================
# 9. KEY UNIQUENESS
# ============================================================

print_section("KEY UNIQUENESS")

KEYS = {
    "Beneficiary 2008": ["DESYNPUF_ID"],
    "Beneficiary 2009": ["DESYNPUF_ID"],
    "Beneficiary 2010": ["DESYNPUF_ID"],

    "Carrier 1A": ["CLM_ID"],
    "Carrier 1B": ["CLM_ID"],

    "Inpatient": ["CLM_ID"],
    "Outpatient": ["CLM_ID"],

    "Prescription Drug Events": ["PDE_ID"]
}


for table_name, key_columns in KEYS.items():

    df = datasets[table_name]

    print()
    print(table_name)
    print("-" * 80)

    for column in key_columns:

        total_rows = len(df)
        unique_values = df[column].nunique()
        missing_values = df[column].isna().sum()

        print(f"Column: {column}")
        print(f"  Total rows:       {total_rows:,}")
        print(f"  Unique values:    {unique_values:,}")
        print(f"  Missing values:   {missing_values:,}")

        if unique_values == total_rows and missing_values == 0:
            print("  Result: UNIQUE")
        else:
            print("  Result: NOT UNIQUE")


# ============================================================
# 10. DATE-LIKE COLUMN IDENTIFICATION
# ============================================================

print_section("DATE-LIKE COLUMNS")

for table_name, df in datasets.items():

    date_columns = []

    for column in df.columns:

        column_upper = column.upper()

        if any(
            keyword in column_upper
            for keyword in [
                "DATE",
                "_DT",
                "FROM_DT",
                "THRU_DT"
            ]
        ):
            date_columns.append(column)

    print()
    print(table_name)
    print("-" * 80)

    if date_columns:

        for column in date_columns:

            print(
                f"{column:<30} "
                f"dtype = {df[column].dtype}"
            )

    else:

        print("No obvious date columns found.")


# ============================================================
# 11. DATE RANGE CHECK
# ============================================================

print_section("DATE RANGE CHECK")

DATE_COLUMNS_TO_CHECK = {
    "Beneficiary 2008": [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ],

    "Beneficiary 2009": [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ],

    "Beneficiary 2010": [
        "BENE_BIRTH_DT",
        "BENE_DEATH_DT"
    ],

    "Carrier 1A": [
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ],

    "Carrier 1B": [
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ],

    "Inpatient": [
        "CLM_FROM_DT",
        "CLM_THRU_DT",
        "CLM_ADMSN_DT"
    ],

    "Outpatient": [
        "CLM_FROM_DT",
        "CLM_THRU_DT"
    ],

    "Prescription Drug Events": [
        "SRVC_DT"
    ]
}


for table_name, columns in DATE_COLUMNS_TO_CHECK.items():

    df = datasets[table_name]

    print()
    print(table_name)
    print("-" * 80)

    for column in columns:

        if column not in df.columns:
            print(f"{column}: column not found")
            continue

        series = pd.to_numeric(
            df[column],
            errors="coerce"
        )

        valid_values = series.dropna()

        if len(valid_values) == 0:

            print(f"{column}: no usable values")

        else:

            print(
                f"{column:<20} "
                f"Min: {valid_values.min():.0f}   "
                f"Max: {valid_values.max():.0f}"
            )


# ============================================================
# 12. NUMERIC COLUMN SUMMARY
# ============================================================

print_section("NUMERIC COLUMN SUMMARY")

for table_name, df in datasets.items():

    numeric_columns = df.select_dtypes(
        include=["number"]
    ).columns

    print()
    print(table_name)
    print("-" * 80)

    for column in numeric_columns:

        series = df[column].dropna()

        if len(series) == 0:
            continue

        print(
            f"{column:<35} "
            f"Min={series.min():.2f}  "
            f"Max={series.max():.2f}  "
            f"Mean={series.mean():.2f}"
        )


# ============================================================
# 13. NEGATIVE VALUE CHECK
# ============================================================

print_section("NEGATIVE NUMERIC VALUES")

for table_name, df in datasets.items():

    numeric_columns = df.select_dtypes(
        include=["number"]
    ).columns

    negative_columns = []

    for column in numeric_columns:

        negative_count = (
            df[column] < 0
        ).sum()

        if negative_count > 0:

            negative_columns.append(
                (column, negative_count)
            )

    print()
    print(table_name)
    print("-" * 80)

    if negative_columns:

        for column, count in negative_columns:

            print(
                f"{column:<35} "
                f"Negative values: {count:,}"
            )

    else:

        print("No negative numeric values found.")


# ============================================================
# 14. ZERO VALUE CHECK
# ============================================================

print_section("ZERO VALUE CHECK")

for table_name, df in datasets.items():

    numeric_columns = df.select_dtypes(
        include=["number"]
    ).columns

    zero_columns = []

    for column in numeric_columns:

        zero_count = (
            df[column] == 0
        ).sum()

        if zero_count > 0:

            zero_columns.append(
                (column, zero_count)
            )

    print()
    print(table_name)
    print("-" * 80)

    if zero_columns:

        for column, count in zero_columns:

            print(
                f"{column:<35} "
                f"Zero values: {count:,}"
            )

    else:

        print("No zero numeric values found.")


# ============================================================
# 15. CATEGORICAL VALUE COUNTS
# ============================================================

print_section("IMPORTANT CATEGORICAL VALUE COUNTS")

CATEGORICAL_COLUMNS = {
    "Beneficiary 2008": [
        "BENE_SEX_IDENT_CD",
        "BENE_RACE_CD",
        "BENE_ESRD_IND",
        "SP_ALZHDMTA",
        "SP_CHF",
        "SP_CHRNKIDN",
        "SP_CNCR",
        "SP_COPD",
        "SP_DEPRESSN",
        "SP_DIABETES"
    ],

    "Beneficiary 2009": [
        "BENE_SEX_IDENT_CD",
        "BENE_RACE_CD",
        "BENE_ESRD_IND",
        "SP_ALZHDMTA",
        "SP_CHF",
        "SP_CHRNKIDN",
        "SP_CNCR",
        "SP_COPD",
        "SP_DEPRESSN",
        "SP_DIABETES"
    ],

    "Beneficiary 2010": [
        "BENE_SEX_IDENT_CD",
        "BENE_RACE_CD",
        "BENE_ESRD_IND",
        "SP_ALZHDMTA",
        "SP_CHF",
        "SP_CHRNKIDN",
        "SP_CNCR",
        "SP_COPD",
        "SP_DEPRESSN",
        "SP_DIABETES"
    ]
}


for table_name, columns in CATEGORICAL_COLUMNS.items():

    df = datasets[table_name]

    print()
    print(table_name)
    print("-" * 80)

    for column in columns:

        if column not in df.columns:
            continue

        print()
        print(f"{column}:")

        counts = df[column].value_counts(
            dropna=False
        )

        print(counts.head(10).to_string())


# ============================================================
# 16. PAYMENT / COST COLUMNS
# ============================================================

print_section("PAYMENT AND COST COLUMNS")

for table_name, df in datasets.items():

    cost_columns = []

    for column in df.columns:

        column_upper = column.upper()

        if any(
            keyword in column_upper
            for keyword in [
                "PAY",
                "PMT",
                "COST",
                "REIMB",
                "RES"
            ]
        ):

            if pd.api.types.is_numeric_dtype(
                df[column]
            ):

                cost_columns.append(column)

    print()
    print(table_name)
    print("-" * 80)

    if cost_columns:

        for column in cost_columns:

            series = df[column].dropna()

            if len(series) == 0:
                continue

            print(
                f"{column:<35} "
                f"Min={series.min():.2f}  "
                f"Max={series.max():.2f}  "
                f"Mean={series.mean():.2f}"
            )

    else:

        print("No numeric payment/cost columns found.")


# ============================================================
# 17. FINAL MESSAGE
# ============================================================

print_section("DATA QUALITY PROFILING COMPLETE")

print()
print("No raw data was modified.")
print()
print("The next step will be to interpret these findings")
print("and create specific cleaning rules.")
print()
print("Examples:")
print("- Which missing values should be kept?")
print("- Which date fields need conversion?")
print("- Which numeric fields need validation?")
print("- Which categorical codes need documentation?")
print("- Which claim segments should remain separate?")
print("- Which tables should be combined?")