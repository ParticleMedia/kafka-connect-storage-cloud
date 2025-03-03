FROM confluentinc/cp-kafka-connect-base:7.1.1 as base

USER root
# Download the aws-msk-iam-auth jar for msk authentication
RUN wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar -O /usr/share/java/kafka/aws-msk-iam-auth-1.1.1-all.jar
RUN yum install -y ca-certificates

USER appuser
COPY jmx/config.yaml /

ENV KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=3231 -javaagent:/usr/share/java/cp-base-new/jmx_prometheus_javaagent-0.14.0.jar=0.0.0.0:4241:/config.yaml"
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.0.0
RUN confluent-hub install --no-prompt scylladb/scylla-cdc-source-connector:1.0.1
RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.8.1
RUN confluent-hub install --no-prompt debezium/debezium-connector-mongodb:1.9.7
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-hdfs:10.1.14
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-protobuf-converter:7.1.1

COPY kafka-connect-s3/target/kafka-connect-s3-10.1.0-SNAPSHOT-development/share/java/kafka-connect-s3/kafka-connect-avro-data-7.1.1.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-s3/lib/kafka-connect-avro-data-7.1.1.jar
RUN rm /usr/share/confluent-hub-components/confluentinc-kafka-connect-s3/lib/kafka-connect-avro-data-6.0.1.jar
COPY kafka-connect-s3/target/kafka-connect-s3-10.1.0-SNAPSHOT-development/share/java/kafka-connect-s3/kafka-connect-s3-10.1.0-SNAPSHOT.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-s3/lib/kafka-connect-s3-10.0.0.jar

RUN mkdir -p /usr/share/confluent-hub-components/hudi-kafka-connect/lib
COPY kafka-connect-hudi/hudi-kafka-connect-bundle-0.12.1-amzn-0.jar /usr/share/confluent-hub-components/hudi-kafka-connect/lib/hudi-kafka-connect-bundle-0.12.1-amzn-0.jar
COPY kafka-connect-hudi/aws-java-sdk-bundle-1.11.271.jar /usr/share/confluent-hub-components/hudi-kafka-connect/lib/aws-java-sdk-bundle-1.11.271.jar
COPY kafka-connect-hudi/hadoop-aws-2.10.1.jar /usr/share/confluent-hub-components/hudi-kafka-connect/lib/hadoop-aws-2.10.1.jar
RUN cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-hdfs/lib/* /usr/share/confluent-hub-components/hudi-kafka-connect/lib/

COPY connect-avro-distributed.properties /etc/schema-registry/
COPY lr-model-pipeline.properties /etc/schema-registry/
COPY first.properties /etc/schema-registry/
COPY crawler.properties /etc/schema-registry/
COPY pub_i18n.properties /etc/schema-registry/
COPY pub_euro_i18n.properties /etc/schema-registry/
COPY pub_asia_i18n.properties /etc/schema-registry/
COPY push2.properties /etc/schema-registry/
COPY novastaging.properties /etc/schema-registry/
COPY monetization-msk.properties /etc/schema-registry/
COPY novaprod.properties /etc/schema-registry/
COPY novastaging_test.properties /etc/schema-registry/
COPY bloomprod.properties /etc/schema-registry/
COPY feature.properties /etc/schema-registry/
COPY feed.properties /etc/schema-registry/
COPY tracelog-push.properties /etc/schema-registry/
COPY newsletter-msk.properties /etc/schema-registry/
COPY connect-log4j.properties /etc/kafka/
