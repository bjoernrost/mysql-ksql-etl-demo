#!/bin/bash

# creates the code database and schema
mysql < /var/lib/mysql-files/db-setup.sql

# run the insert script in a loop
/db-inserts.sh 2>&1 &
