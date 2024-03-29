import csv
from pymongo import MongoClient, DESCENDING
from heapq import heappush, heappop

# Connecting mongodb
mongo_client = MongoClient()
db = mongo_client.yellow_cabs


# Function to get the date string
def get_date_str(d):
    return str(d) if d > 9 else "0" + str(d)


trip_data = db["trip_data"]
zone_data = db["zone_data"]

# getting zones information and making a dictionary to make it available to every functions
zones = zone_data.find()
zone_map = dict()
zones_to_delete = list()
for document in zones:
    # making dictionary and indexing with locationID will make the search faster for future
    if document["Borough"] != "Unknown" and document["Zone"] != "NA":
        print(document)
        zone_map[document["LocationID"]] = document

# Cleanup
trip_data.delete_many(
    {"DOLocationID": {"$nin": [i for i in zone_map]}})


def generate_longest_trip():
    result_trips = []
    # To get the data for first 7 days of January
    for i in range(1, 8):
        longest_trip_query = {
            "tpep_dropoff_datetime": {
                "$gte": "2018-01-"+get_date_str(i)+" 00:00:00",
                "$lte": "2018-01-"+get_date_str(i)+" 23:59:59"
            }
        }
        # Querying only the top 5 trips with longest distnce
        top_results = trip_data.find(longest_trip_query).sort(
            "trip_distance", DESCENDING).limit(5)
        for document in top_results:
            # Altering the date time to match the output format
            result_trips.append([document["tpep_dropoff_datetime"].split(" ")[0],
                                 document["tpep_dropoff_datetime"].split(" ")[
                0] + "T" + document["tpep_dropoff_datetime"].split(" ")[1] + ".000Z",
                zone_map[document["DOLocationID"]]["Borough"],
                zone_map[document["DOLocationID"]]["Zone"],
                document["trip_distance"]])
    # Creting the csv file
    writer = csv.writer(open("longest_trips_per_day_by_sambit.csv", 'w'))
    writer.writerow(["dropoff_date", "tpep_dropoff_datetime",
                     "Borough", "Zone", "Trip_distance"])
    writer.writerows(result_trips)


def generate_top_tipping():
    # Creating a blank list
    heapList = list()
    # Fetching total tip amount for every zone
    for zone in zone_map:
        pipeline = [
            {"$match": {"DOLocationID": zone}},
            {"$group": {"_id": "$DOLocationID", "sum": {"$sum": "$tip_amount"}}}
        ]
        cursor = trip_data.aggregate(pipeline)
        result = list(cursor)
        if len(result) > 0:
            heappush(heapList, (result[0]["sum"], result[0]["_id"]))
            # It is keeping only top 5 tip amount
            if len(heapList) > 5:
                heappop(heapList)
        print(heapList)
    print(heapList)
    row_list = list()
    while len(heapList) > 0:
        row = list()
        minimum = heappop(heapList)
        row.append(zone_map[minimum[1]]["Borough"])
        row.append(zone_map[minimum[1]]["Zone"])
        row.append(minimum[0])
        row_list.insert(0, row)
    # Creating the csv file
    writer = csv.writer(open("top_tipping_zones_by_sambit.csv", 'w'))
    writer.writerow(["Borough", "Zone", "total_tip_amount"])
    writer.writerows(row_list)


if __name__ == "__main__":
    generate_longest_trip()
    print("longest_trips_file_generate_done!")
    generate_top_tipping()
    print("top_tips_file_generate_done!")
