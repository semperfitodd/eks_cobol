#!/bin/bash

set -x

cobc -x -free PostgreSQL.cbl -o PostgreSQL

./PostgreSQL
