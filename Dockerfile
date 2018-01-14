# https://confluentinc.atlassian.net/browse/KSQL-292

ARG DOCKER_UPSTREAM_REGISTRY

FROM ${DOCKER_UPSTREAM_REGISTRY}confluentinc/ksql-clickstream-demo:0.3

EXPOSE 3000

RUN   apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y vim less mysql-server \
    && echo "advertised.listeners=PLAINTEXT://localhost:9092" >> /etc/kafka/server.properties \
    && curl -sLo - https://github.com/zendesk/maxwell/releases/download/v1.12.0/maxwell-1.12.0.tar.gz | tar zxvf -

#RUN find /var/lib/mysql -type f -exec touch {} \; && service mysql start

ADD start-mysql.sh /usr/local/bin/
ADD start-maxwell.sh /usr/local/bin/
ADD my-maxwell.cnf /etc/mysql/conf.d/
ADD mysql-maxwell-init.sql /tmp/

ENTRYPOINT find /var/lib/mysql -type f -exec touch {} \; && service mysql start \
    && /etc/init.d/elasticsearch start \
    && /etc/init.d/grafana-server start \
    && confluent start \
    && start-maxwell.sh \
    && bash
