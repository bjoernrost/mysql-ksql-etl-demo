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


ADD start-mysql.sh /usr/local/bin/
ADD start-maxwell.sh /usr/local/bin/
ADD start-ksql.sh /usr/local/bin/
ADD my-maxwell.cnf /etc/mysql/conf.d/
ADD mysql-maxwell-init.sql /tmp/
ADD users.csv /var/lib/mysql-files/
ADD db-setup.sql /var/lib/mysql-files/
ADD db-inserts.sh /
ADD mysql-users.properties /etc/kafka-connect-jdbc/
ADD dashboard.json /usr/share/doc/ksql-clickstream-demo/
ADD orders-to-grafana.sh /usr/share/doc/ksql-clickstream-demo/
ADD datagen-init.sh /

ENTRYPOINT find /var/lib/mysql -type f -exec touch {} \; && service mysql start \
    && /etc/init.d/grafana-server start \
    && /etc/init.d/elasticsearch start \
    && confluent start \
    && start-maxwell.sh \
    && start-ksql.sh \
    && ln -s /usr/share/java/mysql.jar /share/java/kafka-connect-jdbc/ \
    && bash
