#!/usr/bin/bash
source config.sh
source functions.sh

echo "Initialize DB start. Please be prepared to enter password for DB user '$DB_ADMIN_USER' multiple times."
echo

# Create DB if not yet existing
echo
echo "Checking if DB '$DB_NAME' already exists"
DB_EXISTS=$(RUN_DB_ADMIN_CMD "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';")

if [[ "$DB_EXISTS" -ne 1 ]]; then
	echo "DB '$DB_NAME' does not exist. Creating..."
	createdb -h $DB_HOST -p $DB_PORT -U $DB_ADMIN_USER ${DB_NAME}
	if [ $? -eq 0 ]; then
		echo "DB '$DB_NAME' created."
	else
		echo "DB creation failed. Exiting."
		exit 1
	fi
else
	echo "DB '$DB_NAME' already exists. Skipping creation."
fi


# Create Project user if not yet existing
echo
echo "Checking if DB user '$DB_PROJ_USER' exists"
USER_EXISTS=$(RUN_DB_ADMIN_CMD "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '$DB_PROJ_USER';")

if [[ "$USER_EXISTS" -ne 1 ]]; then
	echo "DB user '$DB_PROJ_USER' does not exist. Creating..."
	RUN_DB_ADMIN_CMD "CREATE ROLE $DB_PROJ_USER LOGIN PASSWORD '$DB_PROJ_PASS'"

	if [ $? -eq 0 ]; then
		echo "DB user '$DB_PROJ_USER' created."
	else
		echo "DB user creation failed. Exiting."
		exit 1
	fi
else
	echo "DB user '$DB_PROJ_USER' already exists. Skipping creation."
	echo

	# Grant all priviliges to DB 
	echo "Granting all privileges to DB '$DB_NAME'..."
	RUN_DB_ADMIN_CMD "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_PROJ_USER"
	if [ $? -eq 1 ]; then
		echo "Granting of privileges failed. Exiting."
		exit 1
	fi

	# Grant usage and create privileges on schema
	echo
	echo "Granting USAGE and CREATE privileges on public schema..."
	RUN_DB_ADMIN_CMD "GRANT USAGE, CREATE ON SCHEMA public TO $DB_PROJ_USER" "$DB_NAME"
	if [ $? -eq 1 ]; then
		echo "Granting of USAGE and CREATE privileges failed. Exiting."
		exit 1
	fi
fi

