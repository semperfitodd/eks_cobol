#!/bin/bash

set -x

cobc -x -free ProcessTSV.cbl -o ProcessTSV

./ProcessTSV
