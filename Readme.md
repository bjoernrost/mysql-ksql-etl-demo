# rdbms->ksql->grafana demo

I am using this as a playground and demo for a presentation on how to get data from a relational database into kafka, transform with KSQL and finally chart this in a real-time dashboard using grafana. It is heavily based on [an existing ksql clickstream demo by confluent](https://github.com/confluentinc/ksql/tree/v0.5/ksql-clickstream-demo#clickstream-analysis).

These are my notes if you want to replay the same thing.

### prepare and run docker
Pull and run the docker image and start the container

``` sh 
docker pull brost/stream-etl:ksql
-- forwarding the kafka ports so i can connect from my laptop,too
docker run -p 2181:2181 -p 9092:9092 -p 9093:9093 -p 33000:3000 -ti brost/stream-etl:ksql bash
```

### review the bits that are already running
Docker already starts most of the daemons, mysql and background scripts. Have a look around.

``` sh
-- there is already a shell script running that inserts random orders
less db-inserts.sh

-- let's see what's happening in mysql
mysql code

mysql> describe orders;
mysql> select * from orders limit 42;
mysql> insert into orders (product, price, user_id) values ('lumpy', 100, 42);
```

Check for existing topics, there should be one called localhost.code.orders created by Debezium

``` sh
-- show that all our topics are there
kafka-topics --zookeeper localhost:2181 --list
```

And we can run a console consumer to dump the contents of the debezium topic
``` sh
kafka-avro-console-consumer --bootstrap-server=localhost:9092 --topic=localhost.code.orders
```

start ksql, look around and create the ksql objects
``` sh
-- start ksql-cli and initialize the clickstream topics
ksql 

-- note the topic localhost.code.orders from connect-debezium

list topics;

-- now set up out orders table step by step
-- if the stream is already in avro, we do not even have to specify columns

create stream orders_raw with (kafka_topic = 'localhost.code.orders', value_format = 'AVRO', timestamp='ordertime');


-- but we need to cast at least the price to bigint
create stream orders as select id, product, cast(price as bigint) price, user_id, ordertime from orders_raw;


-- select product, count(*), sum(price) from orders window tumbling (size 15 seconds) group by product;

-- now the aggregating table
create table orders_per_min as select product, sum(price) amount from orders window hopping (size 60 seconds, advance by 15 seconds) group by product;

-- and enrich that with the event timestamp
CREATE TABLE orders_per_min_ts WITH (value_format='JSON') as select rowTime as event_ts, * from orders_per_min;

list streams;
list tables;
list topics;
```

### load kafka topics into elastic
Now we load things into elastic and prepare them for grafana. I have messed um something in my dashboard jason and it only loads if I load the original one first. 

``` sh
-- now load the streams into elastic and grafana
 cd /usr/share/doc/ksql-clickstream-demo/

./orders-to-grafana.sh

./clickstream-analysis-dashboard.sh
cp dashboard.json clickstream-analysis-dashboard.json
./clickstream-analysis-dashboard.sh
```

### ready to view the results in your browser

open http://localhost:33000/dashboard/db/click-stream-analysis and log in using admin/admin.

Now you can enter new rows into the orders table and watch the dashboard update.

``` sh
-- now play with some mysql inserts
insert into orders (product, price, user_id, ordertime) values ('lumpy', 500, 42, now());

-- here is a late order - which window does this order count against?
insert into orders (product, price, user_id, ordertime) values ('lumpy', 300, 42, date_sub(now(), interval 1 minute));
```

## random notes. here be dragons
To build the container after changes to the Dockerfile:

``` sh
docker build -t brost/stream-etl:ksql .
```

CREATE STREAM USER_CLICKSTREAM_ORDER AS SELECT userid, u.username, ip, u.city, request, status, bytes, o.product, o.price FROM clickstream c LEFT JOIN web_users u ON c.userid = u.user_id LEFT JOIN orders o on c.userid = o.user_id

This seems to be broken
```create stream orders_partby as select cast(id as integer) as id, product, cast(price as integer) as price, cast(user_id as integer) as user_id from orders_flat partition by id;```

--create table spending_per_min as select user_id, sum(price) amount from orders window tumbling (size 2 minutes) group by user_id ;

--create table user_tally as select user_id, sum(price) amount from orders group by user_id;

No SUM aggregate function with Schema{INT32}  argument type exists!
