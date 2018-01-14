mysql < /tmp/mysql-maxwell-init.sql
/maxwell-1.12.0/bin/maxwell --user='maxwell' --password='maxwell' --host='127.0.0.1' --producer=kafka --kafka.bootstrap.servers=localhost:9092 >/tmp/maxwell.log 2>&1 &
