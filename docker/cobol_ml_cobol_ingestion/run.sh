#!/bin/bash

set -x

cobc -x -free IngestCSV.cbl -o IngestCSV

./IngestCSV
