       IDENTIFICATION DIVISION.
       PROGRAM-ID. CSVBATCHPROCESS.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FILE-LIST ASSIGN TO "/output/filelist.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CSV-FILE ASSIGN TO DYNAMIC WS-CSV-FILENAME
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CLEAN-FILE ASSIGN TO DYNAMIC WS-TSV-FILENAME
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FILE-LIST.
       01  FILE-LIST-RECORD PIC X(512).

       FD  CSV-FILE.
       01  CSV-RECORD PIC X(512).

       FD  CLEAN-FILE.
       01  CLEAN-RECORD PIC X(512).

       WORKING-STORAGE SECTION.
       01  WS-CSV-FILENAME PIC X(512).  *> Full path of the input CSV file.
       01  WS-TSV-FILENAME PIC X(512).  *> Full path of the output TSV file.
       01  WS-TEMP PIC X(512).          *> Temporary variable for filenames.
       01  WS-BASENAME PIC X(256).      *> Base name of the input file (without path).
       01  WS-MODIFIED-NAME PIC X(256). *> Modified name for the output file.
       01  WS-EOF PIC X VALUE 'N'.      *> End-of-file flag for FILE-LIST loop.
       01  WS-CLEANUP-EOF PIC X VALUE 'N'. *> End-of-file flag for CSV processing loop.
       01  WS-DELIMITER PIC X VALUE ','.
       01  WS-TAB PIC X VALUE '    '.
       01  WS-FIELD1 PIC X(50).
       01  WS-FIELD2 PIC X(50).
       01  WS-FIELD3 PIC X(100).
       01  WS-FIELD4 PIC X(20).
       01  WS-DELETE-COMMAND PIC X(512).

       PROCEDURE DIVISION.

       MAIN-PROCESS.
           PERFORM PREPARE-FILE-LIST.
           OPEN INPUT FILE-LIST.

           PERFORM UNTIL WS-EOF = 'Y'
               PERFORM READ-NEXT-FILE
           END-PERFORM.

           CLOSE FILE-LIST.

           STOP RUN.

       PREPARE-FILE-LIST.
           DISPLAY "Preparing file list...".
           CALL "SYSTEM" USING
               "ls /output/raw-data/*.csv | xargs -n 1 basename > /output/filelist.txt".
           DISPLAY "File list prepared.".

       READ-NEXT-FILE.
           READ FILE-LIST INTO WS-TEMP
               AT END MOVE 'Y' TO WS-EOF
               NOT AT END
                   DISPLAY "Processing file: " WS-TEMP
                   PERFORM PROCESS-FILE.

       PROCESS-FILE.
           *> Prepend directory path to filename to construct full input path.
           STRING "/output/raw-data/"
                  FUNCTION TRIM(WS-TEMP)
                  DELIMITED BY SIZE
                  INTO WS-CSV-FILENAME

           *> Replace "raw" with "ingested" in the filename:
           MOVE FUNCTION TRIM(WS-TEMP) TO WS-BASENAME.

           IF WS-BASENAME(1:4) = "raw-"
               MOVE "ingested" TO WS-BASENAME(1:8)
           END-IF

           *> Replace ".csv" with ".tsv":
           INSPECT WS-BASENAME REPLACING FIRST ".csv" BY ".tsv".

           *> Construct the full output path:
           STRING "/output/ingested-data/"
                  FUNCTION TRIM(WS-BASENAME)
                  DELIMITED BY SIZE
                  INTO WS-TSV-FILENAME.

           DISPLAY "Input CSV File: " WS-CSV-FILENAME.
           DISPLAY "Output TSV File: " WS-TSV-FILENAME.

           OPEN INPUT CSV-FILE OUTPUT CLEAN-FILE.

           MOVE 'N' TO WS-CLEANUP-EOF.

           PERFORM UNTIL WS-CLEANUP-EOF = 'Y'
               PERFORM READ-NEXT-RECORD
               IF WS-CLEANUP-EOF = 'N'
                   PERFORM CONVERT-CSV-TO-TSV
               END-IF
           END-PERFORM.

           CLOSE CSV-FILE CLEAN-FILE.

           PERFORM CLEANUP-FILE.

       READ-NEXT-RECORD.
           READ CSV-FILE INTO WS-TEMP
               AT END MOVE 'Y' TO WS-CLEANUP-EOF.

       CONVERT-CSV-TO-TSV.
           UNSTRING WS-TEMP DELIMITED BY WS-DELIMITER
               INTO WS-FIELD1, WS-FIELD2, WS-FIELD3, WS-FIELD4

           STRING FUNCTION TRIM(WS-FIELD1) WS-TAB
                  FUNCTION TRIM(WS-FIELD2) WS-TAB
                  FUNCTION TRIM(WS-FIELD3) WS-TAB
                  FUNCTION TRIM(WS-FIELD4)
               DELIMITED BY SIZE INTO CLEAN-RECORD

           WRITE CLEAN-RECORD.

       CLEANUP-FILE.
           STRING "rm " FUNCTION TRIM(WS-CSV-FILENAME) DELIMITED BY SIZE
               INTO WS-DELETE-COMMAND.
           DISPLAY "Deleting file: " FUNCTION TRIM(WS-CSV-FILENAME).
           CALL "SYSTEM" USING WS-DELETE-COMMAND.
