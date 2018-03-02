# https://confluentinc.atlassian.net/browse/KSQL-292

ARG DOCKER_UPSTREAM_REGISTRY

FROM ${DOCKER_UPSTREAM_REGISTRY}confluentinc/ksql-clickstream-demo:0.3

EXPOSE 3000

RUN   apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y vim less mysql-server libmysql-java \
    && echo "advertised.listeners=PLAINTEXT://localhost:9092" >> /etc/kafka/server.properties \
    && echo "advertised.host.name=localhost" >> /etc/kafka/server.properties \
    && echo "rest.port=18083" >> /etc/schema-registry/connect-avro-standalone.properties \
    && curl -sLo - https://github.com/zendesk/maxwell/releases/download/v1.12.0/maxwell-1.12.0.tar.gz | tar zxvf -


ADD files/start-mysql.sh /usr/local/bin/
ADD files/start-maxwell.sh /usr/local/bin/
ADD files/start-ksql.sh /usr/local/bin/
ADD files/my-maxwell.cnf /etc/mysql/conf.d/
ADD files/mysql-maxwell-init.sql /tmp/
ADD files/users.csv /var/lib/mysql-files/
ADD files/db-setup.sql /var/lib/mysql-files/
ADD files/db-inserts.sh /
ADD files/mysql-users.properties /etc/kafka-connect-jdbc/
ADD files/dashboard.json /usr/share/doc/ksql-clickstream-demo/
ADD files/orders-to-grafana.sh /usr/share/doc/ksql-clickstream-demo/
ADD files/datagen-init.sh /

ENTRYPOINT find /var/lib/mysql -type f -exec touch {} \; && service mysql start \
    && /etc/init.d/grafana-server start \
    && /etc/init.d/elasticsearch start \
    && confluent start \
    && start-maxwell.sh \
    && start-ksql.sh \
    && ln -s /usr/share/java/mysql.jar /share/java/kafka-connect-jdbc/ \
    && bash
