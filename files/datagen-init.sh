ksql-datagen -daemon quickstart=clickstream format=json topic=clickstream maxInterval=100 iterations=500000

ksql-datagen quickstart=clickstream_codes format=json topic=clickstream_codes maxInterval=20 iterations=100

ksql-datagen quickstart=clickstream_users format=json topic=clickstream_users maxInterval=10 iterations=1000
