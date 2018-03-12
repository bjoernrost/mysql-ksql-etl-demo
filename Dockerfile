# https://confluentinc.atlassian.net/browse/KSQL-292

FROM confluentinc/ksql-clickstream-demo:0.5

EXPOSE 3000

RUN   apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y vim less mysql-server libmysql-java \
    && echo "advertised.listeners=PLAINTEXT://localhost:9092" >> /etc/kafka/server.properties \
    && echo "advertised.host.name=localhost" >> /etc/kafka/server.properties \
    && echo "rest.port=18083" >> /etc/schema-registry/connect-avro-standalone.properties \
    && mkdir /share/java/kafka/plugins \
    && wget -qO- https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/0.7.4/debezium-connector-mysql-0.7.4-plugin.tar.gz | tar xvz -C /share/java/kafka/plugins/ \
    && ln -s /share/java/kafka/plugins/debezium-connector-mysql/*.jar /share/java/kafka/ \
    && sed -e '/sysctl/s/$/ 2>\/dev\/null/g' -i /etc/init.d/elasticsearch

ADD files/db-init.sh /usr/local/bin/
ADD files/connect-debezium.sh /usr/local/bin/
ADD files/start-ksql.sh /usr/local/bin/
ADD files/my-binlog.cnf /etc/mysql/conf.d/
ADD files/users.csv /var/lib/mysql-files/
ADD files/db-setup.sql /var/lib/mysql-files/
ADD files/db-inserts.sh /
ADD files/dashboard.json /usr/share/doc/ksql-clickstream-demo/
ADD files/orders-to-grafana.sh /usr/share/doc/ksql-clickstream-demo/
ADD files/datagen-init.sh /

ENTRYPOINT find /var/lib/mysql -type f -exec touch {} \; && service mysql start \
    && /etc/init.d/grafana-server start \
    && /etc/init.d/elasticsearch start \
    && db-init.sh \
    && confluent start \
    && connect-debezium.sh \
    && start-ksql.sh \
    && bash
