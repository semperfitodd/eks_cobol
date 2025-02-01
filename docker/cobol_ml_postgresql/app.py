import os
import json
import psycopg2
import hashlib
from datetime import datetime

# Environment configuration
PGHOST = os.getenv("POSTGRES_CONNECTION_ENDPOINT")
PGDATABASE = os.getenv("POSTGRES_DATABASE_NAME")
PGUSER = os.getenv("POSTGRES_USER")
PGPASSWORD = os.getenv("POSTGRES_PASSWORD")

DATA_DIR = "/output/ingested-data"
LOG_ROOT = "/logs/postgresql"

# Log path generation
def get_log_file_path(filename, row):
    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    log_dir = os.path.join(LOG_ROOT, date_str)
    os.makedirs(log_dir, exist_ok=True)

    ts = datetime.utcnow().strftime("%Y-%m-%dT%H-%M-%SZ")
    hash_suffix = hashlib.md5(row.encode()).hexdigest()[:6]
    safe_filename = filename.replace(".tsv", "")

    return os.path.join(log_dir, f"{ts}-{safe_filename}-{hash_suffix}.json")

# Error logger
def log_error(file, row, reason, classification="ingestion_error"):
    log_entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "file": file,
        "row": row.strip(),
        "reason": reason,
        "classification": classification
    }
    try:
        path = get_log_file_path(file, row)
        with open(path, "w") as log_file:
            json.dump(log_entry, log_file)
    except Exception as e:
        print(f"[LOGGER ERROR] Failed to write error log: {e}")
        print(f"Offending log entry: {log_entry}")

# TSV line parser
def parse_line(line):
    parts = line.strip().split(" ")
    if len(parts) < 3:
        raise ValueError("Line does not contain enough parts to parse")
    date = parts[0]
    amount = parts[-1]
    description = " ".join(parts[1:-1])
    return date, description, float(amount)

# Process and insert file contents into DB
def insert_file(cursor, filepath):
    inserted = 0
    total = 0
    line_number = 0
    with open(filepath, "r") as f:
        for line in f:
            line_number += 1
            if line.strip() == "":
                continue
            total += 1
            try:
                date, description, amount = parse_line(line)
                cursor.execute(
                    "INSERT INTO transactions (transaction_date, description, amount) VALUES (%s, %s, %s)",
                    (date, description, amount)
                )
                inserted += 1
            except Exception as e:
                print(f"[ERROR] {filepath}:{line_number} - {e}")
                log_error(os.path.basename(filepath), line, str(e))
    print(f"[SUMMARY] {filepath} — inserted {inserted} of {total} rows.")
    return inserted

# Main workflow
def main():
    conn = psycopg2.connect(
        host=PGHOST,
        dbname=PGDATABASE,
        user=PGUSER,
        password=PGPASSWORD,
        connect_timeout=10
    )
    conn.autocommit = True
    cursor = conn.cursor()

    files = sorted(
        f for f in os.listdir(DATA_DIR)
        if f.endswith(".tsv") and os.path.isfile(os.path.join(DATA_DIR, f))
    )

    print(f"Found {len(files)} files to process.")

    for filename in files:
        path = os.path.join(DATA_DIR, filename)
        size = os.path.getsize(path)
        print(f"Processing {filename} ({size} bytes)...")

        try:
            count = insert_file(cursor, path)
            if count > 0:
                print(f"Inserted {count} rows from {filename}. Deleting file.")
                os.remove(path)
            else:
                print(f"No rows inserted from {filename}. File not deleted.")
        except Exception as e:
            print(f"[FAILED] {filename} → {e}")

    cursor.close()
    conn.close()

    # Final check of remaining files
    remaining = sorted(
        f for f in os.listdir(DATA_DIR)
        if f.endswith(".tsv") and os.path.isfile(os.path.join(DATA_DIR, f))
    )
    print(f"Remaining files: {remaining}")
    print("All done.")
    exit(0)

if __name__ == "__main__":
    main()
