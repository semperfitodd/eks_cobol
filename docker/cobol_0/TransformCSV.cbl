       IDENTIFICATION DIVISION.
       PROGRAM-ID. TransformCSV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT InputFile ASSIGN TO "/mnt/efs/input/orders.csv"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT OutputFile ASSIGN TO "/mnt/efs/output/transformed_orders.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD InputFile.
       01 InputRecord.
           05 OrderID              PIC X(4).
           05 Comma1               PIC X.
           05 CustomerName         PIC X(20).
           05 Comma2               PIC X.
           05 AddressField         PIC X(20).
           05 Comma3               PIC X.
           05 Item                 PIC X(10).
           05 Comma4               PIC X.
           05 Amount               PIC X(3).
           05 Comma5               PIC X.
           05 PurchaseFrequency    PIC X(2).

       FD OutputFile.
       01 OutputRecord            PIC X(100).

       WORKING-STORAGE SECTION.
       01 WS-EOF                  PIC X VALUE 'N'.

       PROCEDURE DIVISION.
       MainSection.
           OPEN INPUT InputFile
           OPEN OUTPUT OutputFile
           PERFORM UNTIL WS-EOF = 'Y'
               READ InputFile
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM TransformRecord
               END-READ
           END-PERFORM
           CLOSE InputFile
           CLOSE OutputFile
           STOP RUN.

       TransformRecord.
           MOVE SPACES TO OutputRecord
           STRING "Order: ", OrderID, " | ",
                  CustomerName, " | ",
                  AddressField, " | ",
                  Item, " | ",
                  Amount, " | Frequency: ",
                  PurchaseFrequency
              INTO OutputRecord
              ON OVERFLOW DISPLAY "Error writing record."
           END-STRING
           WRITE OutputRecord.
