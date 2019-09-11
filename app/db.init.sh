#!/bin/sh
service mongodb start
service mongodb status
service --status-all
mongoimport --db yellow_cabs --collection trip_data --type csv --headerline --file yellow.csv
rm -rf yellow.csv
mongoimport --db yellow_cabs --collection zone_data --type csv --headerline --file zones.csv
rm -rf zones.csv
until mongo --eval "print(\"waited for connection\")"
do
    sleep 60
done
mongo yellow_cabs --eval "db.trip_data.createIndex({'tpep_dropoff_datetime':1})"
mongo yellow_cabs --eval "db.trip_data.createIndex({'DOLocationID':1})"