#!/bin/sh
service mongodb start
service mongodb status
service --status-all

until mongo --eval "print(\"waited for connection\")"
do
    sleep 60
done

python3 generate.py
