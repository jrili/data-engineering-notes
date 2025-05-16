#!/usr/bin/bash
source config.sh

function RUN_DB_ADMIN_CMD() {
	db="postgres"
	if [ -n "$2" ]; then
		db=$2
	fi
	psql -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER -W $db -tAc "$1"
	return $?
}

function RUN_DB_CMD() {
	PGPASSWORD=$DB_PROJ_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_PROJ_USER -d $DB_NAME -tAc "$1"
	return $?

}

function RUN_SQL_FILE() {
	PGPASSWORD=$DB_PROJ_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_PROJ_USER -d $DB_NAME -f "$1"
	return $?

}

# Usage: LOAD_FROM_CSV "path/to/input.csv" "table_name_str" "column1,column2,..."
function LOAD_FROM_CSV() {
	path_to_input_csv=$1
	if [[ "$path_to_input_csv" == "" ]]; then
		echo "ERROR: Missing path to input CSV file"
		exit 1
	fi

	table_name=$2
	if [[ "$table_name" == "" ]]; then
		echo "ERROR: Missing table name"
		exit 1
	fi

	columns=$3
	if [[ "$columns" == "" ]]; then
		echo "ERROR: Missing comma-separated columns"
		exit 1
	fi


	echo
	echo "Populating '$table_name' table..."
	RUN_DB_CMD "\COPY $table_name($columns)
        	FROM '$path_to_input_csv'
	        DELIMITER ','
	        CSV HEADER;"
	count=$(RUN_DB_CMD "SELECT COUNT(*) FROM $table_name;")
	echo "Inserted $count rows."

	return $count
}
