#!/usr/bin/bash
source config.sh
source functions.sh

# Create tables
echo "Creating tables..."
RUN_SQL_FILE "create_tables.sql"
echo "Creating tables done."

# Populate 'employees' table
LOAD_FROM_CSV "employees.csv" "employees" "ID, NAME, DEPARTMENT, MANAGER_ID"
