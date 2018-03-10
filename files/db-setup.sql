CREATE DATABASE code;
USE code;

CREATE TABLE users (user_id integer primary key, username varchar(42), registered_at bigint, first_name varchar(42), last_name varchar(42), city varchar(42), level varchar(42));

load data infile '/var/lib/mysql-files/users.csv' into table users fields terminated by ',';

CREATE TABLE orders (id integer primary key auto_increment, product varchar(42) not null, price integer not null, user_id int, ordertime datetime not null  );

INSERT INTO orders (product, price, user_id) values ('hello world', 20, 42);

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium' IDENTIFIED BY 'dbz';

GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'localhost' identified by 'maxwell';
GRANT ALL on maxwell.* to 'maxwell'@'localhost';
