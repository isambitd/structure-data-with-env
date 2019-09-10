FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y curl

RUN mkdir -p /usr/app
WORKDIR /usr/app

RUN curl https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv --output yellow.csv
RUN curl https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv --output zones.csv

RUN apt-get update && apt-get install -y gnupg2
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
RUN apt-get update
RUN apt-get install -y mongodb
RUN mkdir -p /data/db
RUN apt-get clean

COPY app/db.init.sh .
COPY app/migrate.js .
RUN chmod +x ./db.init.sh
RUN sh ./db.init.sh

RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y python-pip
RUN pip3 install pystrich
RUN pip3 install pymongo
RUN apt-get clean

COPY app/generate.py .
COPY app/init.sh .
RUN chmod +x ./init.sh
ENTRYPOINT [ "./init.sh" ]