#!/bin/bash
set -m
warp-svc &
sleep 2

if [[ -z $TEAMS_ENROLL_TOKEN ]]; then
    warp-cli --accept-tos delete
    warp-cli --accept-tos register
    if [[ -n $WARP_LICENSE ]]; then
      warp-cli --accept-tos set-license "${WARP_LICENSE}"
    fi
    warp-cli --accept-tos set-proxy-port 40000
    warp-cli --accept-tos set-mode proxy
    warp-cli --accept-tos disable-dns-log
    warp-cli --accept-tos set-families-mode "${FAMILIES_MODE}"
else
    warp-cli --accept-tos teams-enroll-token "${TEAMS_ENROLL_TOKEN}"
fi

warp-cli --accept-tos connect
warp-cli --accept-tos enable-always-on

sleep 2

socat tcp-listen:1080,reuseaddr,fork tcp:localhost:40000 &

fg %1
