#!/bin/sh
service mongodb start
service mongodb status
service --status-all
python3 generate.py