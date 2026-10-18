import pyodbc

print("=" * 70)
print("TESTING SQL SERVER CONNECTION")
print("=" * 70)

server = "CHOM-CHOM-MANG-CAU,1433"
database = "Medicare_Analytics"

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=CHOM-CHOM-MANG-CAU,1433;"
    "DATABASE=Medicare_Analytics;"
    "Trusted_Connection=yes;"
)

try:
    connection = pyodbc.connect(
        connection_string,
        timeout=10
    )

    print("\nSUCCESS!")
    print("Connected to:", server)
    print("Database:", database)

    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            @@SERVERNAME AS Server_Name,
            DB_NAME() AS Database_Name
    """)

    result = cursor.fetchone()

    print("\nSQL Server:", result[0])
    print("Database:", result[1])

    connection.close()

except Exception as error:
    print("\nCONNECTION FAILED")
    print(error)
