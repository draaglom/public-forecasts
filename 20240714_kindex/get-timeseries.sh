#!/bin/sh
set -euo pipefail
echo 'datetime,kp' > timeseries.csv
curl https://kp.gfz-potsdam.de/app/files/Kp_ap_since_1932.txt | tail -n +31 | awk '{ print $1 "-" $2 "-" $3 "T" $4 "0Z," $8 }' | sed 's/\./:/' >> timeseries.csv
