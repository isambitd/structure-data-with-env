# yellow_cabs

*** Actions ***

downloaded the csv file for trip data from yello cabs website using
`curl https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv --output yellow.csv`

next import the csv file content to mongodb using
`mongoimport --db yellow_cabs --collection trip_data --type csv --headerline --file yellow.csv`

output will be `imported 8759874 documents`

downloaded the csv file using
`curl https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv --output zones.csv`

import the csv file content to mongodb using
`mongoimport --db yellow_cabs --collection zone_data --type csv --headerline --file zones.csv`

output will be `imported 265 documents`

goto mongoshell using `mongo`

then go to the collection
`use yellow_cabs`

Create Indexes
`db.trip_data.createIndex({"tpep_dropoff_datetime":1})`
`db.trip_data.createIndex({"DOLocationID":1})`
`db.trip_data.createIndex({"DOLocationID":1, "tip_amount":1})`

output will be like
`{ "createdCollectionAutomatically" : false, "numIndexesBefore" : 1, "numIndexesAfter" : 2, "ok" : 1 }`
`{ "createdCollectionAutomatically" : false, "numIndexesBefore" : 2, "numIndexesAfter" : 3, "ok" : 1 }`
`{ "createdCollectionAutomatically" : false, "numIndexesBefore" : 3, "numIndexesAfter" : 4, "ok" : 1 }`

Data cleanup
`db.trip_data.remove({"DOLocationID":{"$in": [264, 265]}}, {"multi": true})`


*** What Docker is doing ***
- Creating a container with `Ubuntu`
- Downloading the `csv` files
- Installing `mongodb`
- Dumping the data form `csv` file into `mongodb`
- Creating `Indexes` to make the search faster
- Installing `python3`
- Installing `python libraries`
- Cleaning up the data for the `Zone` named as `NA`
- Generating the longest trips and saving the file with name `longest_trips_per_day_by_sambit.csv` (for the first 7 days of the month)
- Generating the top tips and saving the file with name `top_tipping_zones_by_sambit.csv` (for the top 5 DropOff Locations)
- End 


*** What Shell Script is doing ***
- Cleaning all the Exited and unused images and containers (Anyone can run without cleaning the environment with commenting `clean_and_start` and uncommenting `start`)
- Creating the image from `Dockerfile` 
- Creating the container from the image
- Waiting for the functions to finish their task
- Downloading the output csv files to the output folder named as `outputs`


*** How to run ***
Run `start.sh` in linux terminal


NOTE : Tip amounts are rounded upto two decimal places

*** Assuming docker is installed in test mahcine ***

## Thank you :)
