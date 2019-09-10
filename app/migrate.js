use trip_data
show collections
db.trip_data.createIndex({ "tpep_dropoff_datetime": 1 })
db.trip_data.createIndex({ "DOLocationID": 1 })
db.trip_data.createIndex({ "DOLocationID": 1, "tip_amount": 1 })