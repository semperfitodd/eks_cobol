#!/bin/bash

FILENAME="$1"
ROW=$(echo "$2" | sed 's/[[:space:]]*$//')
REASON="$3"

DATE_UTC=$(date -u +%F)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)
HASH=$(echo "$ROW" | md5sum | cut -c1-6)
LOGDIR="/logs/cobol/${DATE_UTC}"
BASENAME=$(basename "$FILENAME" .tsv)
LOGFILE="${LOGDIR}/${BASENAME}-${HASH}.json"

# Enhanced logging
echo "Debug: Creating directory: $LOGDIR"
mkdir -p "$LOGDIR" 2>/tmp/mkdir_error
if [ $? -ne 0 ]; then
  echo "Error creating directory: $LOGDIR"
  cat /tmp/mkdir_error
fi

echo "Debug: Attempting to write to $LOGFILE"
# Use tee with error redirection to capture errors
cat <<EOF | tee "$LOGFILE" 2>/tmp/write_error
{
  "timestamp": "${TIMESTAMP}",
  "file": "${FILENAME}",
  "row": "${ROW}",
  "reason": "${REASON}",
  "classification": "validation_error"
}
EOF

WRITE_STATUS=$?
echo "Debug: Write operation exit code: $WRITE_STATUS"

# Check file permissions
echo "Debug: File permissions:"
ls -la "$LOGFILE" 2>/tmp/ls_error || cat /tmp/ls_error

# Check filesystem status
echo "Debug: Filesystem status for $LOGDIR:"
df -h "$LOGDIR" 2>/tmp/df_error || cat /tmp/df_error

# Check mount details
echo "Debug: Mount information:"
mount | grep -i s3 2>/tmp/mount_error || cat /tmp/mount_error

if [ -f "$LOGFILE" ]; then
  echo "✅ Log written: $LOGFILE"
else
  echo "❌ Failed to write log file. Error details:"
  if [ -f /tmp/write_error ]; then
    cat /tmp/write_error
  fi
  # Try to write with strace to see system calls
  echo "Debug: Attempting strace of write operation:"
  strace -f -e trace=file,write echo "Test write" > "$LOGFILE" 2>/tmp/strace_output
  cat /tmp/strace_output
fi
