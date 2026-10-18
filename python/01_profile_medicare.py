from pathlib import Path
import pandas as pd


# ============================================================
# SETUP
# ============================================================

DATA_PATH = Path(
    r"C:\Users\Emma Ngo\OneDrive\MEDICARE DATA\Synthetic_Medicare_Data_Analytics\raw_data"
)


# ============================================================
# FIND FILES
# ============================================================

csv_files = sorted(DATA_PATH.glob("*.csv"))

print("=" * 80)
print("MEDICARE DATASET - CONCISE PROFILE")
print("=" * 80)

print(f"\nFiles found: {len(csv_files)}")


# ============================================================
# LOAD DATA
# ============================================================

datasets = {}

for file in csv_files:

    df = pd.read_csv(
        file,
        low_memory=False
    )

    datasets[file.stem] = df


# ============================================================
# 1. DATASET SIZE
# ============================================================

print("\n")
print("=" * 80)
print("1. DATASET SIZE")
print("=" * 80)

for name, df in datasets.items():

    print(
        f"{name:<65}"
        f"Rows: {len(df):>10,}   "
        f"Columns: {len(df.columns):>4}"
    )


# ============================================================
# 2. MISSING VALUES
# ============================================================

print("\n")
print("=" * 80)
print("2. MISSING VALUES")
print("=" * 80)

for name, df in datasets.items():

    missing = df.isna().sum()

    missing = missing[missing > 0]

    print(f"\n{name}")

    if len(missing) == 0:

        print("  No missing values")

    else:

        print(
            f"  Columns with missing values: {len(missing)}"
        )

        # Show only the 10 columns with the most missing values
        top_missing = missing.sort_values(
            ascending=False
        ).head(10)

        for column, count in top_missing.items():

            percentage = (count / len(df)) * 100

            print(
                f"  {column:<30}"
                f"{count:>10,} missing "
                f"({percentage:>6.2f}%)"
            )


# ============================================================
# 3. DUPLICATE ROWS
# ============================================================

print("\n")
print("=" * 80)
print("3. DUPLICATE ROWS")
print("=" * 80)

for name, df in datasets.items():

    duplicates = df.duplicated().sum()

    print(
        f"{name:<65}"
        f"{duplicates:,} duplicate rows"
    )


# ============================================================
# 4. ID COLUMNS
# ============================================================

print("\n")
print("=" * 80)
print("4. ID COLUMN SUMMARY")
print("=" * 80)

for name, df in datasets.items():

    print(f"\n{name}")

    id_columns = [
        column
        for column in df.columns
        if (
            "ID" in column.upper()
            or "DESYNPUF" in column.upper()
        )
    ]

    for column in id_columns:

        unique_count = df[column].nunique(
            dropna=False
        )

        print(
            f"  {column:<30}"
            f"Unique: {unique_count:>10,} "
            f"of {len(df):>10,} rows"
        )


# ============================================================
# 5. DATE COLUMNS
# ============================================================

print("\n")
print("=" * 80)
print("5. DATE COLUMNS")
print("=" * 80)

for name, df in datasets.items():

    print(f"\n{name}")

    date_columns = [
        column
        for column in df.columns
        if "DATE" in column.upper()
    ]

    if len(date_columns) == 0:

        print("  No columns with DATE in the name")

    else:

        for column in date_columns:

            print(
                f"  {column:<30}"
                f"Type: {df[column].dtype}"
            )


# ============================================================
# 6. COLUMN COUNT BY DATASET
# ============================================================

print("\n")
print("=" * 80)
print("6. COLUMN NAMES")
print("=" * 80)

for name, df in datasets.items():

    print(f"\n{name}")
    print("-" * 80)

    print(
        ", ".join(df.columns)
    )


# ============================================================
# COMPLETE
# ============================================================

print("\n")
print("=" * 80)
print("CONCISE PROFILING COMPLETE")
print("=" * 80)

