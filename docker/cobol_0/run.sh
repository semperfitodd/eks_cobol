#!/bin/bash

set -x

cobc -x -free TransformCSV.cbl -o TransformCSV

./TransformCSV
