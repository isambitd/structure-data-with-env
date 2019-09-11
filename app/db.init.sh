#!/bin/sh
service mongodb start
service mongodb status
service --status-all
mongoimport --db yellow_cabs --collection trip_data --type csv --headerline --file yellow.csv
rm -rf yellow.csv
mongoimport --db yellow_cabs --collection zone_data --type csv --headerline --file zones.csv
rm -rf zones.csv