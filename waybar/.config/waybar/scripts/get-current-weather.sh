#!/bin/bash

# Gets the current location of the machine

LOCATION_JSON=$(curl -s http://ip-api.com/json?fields=country,city)

LOCATION_COORDINATES_JSON=$(curl -s http://ip-api.com/json?fields=lat,lon)

# Extract coordinates using grep and cut
LAT=$(echo $LOCATION_COORDINATES_JSON | grep -o '"lat":[0-9.-]*' | cut -d':' -f2)
LON=$(echo $LOCATION_COORDINATES_JSON | grep -o '"lon":[0-9.-]*' | cut -d':' -f2)
CITY=$(echo $LOCATION_JSON | jq -r .city)

ENCODED_CITY=$(echo "$CITY" | sed 's/ /%20/g')

WEATHER=$(curl -s "https://wttr.in/$ENCODED_CITY?format=1")

if [ -z "$WEATHER" ]; then
    echo "Weather: Unable to fetch data"
    exit 1
fi

echo "$CITY $WEATHER"
