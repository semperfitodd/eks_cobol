import os
import json
import csv
import psycopg2
from datetime import datetime
from glob import glob

LOG_ROOT = "/logs/cobol"
OUTPUT_PATH = "/logs/training/training-data.csv"

PGHOST = os.getenv("POSTGRES_CONNECTION_ENDPOINT")
PGDATABASE = os.getenv("POSTGRES_DATABASE_NAME")
PGUSER = os.getenv("POSTGRES_USER")
PGPASSWORD = os.getenv("POSTGRES_PASSWORD")

def parse_row_string(row):
    parts = row.strip().split(",")
    if len(parts) != 4:
        return None
    try:
        date_str, category, tx_type, amount_str = parts
        description = f"{category} {tx_type}"
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        amount = float(amount_str)
        is_zero = 1 if amount == 0.0 or amount == -0.0 else 0
        is_negative_zero = 1 if amount_str.strip() == "-0.0" else 0
        return {
            "year": dt.year,
            "month": dt.month,
            "day": dt.day,
            "day_of_week": dt.weekday(),
            "description": description,
            "amount": amount,
            "is_zero": is_zero,
            "is_negative_zero": is_negative_zero
        }
    except:
        return None

def process_error_logs():
    print("[*] Scanning error logs in /logs/cobol...")
    rows = []
    files = glob(f"{LOG_ROOT}/**/*.json", recursive=True)
    print(f"[*] Found {len(files)} error log files.")
    for file in files:
        try:
            with open(file, "r") as f:
                data = json.load(f)
            row = data.get("row", "")
            parsed = parse_row_string(row)
            if parsed:
                parsed["label"] = 1
                rows.append(parsed)
        except:
            continue
    print(f"[+] Parsed {len(rows)} error rows.")
    return rows

def pull_good_rows(n):
    print(f"[*] Connecting to Postgres and pulling {n} good rows...")
    conn = psycopg2.connect(
        host=PGHOST,
        dbname=PGDATABASE,
        user=PGUSER,
        password=PGPASSWORD,
        connect_timeout=10
    )
    cursor = conn.cursor()
    cursor.execute(f"SELECT transaction_date, description, amount FROM transactions ORDER BY random() LIMIT {n};")
    rows = []
    for date_str, description, amount in cursor.fetchall():
        try:
            dt = datetime.strptime(str(date_str), "%Y-%m-%d")
            is_zero = 1 if amount == 0.0 or amount == -0.0 else 0
            is_negative_zero = 1 if str(amount).strip() == "-0.0" else 0
            rows.append({
                "year": dt.year,
                "month": dt.month,
                "day": dt.day,
                "day_of_week": dt.weekday(),
                "description": description,
                "amount": amount,
                "is_zero": is_zero,
                "is_negative_zero": is_negative_zero,
                "label": 0
            })
        except:
            continue
    cursor.close()
    conn.close()
    print(f"[+] Pulled {len(rows)} good rows.")
    return rows

def main():
    print("[*] Starting training data generation...")

    # Delete existing training-data.csv if it exists
    if os.path.exists(OUTPUT_PATH):
        print(f"[*] Deleting existing file: {OUTPUT_PATH}")
        os.remove(OUTPUT_PATH)

    bad_rows = process_error_logs()
    if not bad_rows:
        print("[!] No error logs found. Exiting.")
        return
    good_rows = pull_good_rows(len(bad_rows))
    combined = bad_rows + good_rows
    print(f"[*] Writing combined {len(combined)} rows to {OUTPUT_PATH}...")
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "year", "month", "day", "day_of_week", "description",
            "amount", "is_zero", "is_negative_zero", "label"
        ])
        writer.writeheader()
        for row in combined:
            writer.writerow(row)
    print("[✓] Training data generation complete.")

if __name__ == "__main__":
    main()
