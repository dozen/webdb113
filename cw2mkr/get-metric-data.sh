#!/bin/bash

END=$(date +%s)
START=$(($END - 120))

aws cloudwatch get-metric-data \
  --scan-by TimestampDescending \
  --start-time "$START" --end-time "$END" \
  --metric-data-queries file://query.json
