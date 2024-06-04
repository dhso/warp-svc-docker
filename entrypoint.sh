#!/bin/bash
set -m
warp-svc &
sleep 2

output=$(warp-cli --accept-tos registration show)
account_type=$(echo "$output" | grep "Account type" | awk -F': ' '{print $2}')

if [[ -z $account_type || $account_type == "Free" ]]; then
  if [[ -n $TEAMS_ENROLL_TOKEN ]]; then
    warp-cli --accept-tos registration token "${TEAMS_ENROLL_TOKEN}"
  elif [[ -n $WARP_LICENSE ]]; then
    warp-cli --accept-tos registration license "${WARP_LICENSE}"
  else
    warp-cli --accept-tos registration delete
    warp-cli --accept-tos registration new
  fi
fi

warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos mode proxy
warp-cli --accept-tos dns log disable
warp-cli --accept-tos dns families "${FAMILIES_MODE}"

warp-cli --accept-tos connect
# warp-cli --accept-tos enable-always-on
warp-cli --accept-tos debug connectivity-check disable

if [[ $REOPTIMIZE_INTERVAL -gt 0 ]]; then
    echo "Reoptimize interval is set to $REOPTIMIZE_INTERVAL / minutes"
    crontab="*/$REOPTIMIZE_INTERVAL * * * * /usr/local/bin/reoptimize.sh"
    echo "$crontab" > ./crontab
    echo "CRONTAB ADDED:"
    cat ./crontab
    exec /usr/local/bin/supercronic ./crontab &
fi

sleep 2

socat tcp-listen:1080,reuseaddr,fork tcp:localhost:40000 &

fg %1
